#!/usr/bin/env python3
"""
analyze_images_stats.py

Usage:
    python analyze_images_stats.py input.csv

Behavior:
- Reads a CSV where column 0 contains image names.
- Splits rows into:
      Viking        → image name begins with V/v
      HRSC Framing  → image name begins with H/h

- For every other column (index >= 1):
      * Warns if there are non-numeric values.
      * Computes descriptive statistics for Viking and HRSC separately:
           count, mean, std, min, 25%, 50%, 75%, max,
           median, RSD, RMS,
           lower_outlier_threshold, upper_outlier_threshold,
           min_image, max_image, outlier_images (semicolon-separated).
      * Outliers defined by IQR rule:
           value < Q1 - 1.5*IQR  OR  value > Q3 + 1.5*IQR
      * Each outlier gets an outlier_score in IQR units:
           distance beyond nearest quartile / IQR
      * Produces histograms for each group+column:
           - full data
           - with outliers removed

- Outputs:
      <base>_viking_stats.csv
      <base>_hrsc_stats.csv
      <base>_outliers.csv           (one row per outlier, sorted by outlier_score desc)
      <base>_outlier_images.csv     (one row per image, max outlier_score, sorted desc)
      histograms in <base>_histograms/
"""

import sys
import os
from typing import Tuple, Dict, Any, List

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


# ----------------------------------------------------------------------
# Warn if any non-numeric values appear in a data column
# ----------------------------------------------------------------------
def warn_if_non_numeric(series: pd.Series, col_name: str) -> None:
    coerced = pd.to_numeric(series, errors="coerce")
    bad_mask = coerced.isna() & series.notna()

    if bad_mask.any():
        bad_values = series[bad_mask]
        print(f"\nWARNING: Non-numeric values detected in column '{col_name}'")
        print(f"  Count: {bad_mask.sum()}")
        print(f"  Sample: {bad_values.unique()[:5]}\n")


# ----------------------------------------------------------------------
# Extended statistics per column + outlier detection
# ----------------------------------------------------------------------
def extended_stats(values: pd.Series,
                   image_names: pd.Series,
                   col_name: str,
                   group_name: str) -> Tuple[pd.Series, pd.DataFrame]:
    """
    Compute descriptive stats for one numeric column and one group.

    Returns:
        stats: pd.Series
        outliers_df: DataFrame with columns:
            group, column, image_name, value,
            lower_threshold, upper_threshold, outlier_score
    """
    vals = pd.to_numeric(values, errors="coerce")
    mask = vals.notna()
    vals = vals[mask]
    names = image_names[mask].astype(str)

    if len(vals) == 0:
        empty_stats = pd.Series(dtype=float)
        empty_outliers = pd.DataFrame(columns=[
            "group", "column", "image_name", "value",
            "lower_threshold", "upper_threshold", "outlier_score"
        ])
        return empty_stats, empty_outliers

    # Basic descriptive stats
    desc = vals.describe()  # count, mean, std, min, 25%, 50%, 75%, max

    mean = desc.get("mean", np.nan)
    std = desc.get("std", np.nan)

    # RSD
    if mean != 0 and not np.isnan(mean):
        rsd = std / abs(mean)
    else:
        rsd = np.nan

    # RMS
    rms = np.sqrt(np.mean(vals.values ** 2))

    desc["median"] = desc.get("50%", np.nan)
    desc["RSD"] = rsd
    desc["RMS"] = rms

    # min/max image names
    min_image = names.loc[vals.idxmin()]
    max_image = names.loc[vals.idxmax()]
    desc["min_image"] = min_image
    desc["max_image"] = max_image

    # IQR thresholds
    q1 = desc.get("25%", np.nan)
    q3 = desc.get("75%", np.nan)
    iqr = q3 - q1

    if iqr > 0 and not np.isnan(iqr):
        lower = q1 - 1.5 * iqr
        upper = q3 + 1.5 * iqr
    else:
        lower = np.nan
        upper = np.nan

    desc["lower_outlier_threshold"] = lower
    desc["upper_outlier_threshold"] = upper

    # Outliers
    outlier_rows = []
    if not np.isnan(lower) and not np.isnan(upper):
        mask_out = (vals < lower) | (vals > upper)
        out_vals = vals[mask_out]
        out_names = names[mask_out]
        desc["outlier_images"] = ";".join(out_names.unique())

        for idx, val in out_vals.items():
            # outlier_score: distance from nearest quartile in IQR units
            if val < q1:
                score = (q1 - val) / iqr
            elif val > q3:
                score = (val - q3) / iqr
            else:
                score = 0.0  # shouldn't happen given the mask

            outlier_rows.append({
                "group": group_name,
                "column": col_name,
                "image_name": names.loc[idx],
                "value": float(val),
                "lower_threshold": float(lower),
                "upper_threshold": float(upper),
                "outlier_score": float(score),
            })
    else:
        desc["outlier_images"] = ""

    outliers_df = pd.DataFrame(
        outlier_rows,
        columns=[
            "group", "column", "image_name", "value",
            "lower_threshold", "upper_threshold", "outlier_score"
        ]
    )

    return desc, outliers_df


# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------
def main(csv_path: str) -> None:
    if not os.path.isfile(csv_path):
        print("ERROR: Input file not found.")
        sys.exit(1)

    df = pd.read_csv(csv_path)
    if df.shape[1] < 2:
        print("ERROR: CSV must have >= 2 columns (image name + data).")
        sys.exit(1)

    image_col = df.columns[0]

    # Split into Viking and HRSC Framing
    first = df[image_col].astype(str).str[:1].str.upper()
    viking_df = df[first == "V"].copy()
    hrsc_df   = df[first == "H"].copy()

    print(f"Total rows:   {len(df)}")
    print(f"Viking rows:  {len(viking_df)}")
    print(f"HRSC rows:    {len(hrsc_df)}")

    basename = os.path.splitext(os.path.basename(csv_path))[0]
    hist_dir = f"{basename}_histograms"
    os.makedirs(hist_dir, exist_ok=True)

    viking_stats: Dict[str, pd.Series] = {}
    hrsc_stats: Dict[str, pd.Series] = {}
    outlier_rows: List[Dict[str, Any]] = []

    # Process each data column
    for col in df.columns[1:]:
        warn_if_non_numeric(df[col], col)

        # Viking stats
        vik_stats, vik_out = extended_stats(
            viking_df[col], viking_df[image_col], col, "Viking"
        )
        viking_stats[col] = vik_stats
        outlier_rows.extend(vik_out.to_dict("records"))

        # HRSC stats
        hrs_stats, hrs_out = extended_stats(
            hrsc_df[col], hrsc_df[image_col], col, "HRSC Framing"
        )
        hrsc_stats[col] = hrs_stats
        outlier_rows.extend(hrs_out.to_dict("records"))

        # Histograms
        vik_vals = pd.to_numeric(viking_df[col], errors="coerce").dropna()
        hrs_vals = pd.to_numeric(hrsc_df[col], errors="coerce").dropna()

        vik_lower = vik_stats.get("lower_outlier_threshold", np.nan)
        vik_upper = vik_stats.get("upper_outlier_threshold", np.nan)
        hrs_lower = hrs_stats.get("lower_outlier_threshold", np.nan)
        hrs_upper = hrs_stats.get("upper_outlier_threshold", np.nan)

        # --- Viking full ---
        if len(vik_vals) > 0:
            plt.figure()
            vik_vals.hist(bins=30)
            plt.title(f"{col} (Viking)")
            plt.xlabel(col)
            plt.ylabel("Frequency")
            plt.tight_layout()
            plt.savefig(os.path.join(hist_dir, f"{basename}_viking_{col}.png"))
            plt.close()

            # Viking no-outliers
            if not np.isnan(vik_lower) and not np.isnan(vik_upper):
                vik_no = vik_vals[(vik_vals >= vik_lower) & (vik_vals <= vik_upper)]
                if len(vik_no) > 0:
                    plt.figure()
                    vik_no.hist(bins=30)
                    plt.title(f"{col} (Viking, no outliers)")
                    plt.xlabel(col)
                    plt.ylabel("Frequency")
                    plt.tight_layout()
                    plt.savefig(os.path.join(hist_dir, f"{basename}_viking_{col}_no_outliers.png"))
                    plt.close()

        # --- HRSC full ---
        if len(hrs_vals) > 0:
            plt.figure()
            hrs_vals.hist(bins=30)
            plt.title(f"{col} (HRSC Framing)")
            plt.xlabel(col)
            plt.ylabel("Frequency")
            plt.tight_layout()
            plt.savefig(os.path.join(hist_dir, f"{basename}_hrsc_{col}.png"))
            plt.close()

            # HRSC no-outliers
            if not np.isnan(hrs_lower) and not np.isnan(hrs_upper):
                hrs_no = hrs_vals[(hrs_vals >= hrs_lower) & (hrs_vals <= hrs_upper)]
                if len(hrs_no) > 0:
                    plt.figure()
                    hrs_no.hist(bins=30)
                    plt.title(f"{col} (HRSC Framing, no outliers)")
                    plt.xlabel(col)
                    plt.ylabel("Frequency")
                    plt.tight_layout()
                    plt.savefig(os.path.join(hist_dir, f"{basename}_hrsc_{col}_no_outliers.png"))
                    plt.close()

    # Stats tables
    viking_out = pd.DataFrame(viking_stats).T
    hrsc_out   = pd.DataFrame(hrsc_stats).T

    viking_stats_path = f"{basename}_viking_stats.csv"
    hrsc_stats_path   = f"{basename}_hrsc_stats.csv"

    viking_out.to_csv(viking_stats_path)
    hrsc_out.to_csv(hrsc_stats_path)

    print(f"\nViking stats saved to: {viking_stats_path}")
    print(f"HRSC stats saved to:   {hrsc_stats_path}")

    # Outliers (one row per outlier), with sorting by outlier_score
    outliers_csv_path = f"{basename}_outliers.csv"
    if outlier_rows:
        outliers_df = pd.DataFrame(outlier_rows)

        # sort from most extreme to least extreme
        outliers_df = outliers_df.sort_values("outlier_score", ascending=False)
        outliers_df.to_csv(outliers_csv_path, index=False)
        print(f"Outliers saved to:     {outliers_csv_path}")

        # Unique images with max outlier_score (image-level summary)
        image_scores = (
            outliers_df.groupby("image_name", as_index=False)["outlier_score"]
            .max()
            .rename(columns={"outlier_score": "max_outlier_score"})
            .sort_values("max_outlier_score", ascending=False)
        )

        outlier_images_path = f"{basename}_outlier_images.csv"
        image_scores.to_csv(outlier_images_path, index=False)
        print(f"Unique outlier images saved to: {outlier_images_path}")
    else:
        print("No outliers detected by IQR rule; outlier CSVs not created.")

    print(f"Histograms saved to:   {hist_dir}\n")


# ----------------------------------------------------------------------
# CLI
# ----------------------------------------------------------------------
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python analyze_images_stats.py input.csv")
        sys.exit(1)

    main(sys.argv[1])