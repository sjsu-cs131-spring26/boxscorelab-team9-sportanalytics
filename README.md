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


## Cloud Pipeline (Final Sprint)

### How to Run

**1. Upload data to GCS:**
```bash
gcloud storage cp data/TeamStatistics.csv gs://hw8-cs131-omajano-1845-bkt/data/TeamStatistics.csv
```

**2. Create a Dataproc cluster:**
```bash
gcloud dataproc clusters create nba-spark-cluster \
    --region=us-west1 \
    --zone=us-west1-b \
    --master-machine-type=e2-standard-2 \
    --num-workers=2 \
    --worker-machine-type=e2-standard-2 \
    --image-version=2.1-debian11 \
    --enable-component-gateway \
    --project=hw8-cs131-omajano-1845
```

**3. Submit the PySpark job:**
```bash
gcloud dataproc jobs submit pyspark \
    gs://hw8-cs131-omajano-1845-bkt/code/cloud_pyspark_job.py \
    --cluster=nba-spark-cluster \
    --region=us-west1
```

**4. Delete the cluster when done:**
```bash
gcloud dataproc clusters delete nba-spark-cluster --region=us-west1 --quiet
```

### Where Data Lives

| What | Location |
|------|----------|
| Input CSV | `gs://hw8-cs131-omajano-1845-bkt/data/TeamStatistics.csv` |
| PySpark job script | `gs://hw8-cs131-omajano-1845-bkt/code/cloud_pyspark_job.py` |
| Output (Parquet) | `gs://hw8-cs131-omajano-1845-bkt/output/nba_3pt_evolution/` |

### Output Tables (Parquet)

- `decade_summary/` — 3PT stats aggregated by decade
- `season_trends/` — Season-level trends with YoY delta and cumulative averages
- `era_comparison/` — Pre-Analytics (1980-2014) vs Analytics Era (2015-2026)
- `top_teams_by_decade/` — Top 5 teams by 3PA per decade (partitioned by decade)
- `scoring_composition/` — Points from 2PT, 3PT, and free throws by decade

### Project Files

| File | Description |
|------|-------------|
| `scripts/cloud_pyspark_job.py` | Standalone PySpark job for Dataproc |
| `notebooks/NBA_Viz_Cloud.ipynb` | Visualization notebook (runs on cluster via Jupyter) |

## Environment Requirements

- Python 3.9+
- PySpark 3.3+
- pandas, numpy, matplotlib

```bash
pip install -r requirements.txt
```

---

## Sprint 2 – Definition of Done

- [x] Data Card present in README  
- [x] Dataset path verified using `ls -lh`, `wc -l`, `head`  
- [x] 1,000-row sample created (header preserved)  
- [x] ≥2 frequency tables generated and saved in `out/`  
- [x] ≥1 Top-N list generated  
- [x] ≥1 skinny table created and deduplicated  
- [x] `grep -i` demonstrated  
- [x] `grep -v` demonstrated  
- [x] `tee` used at least once  
- [x] stdout and stderr separated using `>` and `2>`  
- [x] Full session captured using `script`  
- [x] `run_project2.sh` runs end-to-end  
- [x] Raw dataset excluded via `.gitignore`  
- [x] Work done via branches → PR → review → merge  
- [x] Sprint report completed with findings & limitations

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
