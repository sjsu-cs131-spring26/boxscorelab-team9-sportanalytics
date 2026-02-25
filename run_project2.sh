#!/bin/bash

DATA="data/PlayerStatistics.csv"
SAMPLE="data/sample_playerstats_10k.csv"
OUTDIR="out/playerstats"

mkdir -p "$OUTDIR"

echo "Creating 10k-row sample of Player Stats..."
(head -n 1 "$DATA" && tail -n +2 "$DATA" | shuf -n 10000) > "$SAMPLE"

echo "Generating frequency table of Player teams..."
cut -d',' -f7 "$SAMPLE" | tail -n +2 | sort | uniq -c | sort -nr > "$OUTDIR/freq_playerteam.txt"

echo "Generating top 10 highest count from frequency table..."
head -n 10 "$OUTDIR/freq_playerteam.txt" > "$OUTDIR/top10_playerteam.txt"

echo "Generating skinny table including Id, playerteamName and points..."
cut -d',' -f3,7,16 "$SAMPLE" | tail -n +2 | sort -u > "$OUTDIR/skinny_playerstats.txt"

echo "PlayerStatistics automation completed!!"
