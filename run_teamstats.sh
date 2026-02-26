#!/bin/bash

# CHANGE THIS to your actual team stats file name in data/
DATA="data/TeamStatistics.csv"

SAMPLE="data/sample_teamstats_10k.csv"
OUTDIR="out/teams"

mkdir -p "$OUTDIR"

echo "Creating 10k-row sample of Team Stats..."
(head -n 1 "$DATA" && tail -n +2 "$DATA" | shuf -n 10000) > "$SAMPLE"

echo "Generating frequency table for home (0/1)..."
cut -d',' -f9 "$SAMPLE" | tail -n +2 | sort | uniq -c | sort -nr > "$OUTDIR/freq_home.txt"

echo "Generating Top 10 opponent teams..."
cut -d',' -f7 "$SAMPLE" | tail -n +2 | sort | uniq -c | sort -nr | head -n 10 > "$OUTDIR/top10_opponentteam.txt"

echo "Generating skinny 3PT table (teamName, 3PA, 3PM) and removing blanks..."
cut -d',' -f4,19,20 "$SAMPLE" | tail -n +2 | grep -v ",," | sort -u > "$OUTDIR/skinny_3pt.txt"

echo "TeamStats automation completed!"
