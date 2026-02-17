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

## Data Card

| File Name                 | Size | Row Count    | Delimiter   | Header |
| :------------------------ | :--- | :----------- | :---------- | :----- |
| `Games.csv`               | 9.2M | 72,704       | Comma (`,`) | Yes    |
| `LeagueSchedule24_25.csv` | 144K | 1,409        | Comma (`,`) | Yes    |
| `LeagueSchedule25_26.csv` | 159K | 1,320        | Comma (`,`) | Yes    |
| `Players.csv`             | 361K | 6,682        | Comma (`,`) | Yes    |
| `PlayerStatistics.csv`    | 305M | 1,649,713    | Comma (`,`) | Yes    |
| `TeamHistories.csv`       | 6.8K | 141          | Comma (`,`) | Yes    |
| `TeamStatistics.csv`      | 24M  | 145,410      | Comma (`,`) | Yes    |
| `PlayByPlay.parquet`      | 788M | N/A (Binary) | N/A         | N/A    |

---

## Sprint 2 – Definition of Done

- [x] Data Card present in README
- [x] Dataset path verified using `ls -lh`, `wc -l`, `head`
- [ ] 1,000-row sample created (header preserved)
- [ ] ≥2 frequency tables generated and saved in `out/`
  - [x] Frequency table #1: `out/freq_hometeamCity.txt`
- [x] ≥1 Top-N list generated
  - [x] Top 10 list: `out/top10_hometeamCity.txt`
- [ ] ≥1 skinny table created and deduplicated
- [x] `grep -i` demonstrated
  - [x] Case-insensitive search: `out/grep_case_insensitive.txt`
- [x] `grep -v` demonstrated
  - [x] Exclusion search: `out/grep_exclude.txt`
- [ ] `tee` used at least once
- [ ] stdout and stderr separated using `>` and `2>`
- [x] Full session captured using `script`
- [ ] `run_project2.sh` runs end-to-end
- [ ] Raw dataset excluded via `.gitignore`
- [ ] Work done via branches → PR → review → merge
- [ ] Sprint report completed with findings & limitations
