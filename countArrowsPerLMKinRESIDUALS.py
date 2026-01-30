#!/usr/bin/env python3
"""countArrowsPerLMKinRESIDUALS.py

What this script does
---------------------
This script scans a RESIDUALS.TXT-style text file that is organized into repeated
"landmark blocks" delimited by dotted separator lines:

    ..................................................
    AJ0001 T      0.0600     72.5500    181.0406      9.7508
    ..................................................
        VO039B84              0.330    -1.001     1.054   0.02409
        ...
    AJ0001    114.28

Within each block, the *residual data rows* are the lines that contain an ID
(e.g., a picture/feature name) followed by four numeric columns. The value of
interest is the **right-most** numeric column on those rows.

This script **does not** use '>>' to detect interesting rows. It treats a
residual row as "interesting" if:

    (right_most_value >= --threshold)

It outputs one CSV row per landmark:

- landmark:       the landmark code (e.g., AJ0001)
- arrow_count:    number of residual rows in that landmark with last_value >= threshold
- total_rows:     number of residual rows considered for that landmark
- arrow_fraction: arrow_count / total_rows (0 if total_rows == 0)

Threshold is required
---------------------
There is no sensible default threshold across datasets, so --threshold is
REQUIRED. If you omit it, argparse will print usage and exit.

Warnings
--------
Warnings are printed (to stderr) only when a line *looks like* a residual data
row (ID + 4 columns) but the numeric parsing fails. Separator/header/trailer
lines are ignored silently.

Example
-------
    python countArrowsPerLMKinRESIDUALS.py --threshold 0.25 RESIDUALS.TXT output.csv

The output CSV begins with a comment recording the threshold:

    # threshold >= 0.25

"""

from __future__ import annotations

import argparse
import csv
import re
import warnings
from dataclasses import dataclass
from typing import Dict, Optional


DOTS_RE = re.compile(r"^\s*\.+\s*$")
LEGACY_PREFIX_RE = re.compile(r"^\s*>>\s*")  # allow legacy prefix, but do not rely on it


def is_dots_line(line: str) -> bool:
    """True if the line is a separator line made of dots."""
    return bool(DOTS_RE.match(line))


def strip_legacy_prefix(line: str) -> str:
    """Remove a leading '>>' marker if present and return the cleaned line."""
    return LEGACY_PREFIX_RE.sub("", line)


def try_parse_residual_last_value(line: str) -> Optional[float]:
    """Parse a residual row and return its right-most numeric value.

    A residual data row, after stripping optional '>>', should look like:

        <ID> <num> <num> <num> <num>

    i.e., **exactly 5 whitespace-separated tokens**, where the last 4 tokens are
    numeric. If the structure doesn't match, return None.

    We intentionally require exactly 5 tokens so we do NOT misinterpret:
    - landmark header rows (AJ0001 T ... ... ... ...)
    - trailer summary rows (AJ0001 114.28)
    - other bookkeeping lines
    """
    cleaned = strip_legacy_prefix(line).strip()
    if not cleaned:
        return None

    parts = cleaned.split()
    if len(parts) != 5:
        return None

    # parts[0] is the residual id; parts[1:5] should be numeric
    try:
        float(parts[1])
        float(parts[2])
        float(parts[3])
        return float(parts[4])
    except ValueError:
        return None


def looks_like_residual_row_but_bad(line: str) -> bool:
    """Heuristic: line has 5 tokens after stripping '>>' but doesn't parse numerically."""
    cleaned = strip_legacy_prefix(line).strip()
    if not cleaned:
        return False
    parts = cleaned.split()
    if len(parts) != 5:
        return False
    # If it isn't a header (token 2 == 'T') and still fails numeric parsing, warn.
    if len(parts) >= 2 and parts[1] == "T":
        return False
    return try_parse_residual_last_value(line) is None


def parse_landmark_from_header(line: str) -> Optional[str]:
    """Extract landmark name (first token) from a landmark header line."""
    s = line.strip()
    if not s:
        return None
    return s.split()[0]


@dataclass
class Counts:
    arrow_count: int = 0
    total_rows: int = 0

    def fraction(self) -> float:
        return (self.arrow_count / self.total_rows) if self.total_rows else 0.0


def scan_residuals_by_landmark(residuals_path: str, threshold: float) -> Dict[str, Counts]:
    """Scan RESIDUALS.TXT and compute counts per landmark.

    Parsing strategy (robust to spacing/blank lines)
    -----------------------------------------------
    We treat the file as a sequence of blocks:

      dots
      header line (landmark name is first token)   <-- NEVER threshold this
      dots
      residual rows (ID + 4 numeric columns)       <-- threshold right-most numeric value
      (optional trailer like 'AJ0001 114.28')
      dots   (starts next block)

    We DO NOT infer a landmark name from arbitrary lines (that is how 'VO250A68'
    accidentally became a landmark in your earlier run). We only set the current
    landmark from the header line that follows the first dots line of a block.
    """

    results: Dict[str, Counts] = {}

    expect_header = False
    waiting_for_row_separator = False
    in_rows = False
    current_landmark: Optional[str] = None

    def flush_current() -> None:
        nonlocal current_landmark, in_rows, waiting_for_row_separator
        if current_landmark is None:
            return
        # Ensure landmark exists even if it had zero residual rows.
        results.setdefault(current_landmark, Counts())
        current_landmark = None
        in_rows = False
        waiting_for_row_separator = False

    with open(residuals_path, "r", encoding="utf-8", errors="ignore") as f:
        for lineno, raw in enumerate(f, start=1):
            line = raw.rstrip("\n")

            if is_dots_line(line):
                if waiting_for_row_separator and current_landmark is not None:
                    # This is the SECOND dotted line in a block.
                    # It marks the beginning of the residual row section.
                    waiting_for_row_separator = False
                    in_rows = True
                    expect_header = False
                    continue

                if in_rows:
                    # A dotted line after we've been in rows marks the end of this block.
                    flush_current()
                    expect_header = True
                else:
                    # A dotted line outside rows starts (or restarts) header parsing.
                    expect_header = True
                continue

            # Ignore empty lines anywhere.
            if not line.strip():
                continue

            if expect_header:
                # The next non-empty, non-dots line is the header line.
                current_landmark = parse_landmark_from_header(line)
                if current_landmark is None:
                    # If somehow we can't parse, keep looking for a header.
                    continue
                results.setdefault(current_landmark, Counts())
                expect_header = False
                waiting_for_row_separator = True
                in_rows = False
                continue

            if waiting_for_row_separator:
                # We are between header and the second dots line. Ignore everything
                # until the dots line flips us into the row section.
                # (In well-formed files, only dots appears here.)
                continue

            # If we have no current landmark, we're outside a block; ignore.
            if current_landmark is None:
                continue

            # We are inside a block after the row separator, so interpret residual rows.
            in_rows = True

            v = try_parse_residual_last_value(line)
            if v is None:
                if looks_like_residual_row_but_bad(line):
                    warnings.warn(
                        f"[{residuals_path}:{lineno}] Skipping residual-like row with non-numeric values "
                        f"in landmark '{current_landmark}': {line!r}"
                    )
                # Non-residual lines (trailers, etc.) are ignored quietly.
                continue

            c = results[current_landmark]
            c.total_rows += 1
            if v >= threshold:
                c.arrow_count += 1

    # If file ended while still in a block, flush it.
    if current_landmark is not None:
        flush_current()

    return results


def write_csv(output_csv: str, results: Dict[str, Counts], threshold: float) -> None:
    """Write results CSV, including a first-line comment recording the threshold."""
    with open(output_csv, "w", newline="", encoding="utf-8") as f:
        f.write(f"# threshold >= {threshold}\n")
        writer = csv.writer(f)
        writer.writerow(["landmark", "arrow_count", "total_rows", "arrow_fraction"])
        for landmark in sorted(results.keys()):
            c = results[landmark]
            writer.writerow([landmark, c.arrow_count, c.total_rows, f"{c.fraction():.6f}"])


def build_arg_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description=(
            "Count, per landmark in RESIDUALS.TXT, how many residual rows have a right-most value >= threshold. "
            "Threshold is REQUIRED."
        )
    )
    p.add_argument("residuals_txt", help="Path to RESIDUALS.TXT")
    p.add_argument("output_csv", help="Path to write the output CSV")
    p.add_argument(
        "--threshold",
        type=float,
        required=True,
        help=(
            "REQUIRED. Flag a residual row when its right-most numeric column is >= this value. "
            "Example: --threshold 0.25"
        ),
    )
    return p


def main() -> None:
    args = build_arg_parser().parse_args()
    results = scan_residuals_by_landmark(args.residuals_txt, args.threshold)
    write_csv(args.output_csv, results, args.threshold)

    total_flagged = sum(c.arrow_count for c in results.values())
    total_rows = sum(c.total_rows for c in results.values())
    print(
        f"Done. Wrote {len(results)} landmark rows to {args.output_csv} "
        f"(threshold >= {args.threshold}). Flagged {total_flagged} of {total_rows} residual rows."
    )


if __name__ == "__main__":
    main()
