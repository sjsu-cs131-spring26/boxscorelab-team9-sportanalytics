#!/bin/bash

#Create output directory
mkdir -p out

DATA="data/PlayerStatistics.csv"
SAMPLE="data/sample_10k.csv"

echo "Creating 10k-row sample of Player Stats..."
(head -n 1 "$DATA" && tail -n +2 "$DATA" | shuf -n 1000) > "$SAMPLE"

echo "Generating frequency table of Player teams..."
cut -d',' -f7 "$SAMPLE" | tail -n +2 | sort | uniq -c | sort -nr > out/freq_playerteam.txt

echo "Generating top 10 highest count from frequency table..."
head -n 10 out/freq_playerteam.txt > out/top10_playerteam.txt

echo "Generating skinny table including Id, playerteamName and points..."
cut -d',' -f3,7,16 "$SAMPLE" | tail -n +2 | sort -u > out/skinny_table.txt

echo "Project 2 run completed!!"
