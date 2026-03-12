#!/usr/bin/env bash
set -euo pipefail

#run from repo root
cd "$(dirname "$0")/.."

# CS 131 Project, Sprint 3
# Entry script to generate selected evidence artifacts for TeamStatistics.csv.

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <DATASET_PATH> <DELIM>" >&2
  exit 1
fi

DATASET_PATH="$1"
DELIM="$2"

OUT_DIR="out"
EVID_DIR="${OUT_DIR}/evidence"
LOG="${OUT_DIR}/run_teamstats.log"
ERR="${OUT_DIR}/errors.log"

mkdir -p "${EVID_DIR}"
: > "${LOG}"
: > "${ERR}"

exec > >(tee -a "${LOG}") 2> >(tee -a "${ERR}" >&2)

echo "Team statistics evidence pack run"
date
echo "Dataset: ${DATASET_PATH}"
echo "Delimiter: '${DELIM}'"
echo

if [[ ! -f "${DATASET_PATH}" ]]; then
  echo "ERROR: dataset not found at: ${DATASET_PATH}" >&2
  exit 2
fi

echo "File size"
ls -lh "${DATASET_PATH}" | tee "${EVID_DIR}/file_size.txt"
echo

echo "Header preview"
head -n 3 "${DATASET_PATH}" | tee "${EVID_DIR}/header_preview.txt"
echo

echo "Row count"
wc -l "${DATASET_PATH}" | tee "${EVID_DIR}/row_count.txt"
echo

# -----------------------------
# ARTIFACT 1
# Three-point trend analysis
# 1980s to current only
# -----------------------------

echo "Generating three_point_trend_analysis.txt"

python3 - "${DATASET_PATH}" "${EVID_DIR}/three_point_trend_analysis.txt" <<'PY'

# Import libraries needed for reading CSV data and performing calculations
import csv
import math
import sys
from collections import defaultdict

# Read arguments passed from the shell script
# sys.argv[1] = dataset path
# sys.argv[2] = output file path
dataset_path = sys.argv[1]
output_path = sys.argv[2]

# Dictionary that groups rows by decade
# Example structure:
# decades[1990] = [(3PA,3PM,win), (3PA,3PM,win), ...]
decades = defaultdict(list)

# Open the dataset and read it row by row
with open(dataset_path, newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        try:
            # Extract the year from the timestamp
            year = int(row["gameDateTimeEst"][:4])

            # Only analyze data from the 1980s onward
            if year < 1980:
                continue

            # Convert the year to its decade (1993 -> 1990)
            decade = (year // 10) * 10

            # Read the three-point statistics
            three_pa = float(row["threePointersAttempted"])
            three_pm = float(row["threePointersMade"])

            # Read the win column (1 = win, 0 = loss)
            win = int(row["win"])

            # Store this record in the correct decade bucket
            decades[decade].append((three_pa, three_pm, win))

        # Skip rows with bad or missing values
        except:
            continue


# Function to compute the average of a list
def mean(vals):
    return sum(vals) / len(vals) if vals else 0.0


# Function to compute correlation between two variables
# Used here to measure how strongly 3PM relates to winning
def corr(x, y):

    if len(x) < 2:
        return float("nan")

    mx = mean(x)
    my = mean(y)

    num = sum((a - mx) * (b - my) for a, b in zip(x, y))
    denx = math.sqrt(sum((a - mx) ** 2 for a in x))
    deny = math.sqrt(sum((b - my) ** 2 for b in y))

    if denx == 0 or deny == 0:
        return float("nan")

    return num / (denx * deny)


# Function that finds the 75th percentile
# Used to determine the cutoff for the top quartile of 3PM games
def q3(vals):

    if not vals:
        return float("nan")

    vals = sorted(vals)

    i = 0.75 * (len(vals) - 1)
    lo = math.floor(i)
    hi = math.ceil(i)

    if lo == hi:
        return vals[int(i)]

    return vals[lo] + (vals[hi] - vals[lo]) * (i - lo)


# Combine all rows across decades
all_rows = []
for decade in decades:
    all_rows.extend(decades[decade])


# Open the output file where the analysis will be written
with open(output_path, "w") as out:

    out.write("THREE-POINT TREND ANALYSIS (1980s TO CURRENT)\n")
    out.write("============================================\n\n")

    # Extract 3PM and win values across all decades
    all_pm = [r[1] for r in all_rows]
    all_win = [r[2] for r in all_rows]

    # Calculate correlation between 3PM and winning
    overall = corr(all_pm, all_win)

    out.write("Overall 3PM-to-win correlation\n")

    if not math.isnan(overall):
        out.write(f"overall_3pm_win_corr={overall:.4f}\n\n")
    else:
        out.write("overall_3pm_win_corr=NA\n\n")


    # Calculate average three-point attempts per game by decade
    out.write("3PA/game by decade\n")

    for decade in sorted(decades):
        avg_3pa = mean([r[0] for r in decades[decade]])
        out.write(f"{decade}s\t{avg_3pa:.2f}\n")

    out.write("\n")


    # Calculate correlation between 3PM and winning for each decade
    out.write("3PM correlation with winning by decade\n")

    for decade in sorted(decades):

        pm = [r[1] for r in decades[decade]]
        wins = [r[2] for r in decades[decade]]

        value = corr(pm, wins)

        if not math.isnan(value):
            out.write(f"{decade}s\t{value:.4f}\n")
        else:
            out.write(f"{decade}s\tNA\n")

    out.write("\n")


    # Determine win percentage for games in the top quartile of 3PM
    out.write("Top-quartile 3PM win% by decade\n")

    for decade in sorted(decades):

        pm = [r[1] for r in decades[decade]]

        cutoff = q3(pm)

        # Select games where 3PM >= 75th percentile
        top = [r for r in decades[decade] if r[1] >= cutoff]

        win_pct = 100 * mean([r[2] for r in top]) if top else 0.0

        out.write(f"{decade}s\tthreshold_3PM>={cutoff:.2f}\twin_pct={win_pct:.2f}\tn={len(top)}\n")


# Print the result to the terminal
with open(output_path) as f:
    print(f.read(), end="")
PY

# -----------------------------
# TRUST CHECK
# Missingness by decade
# 1980s to current only
# -----------------------------

echo "Generating trust_check_missing_stats_by_decade.txt"

python3 - "${DATASET_PATH}" "${EVID_DIR}/trust_check_missing_stats_by_decade.txt" <<'PY'

# Import libraries for CSV reading and grouping data
import csv
import sys
from collections import defaultdict

# Get arguments passed from the shell script
dataset_path = sys.argv[1]
output_path = sys.argv[2]

# Count how many rows exist per decade
decade_counts = defaultdict(int)

# Track missing values per statistic per decade
missing = defaultdict(lambda: defaultdict(int))

# Columns we want to check for missing data
columns = [
    "blocks",
    "steals",
    "turnovers",
    "threePointersMade"
]

# Read the dataset
with open(dataset_path, newline="") as f:
    reader = csv.DictReader(f)

    for row in reader:

        try:
            # Extract the year
            year = int(row["gameDateTimeEst"][:4])

            # Ignore rows before 1980
            if year < 1980:
                continue

            decade = (year // 10) * 10

        except:
            continue

        # Count total rows in each decade
        decade_counts[decade] += 1

        # Check each statistic for missing values
        for col in columns:

            val = row.get(col, "").strip().lower()

            # Treat these values as missing
            if val in {"", "na", "n/a", "null", "none"}:
                missing[decade][col] += 1


# Write the results to the output file
with open(output_path, "w") as out:

    out.write("TRUST CHECK: MISSINGNESS SUMMARY BY DECADE (1980s TO CURRENT)\n")
    out.write("============================================================\n\n")

    out.write("decade\trows\tblocks_missing\tsteals_missing\tturnovers_missing\tthreePM_missing\n")

    # Print the counts for each decade
    for decade in sorted(decade_counts):

        out.write(
            f"{decade}s\t{decade_counts[decade]}\t"
            f"{missing[decade]['blocks']}\t"
            f"{missing[decade]['steals']}\t"
            f"{missing[decade]['turnovers']}\t"
            f"{missing[decade]['threePointersMade']}\n"
        )


# Print the results to the terminal
with open(output_path) as f:
    print(f.read(), end="")
PY
