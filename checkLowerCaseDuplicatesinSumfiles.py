#!/usr/bin/env python3
"""
find_sum_dups_fix_blocks.py

Non-recursive inspector and optional fixer for .SUM files, treating two blocks separately:
 - LANDMARKS block: lines between LANDMARKS and LIMB FITS
 - LIMB FITS block: lines between LIMB FITS and END FILE

Default:
  - List stems of .SUM files in --root that contain landmark/limb-fit names that start with a lowercase letter.
  - Use --duplicates to show case-insensitive duplicate groups (reported separately per block).

--fix:
  - For each block in each file, remove lowercase variants of duplicates (keep non-lowercase variants).
  - Creates a backup "<original><suffix>.bak" before modifying.

Other flags:
  --root PATH    Change folder (default: SUMFILES)
  --out FILE     Write report to FILE
  --duplicates   Also show case-insensitive duplicate groups
  --fix          Modify files in-place (creates backups)
  --verbose      Print per-file action details
"""
from __future__ import annotations

import argparse
import re
import shutil
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import List, Dict, Optional, Iterable, Tuple

# Header/terminator regexes
LANDMARKS_HEADER_RE = re.compile(r"^\s*LANDMARKS\b", re.IGNORECASE)
LIMB_FITS_HEADER_RE = re.compile(r"^\s*LIMB\s+FITS\b", re.IGNORECASE)
END_FILE_RE = re.compile(r"^\s*END\s+FILE\b", re.IGNORECASE)

# Token extraction
TOKEN_FINDER_RE = re.compile(r'''(?x)
    (?:"([^"]+)") |     # "quoted"
    (?:'([^']+)')  |    # 'quoted'
    ([A-Za-z_][A-Za-z0-9_.\-]*)  # unquoted starting with letter/_ 
''')
FIRST_TOKEN_RE = re.compile(r"^\s*([A-Za-z0-9_.\-]+)")

# filename suffix (case-insensitive)
FILENAME_SUFFIX = ".sum"


@dataclass
class BlockReport:
    block_name: str  # "LANDMARKS" or "LIMB FITS"
    lowercase_names: List[str]
    duplicate_groups: List[str]
    removed_names: List[str]  # names removed if fix applied


@dataclass
class FileReport:
    path: Path
    stem: str
    landmarks: Optional[BlockReport]
    limbfits: Optional[BlockReport]


def iter_sum_files(root: Path) -> Iterable[Path]:
    """Yield files directly in root whose suffix is .sum (case-insensitive)."""
    for p in sorted(root.iterdir()):
        if p.is_file() and p.suffix.lower() == FILENAME_SUFFIX:
            yield p


def find_block_indices(lines: List[str], start_re: re.Pattern, end_re: re.Pattern) -> Optional[Tuple[int, int]]:
    """
    Return (start_idx, end_idx) for the block that begins after the first line matching start_re
    and ends at the first line matching end_re (end_idx exclusive).
    If start or end not found returns None.
    """
    start = None
    end = None
    for i, ln in enumerate(lines):
        if start is None and start_re.search(ln):
            start = i + 1
            continue
        if start is not None and end_re.search(ln):
            end = i
            break
    if start is None:
        return None
    if end is None:
        # start found but end not found; for LIMB FITS block we allow EOF as end
        return (start, len(lines))
    return (start, end)


def extract_token(line: str) -> Optional[str]:
    """
    Extract preferred token from a line:
      - quoted tokens or tokens starting with letter/_ preferred
      - fallback: first contiguous token of letters/digits/._-
      - if first token is numeric index, try next token
    """
    s = line.strip()
    if not s or s.startswith(("#", ";", "//")):
        return None

    tokens: List[str] = []
    for m in TOKEN_FINDER_RE.finditer(s):
        tokens.append(m.group(1) or m.group(2) or m.group(3))
    if not tokens:
        m = FIRST_TOKEN_RE.match(s)
        if m:
            tokens = [m.group(1)]
    if not tokens:
        return None
    if tokens[0].isdigit() and len(tokens) > 1:
        return tokens[1]
    return tokens[0]


def find_case_insensitive_duplicates(names: List[str]) -> List[str]:
    """Return groups like 'A/a' for buckets with multiple distinct spellings."""
    buckets: Dict[str, List[str]] = defaultdict(list)
    for n in names:
        buckets[n.casefold()].append(n)
    groups: List[str] = []
    for vals in buckets.values():
        seen = []
        for v in vals:
            if v not in seen:
                seen.append(v)
        if len(seen) > 1:
            groups.append("/".join(seen))
    groups.sort(key=lambda x: x.casefold())
    return groups


def analyze_block(lines: List[str], start_idx: int, end_idx: int, block_name: str) -> Optional[BlockReport]:
    """Analyze a block slice lines[start_idx:end_idx]. Return BlockReport if lowercase-starting tokens exist."""
    block_lines = lines[start_idx:end_idx]
    tokens: List[str] = []
    for ln in block_lines:
        t = extract_token(ln)
        if t:
            tokens.append(t)
    if not tokens:
        return None
    lowercase = [t for t in tokens if t and t[0].islower()]
    if not lowercase:
        return None
    duplicates = find_case_insensitive_duplicates(tokens)
    return BlockReport(block_name=block_name, lowercase_names=lowercase, duplicate_groups=duplicates, removed_names=[])


def analyze_file(path: Path) -> Optional[FileReport]:
    """Analyze both blocks in a file. Return FileReport if any block contains lowercase-starting tokens."""
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None
    lines = text.splitlines()
    lm_idx = find_block_indices(lines, LANDMARKS_HEADER_RE, LIMB_FITS_HEADER_RE)
    lf_idx = find_block_indices(lines, LIMB_FITS_HEADER_RE, END_FILE_RE)

    lm_report = analyze_block(lines, lm_idx[0], lm_idx[1], "LANDMARKS") if lm_idx else None
    lf_report = analyze_block(lines, lf_idx[0], lf_idx[1], "LIMB FITS") if lf_idx else None

    if not lm_report and not lf_report:
        return None
    return FileReport(path=path, stem=path.stem, landmarks=lm_report, limbfits=lf_report)


def apply_fix_to_block(lines: List[str], start_idx: int, end_idx: int, verbose: bool = False) -> Tuple[List[str], List[str]]:
    """
    For a block (slice of lines), compute which exact line-indices to remove (returning the new lines list
    and the list of removed token names). Removal policy per-block:
      - For each casefold bucket with multiple variants, remove variants that are fully lowercase (str.islower()).
      - If none fully-lowercase, remove variants whose first character is lowercase.
    Returns (new_block_lines, removed_names_in_block).
    """
    block_lines = lines[start_idx:end_idx]
    name_to_indices: Dict[str, List[int]] = defaultdict(list)
    order: List[str] = []

    for offset, ln in enumerate(block_lines):
        file_idx = start_idx + offset
        nm = extract_token(ln)
        if nm:
            name_to_indices[nm].append(file_idx)
            order.append(nm)

    if not name_to_indices:
        return (block_lines, [])

    # build buckets preserving order
    buckets: Dict[str, List[str]] = defaultdict(list)
    for nm in order:
        key = nm.casefold()
        if nm not in buckets[key]:
            buckets[key].append(nm)

    to_remove_indices: List[int] = []
    removed_names: List[str] = []

    for variants in buckets.values():
        if len(variants) <= 1:
            continue
        # try fully lowercase first
        lower_variants = [v for v in variants if v.islower()]
        if not lower_variants:
            # fallback: variants whose first char is lowercase
            lower_variants = [v for v in variants if v and v[0].islower()]
        if not lower_variants:
            continue
        for var in lower_variants:
            for idx in name_to_indices.get(var, []):
                to_remove_indices.append(idx)
            removed_names.append(var)

    if not to_remove_indices:
        return (block_lines, [])

    # produce new block lines excluding indices
    rem_set = set(to_remove_indices)
    new_block = [ln for offset, ln in enumerate(block_lines) if (start_idx + offset) not in rem_set]

    return (new_block, sorted(set(removed_names)))


def apply_fix(path: Path, verbose: bool = False) -> Optional[FileReport]:
    """
    Apply fixes to both blocks independently. Backup original as <name><suffix>.bak before writing.
    Returns FileReport with removed_names populated per block if any change was made, else possibly returns
    a report with empty removed lists if lowercase found but nothing matched removal policy.
    """
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None
    lines = text.splitlines()
    lm_idx = find_block_indices(lines, LANDMARKS_HEADER_RE, LIMB_FITS_HEADER_RE)
    lf_idx = find_block_indices(lines, LIMB_FITS_HEADER_RE, END_FILE_RE)

    # We'll mutate a working copy of lines
    new_lines = list(lines)
    lm_removed: List[str] = []
    lf_removed: List[str] = []

    modified = False

    # LANDMARKS block
    if lm_idx:
        start, end = lm_idx
        new_block, removed = apply_fix_to_block(new_lines, start, end, verbose=verbose)
        if removed:
            # replace the slice in new_lines
            new_lines = new_lines[:start] + new_block + new_lines[end:]
            lm_removed = removed
            modified = True

    # LIMB FITS block
    # Note: If LANDMARKS modifications changed new_lines length, recompute lf_idx positions relative to original.
    # To keep things simple, we re-parse indices from the modified new_lines based on headers again.
    if lf_idx:
        # find the block indices again in the (possibly) updated new_lines
        lf_idx_new = find_block_indices(new_lines, LIMB_FITS_HEADER_RE, END_FILE_RE)
        if lf_idx_new:
            start2, end2 = lf_idx_new
            new_block2, removed2 = apply_fix_to_block(new_lines, start2, end2, verbose=verbose)
            if removed2:
                new_lines = new_lines[:start2] + new_block2 + new_lines[end2:]
                lf_removed = removed2
                modified = True

    if not modified:
        # Nothing to change; still return a report if lowercase entries existed
        # Build analysis report
        lm_report = None
        lf_report = None
        if lm_idx:
            lm_report = analyze_block_for_report(new_lines, lm_idx[0], lm_idx[1], "LANDMARKS")
        if lf_idx:
            lf_report = analyze_block_for_report(new_lines, lf_idx[0], lf_idx[1], "LIMB FITS")
        if not lm_report and not lf_report:
            return None
        return FileReport(path=path, stem=path.stem, landmarks=lm_report, limbfits=lf_report)

    # create backup
    bak_path = path.with_name(path.name + ".bak")
    try:
        shutil.copy2(path, bak_path)
    except OSError:
        if verbose:
            print(f"[WARN] Could not create backup {bak_path}; aborting change for {path.name}")
        return None

    # write out updated file (ensure trailing newline)
    try:
        out_text = "\n".join(new_lines) + ("\n" if new_lines and not new_lines[-1].endswith("\n") else "")
        path.write_text(out_text, encoding="utf-8")
    except OSError:
        # try restore
        try:
            shutil.copy2(bak_path, path)
        except Exception:
            pass
        if verbose:
            print(f"[WARN] Could not write modified file for {path.name}; original restored from backup.")
        return None

    # prepare final report structure
    lm_report = None
    lf_report = None
    if lm_idx:
        # recompute indices on saved file to create accurate reports
        final_text = path.read_text(encoding="utf-8", errors="replace")
        final_lines = final_text.splitlines()
        lm_idx_fresh = find_block_indices(final_lines, LANDMARKS_HEADER_RE, LIMB_FITS_HEADER_RE)
        if lm_idx_fresh:
            lm_report = analyze_block_for_report(final_lines, lm_idx_fresh[0], lm_idx_fresh[1], "LANDMARKS")
            if lm_report:
                lm_report.removed_names = lm_removed
    if lf_idx:
        final_text = path.read_text(encoding="utf-8", errors="replace")
        final_lines = final_text.splitlines()
        lf_idx_fresh = find_block_indices(final_lines, LIMB_FITS_HEADER_RE, END_FILE_RE)
        if lf_idx_fresh:
            lf_report = analyze_block_for_report(final_lines, lf_idx_fresh[0], lf_idx_fresh[1], "LIMB FITS")
            if lf_report:
                lf_report.removed_names = lf_removed

    return FileReport(path=path, stem=path.stem, landmarks=lm_report, limbfits=lf_report)


def analyze_block_for_report(lines: List[str], start_idx: int, end_idx: int, block_name: str) -> Optional[BlockReport]:
    """Helper to generate BlockReport from current lines (used for final reports)."""
    block_lines = lines[start_idx:end_idx]
    tokens: List[str] = []
    for ln in block_lines:
        t = extract_token(ln)
        if t:
            tokens.append(t)
    if not tokens:
        return None
    lowercase = [t for t in tokens if t and t[0].islower()]
    duplicates = find_case_insensitive_duplicates(tokens)
    if not lowercase:
        return None
    return BlockReport(block_name=block_name, lowercase_names=lowercase, duplicate_groups=duplicates, removed_names=[])


def format_file_report(fr: FileReport, show_duplicates: bool, show_removed: bool) -> List[str]:
    rows: List[str] = []
    def format_block(name: str, br: BlockReport):
        if show_removed and br.removed_names:
            return f"{fr.stem} ({name}): removed: {', '.join(br.removed_names)}"
        if show_duplicates:
            if br.duplicate_groups:
                return f"{fr.stem} ({name}): {', '.join(br.duplicate_groups)}"
            else:
                return f"{fr.stem} ({name}): (lowercase entries; no duplicates)"
        return f"{fr.stem} ({name})"

    if fr.landmarks:
        rows.append(format_block("LANDMARKS", fr.landmarks))
    if fr.limbfits:
        rows.append(format_block("LIMB FITS", fr.limbfits))
    return rows


def main() -> int:
    ap = argparse.ArgumentParser(description="Detect and optionally remove lowercase duplicate tokens in .SUM file blocks (non-recursive).")
    ap.add_argument("--root", default="SUMFILES", help="Folder containing .SUM files (default: SUMFILES)")
    ap.add_argument("--duplicates", action="store_true", help="Show case-insensitive duplicate groups in report")
    ap.add_argument("--fix", action="store_true", help="Modify files in-place to remove lowercase duplicate variants (creates .bak backups)")
    ap.add_argument("--out", default=None, help="Optional output file to write results")
    ap.add_argument("--verbose", action="store_true", help="Print per-file action details")
    args = ap.parse_args()

    root = Path(args.root)
    if not root.exists() or not root.is_dir():
        print(f"[ERROR] Root folder not found or not a directory: {root}")
        return 2

    reports: List[FileReport] = []
    candidates = list(iter_sum_files(root))
    if args.verbose:
        print(f"[INFO] Found {len(candidates)} candidate .SUM file(s) in {root.resolve()} (non-recursive).")

    for p in candidates:
        if args.fix:
            rep = apply_fix(p, verbose=args.verbose)
            if rep:
                reports.append(rep)
                if args.verbose:
                    if rep.landmarks and rep.landmarks.removed_names:
                        print(f"[FIXED] {p.name} LANDMARKS: removed {', '.join(rep.landmarks.removed_names)} (backup: {p.name + '.bak'})")
                    if rep.limbfits and rep.limbfits.removed_names:
                        print(f"[FIXED] {p.name} LIMB FITS: removed {', '.join(rep.limbfits.removed_names)} (backup: {p.name + '.bak'})")
                    if (rep.landmarks and not rep.landmarks.removed_names) or (rep.limbfits and not rep.limbfits.removed_names):
                        print(f"[NOTE] {p.name}: lowercase entries found but none matched the removal policy for some blocks.")
        else:
            rep = analyze_file(p)
            if rep:
                reports.append(rep)
                if args.verbose:
                    if rep.landmarks:
                        print(f"[REPORT] {p.name} LANDMARKS: lowercase: {', '.join(rep.landmarks.lowercase_names)}")
                    if rep.limbfits:
                        print(f"[REPORT] {p.name} LIMB FITS: lowercase: {', '.join(rep.limbfits.lowercase_names)}")

    # Format combined output rows
    rows: List[str] = []
    for fr in sorted(reports, key=lambda x: x.stem.casefold()):
        rows.extend(format_file_report(fr, show_duplicates=args.duplicates, show_removed=args.fix))

    if not rows:
        print("No .SUM files in the direct folder contain lowercase-starting tokens in either block.")
    else:
        report_text = "\n".join(rows) + "\n"
        print(report_text, end="")
        if args.out:
            try:
                Path(args.out).write_text(report_text, encoding="utf-8")
                print(f"\nWrote report to: {args.out}")
            except OSError as e:
                print(f"[WARN] Could not write output file {args.out}: {e}")
                return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

