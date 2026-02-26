# Project Overview: The Box Score Lab

## Team Members:
- Oliver Majano
- Blessing Cheng
- Manuel Rafanan
- Minn Naung

## Data Set:
[Historical NBA Data and Player Box Scores](https://www.kaggle.com/datasets/eoinamoore/historical-nba-data-and-player-box-scores/data)


The Historical NBA Data and Player Box Scores dataset contains game-level and player-level statistics from NBA history. It includes detailed player box scores (points, rebounds, assists, shooting stats, etc.), team performance data, and game metadata such as dates and matchups.

This dataset is well-suited for basketball analytics, trend analysis, data processing, and predictive modeling projects.

### Download Instructions
From the project root, run:

```bash
cd data
./download.sh
```

The script will download, extract, and clean up the dataset automatically.

---

## Sprint 2 – Definition of Done

- [ ] Data Card present in README  
- [ ] Dataset path verified using `ls -lh`, `wc -l`, `head`  
- [ ] 1,000-row sample created (header preserved)  
- [ ] ≥2 frequency tables generated and saved in `out/`  
- [ ] ≥1 Top-N list generated  
- [ ] ≥1 skinny table created and deduplicated  
- [ ] `grep -i` demonstrated  
- [ ] `grep -v` demonstrated  
- [ ] `tee` used at least once  
- [ ] stdout and stderr separated using `>` and `2>`  
- [ ] Full session captured using `script`  
- [ ] `run_project2.sh` runs end-to-end  
- [ ] Raw dataset excluded via `.gitignore`  
- [ ] Work done via branches → PR → review → merge  
- [ ] Sprint report completed with findings & limitations

## Sprint 2 Data Card

**Source**  
`TeamStatistics.csv` under [Historical NBA Data and Player Box Scores] Data Set. 
(https://www.kaggle.com/datasets/eoinamoore/historical-nba-data-and-player-box-scores?select=TeamStatisticsScoring.csv)

**Format**  
CSV, UTF-8 encoding, with a single header row.

**Size**  
- Full dataset: 24MB, ~145,000 rows, ~33 columns  
- Sample committed: 1,000 rows (`teamstats_1k.csv`)

**Delimiter & Header**  
- Delimiter: `,` (comma)  
- Header row present

**Fields (examples)**  
- gameDateTimeEst  
- teamName  
- opponentTeamName  
- home  
- win  
- threePointersMade  
- blocks  

**Quality Notes**  
Some columns contain missing values (empty fields), which required filtering during frequency table generation.
