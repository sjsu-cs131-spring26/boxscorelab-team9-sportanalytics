#!/usr/bin/env bash 

# ------------------------------------------------------------
# CS 131 – Sprint 3 Entry Script
#
# Usage:
#   ./scripts/run_sprint3.sh <DATASET_PATH> <DELIM>
#
# Example:
#   ./scripts/run_sprint3.sh data/TeamStatistics.csv ','
#
# Environment Requirements:
#   - Python 3.9+
#   - pandas
#   - numpy
#
# If running on IBM server:
#   eval "$(micromamba shell hook -s bash)"
#   micromamba activate cs131
#
# Outputs:
#   out/evidence/  (all evidence artifacts)
#   out/run_sprint3.log
#   out/errors.log
# ------------------------------------------------------------

set -euo pipefail

#always run from repo root
cd "$(dirname "$0")/.."


# Sprint 3 entry script
#How to run:
#from repo root:
#        chmod +x scripts/run_sprint3.sh
# 	./scripts/run_sprint3.sh data/TeamStatistics.csv


PY_SCRIPT="scripts/sprint3.py"


#dataset passed as argument $
# IE:
#   ./scripts/run_sprint3.sh data/TeamStatistics.csv
#   then $1 = data/TeamStatistics.csv1
if [[ $# -lt 2 ]]; then

	#if user did not input argument, print correct usage to stderr and exit
	echo "USage: $0 <DATASET_PATH>" >&2
	echo "Ex: $0 data/TeamStatistics.csv" >&2
	exit 1
fi

DATASET_PATH="$1"
DELIM="$2"

OUT_DIR="out"     # main output folder
EVID_DIR="${OUT_DIR}/evidence"    # evidence pack folder 
LOG="${OUT_DIR}/run_sprint3.log"  # run log 
ERR="${OUT_DIR}/errors.log"  # stderr log

mkdir -p "${EVID_DIR}"
: > "${LOG}" # clears logs each run so that it its reproducible 
: > "${ERR}"

echo "Sprint 3 evidence pack run" | tee -a "$LOG"
date | tee -a "$LOG"
echo "Dataset: $DATASET_PATH" | tee -a "$LOG"
echo "Delimiter: '$DELIM'" | tee -a "$LOG"
echo "" | tee -a "$LOG"


#ensures dataset path exists beforehand
if [[ ! -f "${DATASET_PATH}" ]]; then
  echo "ERROR: dataset not found at: ${DATASET_PATH}" >&2
  exit 2
fi

#validates python script exists
if [[ ! -f "${PY_SCRIPT}" ]]; then
  echo "ERROR: python script not found at: ${PY_SCRIPT}" >&2
  echo "Fix: check file name or  update PY_SCRIPT in run_sprint3.sh" >&2
  exit 3
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



# Main evidence
echo "Running Python evidence generator: $PY_SCRIPT" | tee -a "$LOG"
$(which python3) "$PY_SCRIPT" "$DATASET_PATH" 2> "$ERR" | tee -a "$LOG"

echo "" | tee -a "$LOG"

#ENG2's (Manuel for this sprint) artifacts
echo
echo "Running ENG2  artifacts..." | tee -a "$LOG"

if [[ -x "scripts/run_teamstats.sh" ]]; then
  ( bash scripts/run_teamstats.sh "$DATASET_PATH" "$DELIM" ) \
    2>>"$ERR" | tee -a "$LOG"
else
  echo "WARN: scripts/run_teamstats.sh not found or not executable" | tee -a "$LOG"
fi


echo "Done" | tee -a "$LOG"


date | tee -a "$LOG"
