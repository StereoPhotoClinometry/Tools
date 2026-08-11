import csv
from pathlib import Path

# This script converts PICINFO.TXT and MAPINFO.TXT into clean CSV files.
# PICINFO:
#   - Handles files with or without headers, and with or without UTC fields.
#   - Merges multi-token CODE fields (e.g., "* c", "# * c", ">*# c", "# >b") into a single CODE value.
#   - Joins UTC fields into one column (e.g., "2005 JUL 04 04:43:42.448").
#   - Stops before the SIGcx block and skips all SIG lines.
#
# MAPINFO:
#   - Handles files with or without headers, stops at the END line.
#   - Supports optional "km" after RES.
#   - Extracts optional FLAG values (">>" or "**") preceding PXRSD.
#   - Outputs consistent columns: NAME, RES, LAT, WLON, RADIUS, #PIC, #OLAP,
#     #LIMB, UNC(M), PXRSD, FLAG, mxslp, dHT.
#
# Author: Carolyn Ernst
# Version: 1.0
# Last Modified: 2026-01-23


# ---------- PICINFO CONFIG ----------

HEADERS_PIC = [
    "PICNM",
    "UTC",
    "RES",
    "#LMK",
    "#LIM",
    "CODE",
    "PXRSD",
    "V0_RSD",
    "DELTA_V0CX",
    "DELTA_V0CY",
    "DELTA_V0CZ",
    "DELTA_CX",
    "DELTA_CY",
    "DELTA_CZ",
    "PHASE",
]

MONTH_NAMES = {
    "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC",
}

# ---------- PICINFO HELPERS ----------

def normalize_marker_code_tokens(tokens):
    """
    Merge patterns like:
       ['*','c']       -> ['*c']
       ['#','c']       -> ['#c']
       ['#','*','c']   -> ['#*c']
       ['#*','c']      -> ['#*c']
       ['>*#','c']     -> ['>*#c']
       ['#','>b']      -> ['#>b']
       ['#','>','b']   -> ['#>b']

    Rule: one or more tokens consisting ONLY of marker chars (*, >, ", #),
    followed by either:
      - a single alphabetic token (e.g., 'b'), OR
      - a token that is markers + one letter (e.g., '>b', '*c', '>*d'),
    become one CODE token.
    """
    markers = {"*", ">", '"', "#"}

    def is_marker_token(tok: str) -> bool:
        return tok != "" and all(ch in markers for ch in tok)

    def is_marker_plus_letter(tok: str) -> bool:
        # e.g. ">b", "*c", ">*d"  (all but last are markers, last is a letter)
        return (
            len(tok) >= 2
            and tok[-1].isalpha()
            and all(ch in markers for ch in tok[:-1])
        )

    out = []
    i = 0
    n = len(tokens)

    while i < n:
        tok = tokens[i]

        if is_marker_token(tok):
            combo = ""
            j = i

            # accumulate marker-only tokens
            while j < n and is_marker_token(tokens[j]):
                combo += tokens[j]
                j += 1

            # then require either:
            # (a) single-letter alpha token
            if j < n and len(tokens[j]) == 1 and tokens[j].isalpha():
                combo += tokens[j]
                out.append(combo)
                i = j + 1
                continue

            # (b) marker+letter token like ">b"
            if j < n and is_marker_plus_letter(tokens[j]):
                combo += tokens[j]
                out.append(combo)
                i = j + 1
                continue

            # can't merge; emit first marker token
            out.append(tok)
            i += 1
            continue

        # non-marker token, just pass through
        out.append(tok)
        i += 1

    return out


def detect_picinfo_has_utc(tokens):
    """True if any of tokens[1:5] is a month abbreviation."""
    return any(t.upper() in MONTH_NAMES for t in tokens[1:5])


def parse_picinfo_line_with_utc(tokens):
    """
    PICINFO WITH UTC:
      PICNM  YYYY MON DD HH:MM:SS.SSS  RES  [km]  #LMK  #LIM  CODE  PXRSD  V0_RSD  ...
    Assumes CODE has been normalized to a single token (#c, #>b, *c, #*c, etc.).
    """
    picnm = tokens[0]

    if len(tokens) < 6:
        utc = ""
        res = tokens[1] if len(tokens) > 1 else ""
        rest = tokens[2:]
    else:
        # This lumps the 4 UTC pieces into ONE column
        utc = " ".join(tokens[1:5])
        res = tokens[5]
        idx = 6
        # optional 'km'
        if idx < len(tokens) and tokens[idx].lower() == "km":
            idx += 1
        rest = tokens[idx:]

    lmk = rest[0] if len(rest) > 0 else ""
    lim = rest[1] if len(rest) > 1 else ""
    code = rest[2] if len(rest) > 2 else ""
    after = rest[3:] if len(rest) > 3 else []

    pxrsd  = after[0] if len(after) > 0 else ""
    v0_rsd = after[1] if len(after) > 1 else ""
    dv0cx  = after[2] if len(after) > 2 else ""
    dv0cy  = after[3] if len(after) > 3 else ""
    dv0cz  = after[4] if len(after) > 4 else ""
    dcx    = after[5] if len(after) > 5 else ""
    dcy    = after[6] if len(after) > 6 else ""
    dcz    = after[7] if len(after) > 7 else ""
    phase  = after[8] if len(after) > 8 else ""

    row = [
        picnm, utc, res, lmk, lim, code,
        pxrsd, v0_rsd, dv0cx, dv0cy, dv0cz,
        dcx, dcy, dcz, phase,
    ]

    if len(row) < len(HEADERS_PIC):
        row += [""] * (len(HEADERS_PIC) - len(row))
    return row


def parse_picinfo_line_without_utc(tokens):
    """
    PICINFO WITHOUT UTC:
      PICNM  RES  #LMK  #LIM  CODE  PXRSD  V0_RSD  DELTA_V0CX  ...
    Assumes CODE has been normalized.
    """
    picnm = tokens[0]
    utc = ""

    if len(tokens) >= 2:
        res = tokens[1]
        rest = tokens[2:]
    else:
        res = ""
        rest = []

    lmk = rest[0] if len(rest) > 0 else ""
    lim = rest[1] if len(rest) > 1 else ""
    code = rest[2] if len(rest) > 2 else ""
    after = rest[3:] if len(rest) > 3 else []

    pxrsd  = after[0] if len(after) > 0 else ""
    v0_rsd = after[1] if len(after) > 1 else ""
    dv0cx  = after[2] if len(after) > 2 else ""
    dv0cy  = after[3] if len(after) > 3 else ""
    dv0cz  = after[4] if len(after) > 4 else ""
    dcx    = after[5] if len(after) > 5 else ""
    dcy    = after[6] if len(after) > 6 else ""
    dcz    = after[7] if len(after) > 7 else ""
    phase  = after[8] if len(after) > 8 else ""

    row = [
        picnm, utc, res, lmk, lim, code,
        pxrsd, v0_rsd, dv0cx, dv0cy, dv0cz,
        dcx, dcy, dcz, phase,
    ]

    if len(row) < len(HEADERS_PIC):
        row += [""] * (len(HEADERS_PIC) - len(row))
    return row


def convert_picinfo_txt_to_csv(
    input_txt: Path = Path("PICINFO.TXT"),
    output_csv: Path = Path("PICINFO.csv"),
):
    if not input_txt.exists():
        print("[PICINFO] PICINFO.TXT not found, skipping.")
        return

    lines = input_txt.read_text(encoding="utf-8", errors="ignore").splitlines()

    # find first non-empty line
    i = 0
    while i < len(lines) and not lines[i].strip():
        i += 1
    if i >= len(lines):
        print("[PICINFO] File appears empty.")
        return

    first_line = lines[i].strip()
    first_fields = first_line.split()

    # header detection is based only on first token being PICNM
    has_header = bool(first_fields) and first_fields[0].upper() == "PICNM"
    data_start = i + 1 if has_header else i

    # detect UTC/non-UTC from first data line
    j = data_start
    while j < len(lines) and not lines[j].strip():
        j += 1
    if j >= len(lines):
        print("[PICINFO] No data rows found.")
        return

    test_tokens = normalize_marker_code_tokens(lines[j].split())
    has_utc = detect_picinfo_has_utc(test_tokens)
    print(f"[PICINFO] Detected format: {'WITH UTC' if has_utc else 'WITHOUT UTC'}")

    rows = []
    for line in lines[data_start:]:
        s = line.strip()
        if not s:
            continue

        # Stop at start of SIGcx block; ignore everything after
        if s.startswith("SIGcx") or s.startswith("SIGCX"):
            print("[PICINFO] Reached SIGcx block — stopping PICINFO parse.")
            break

        # Skip any other SIG lines
        if s.startswith("SIG"):
            continue

        tokens = normalize_marker_code_tokens(s.split())
        if not tokens:
            continue

        if has_utc:
            row = parse_picinfo_line_with_utc(tokens)
        else:
            row = parse_picinfo_line_without_utc(tokens)

        rows.append(row)

    with output_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(HEADERS_PIC)
        w.writerows(rows)

    print(f"[PICINFO] Wrote {len(rows)} rows → {output_csv}")


# ---------- MAPINFO CONFIG ----------

HEADERS_MAP = [
    "NAME",
    "RES",
    "LAT",
    "WLON",
    "RADIUS",
    "#PIC",
    "#OLAP",
    "#LIMB",
    "UNC(M)",
    "PXRSD",
    "FLAG",   # '>>' or '**'
    "mxslp",
    "dHT",
]

def parse_mapinfo_line_to_row(tokens):
    """
    MAPINFO line:
      NAME RES [km] LAT WLON RADIUS #PIC #OLAP #LIMB UNC(M) [FLAG] PXRSD [mxslp] [dHT]

    FLAG may be '>>' or '**'. If absent, FLAG is blank.
    """
    name = tokens[0]
    res  = tokens[1]

    idx = 2
    # Optional 'km' after RES
    if idx < len(tokens) and tokens[idx].lower() == "km":
        idx += 1

    # LAT, WLON, RADIUS, #PIC, #OLAP, #LIMB, UNC(M)
    needed = 7
    if len(tokens) - idx < needed:
        lat    = tokens[idx]     if idx     < len(tokens) else ""
        wlon   = tokens[idx + 1] if idx + 1 < len(tokens) else ""
        radius = tokens[idx + 2] if idx + 2 < len(tokens) else ""
        pic    = tokens[idx + 3] if idx + 3 < len(tokens) else ""
        olap   = tokens[idx + 4] if idx + 4 < len(tokens) else ""
        limb   = tokens[idx + 5] if idx + 5 < len(tokens) else ""
        unc    = tokens[idx + 6] if idx + 6 < len(tokens) else ""
        rem = []
    else:
        lat    = tokens[idx]
        wlon   = tokens[idx + 1]
        radius = tokens[idx + 2]
        pic    = tokens[idx + 3]
        olap   = tokens[idx + 4]
        limb   = tokens[idx + 5]
        unc    = tokens[idx + 6]
        rem    = tokens[idx + 7 :]

    flag = ""
    px = ""
    mxslp = ""
    dht = ""

    # FLAG can be '>>' or '**' immediately before PXRSD
    if rem and rem[0] in {">>", "**"}:
        flag = rem[0]
        rem = rem[1:]

    # Now rem (if any) is [PXRSD, mxslp, dHT] in that order
    if len(rem) > 0:
        px = rem[0]
    if len(rem) > 1:
        mxslp = rem[1]
    if len(rem) > 2:
        dht = rem[2]

    return [
        name, res, lat, wlon, radius,
        pic, olap, limb, unc,
        px, flag, mxslp, dht,
    ]


def convert_mapinfo_txt_to_csv(
    input_txt: Path = Path("MAPINFO.TXT"),
    output_csv: Path = Path("MAPINFO.csv"),
):
    if not input_txt.exists():
        print("[MAPINFO] MAPINFO.TXT not found, skipping.")
        return

    lines = input_txt.read_text(encoding="utf-8", errors="ignore").splitlines()

    # Find first non-empty line
    i = 0
    while i < len(lines) and not lines[i].strip():
        i += 1
    if i >= len(lines):
        print("[MAPINFO] File appears empty.")
        return

    first_line = lines[i].strip()
    first_fields = first_line.split()
    has_header = bool(first_fields) and first_fields[0].upper() == "NAME"

    if has_header:
        print("[MAPINFO] Detected header row; will replace with canonical headers.")
        data_start = i + 1
    else:
        print("[MAPINFO] No header row detected; using canonical headers.")
        data_start = i

    rows = []
    for line in lines[data_start:]:
        s = line.strip()
        if not s:
            continue
        # Stop at END line; ignore anything after
        if s.startswith("END"):
            break

        tokens = s.split()
        if not tokens:
            continue

        row = parse_mapinfo_line_to_row(tokens)
        rows.append(row)

    with output_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(HEADERS_MAP)
        w.writerows(rows)

    print(f"[MAPINFO] Wrote {len(rows)} rows → {output_csv}")


# ---------- MAIN ----------

def main():
    convert_picinfo_txt_to_csv()
    convert_mapinfo_txt_to_csv()

if __name__ == "__main__":
    main()

