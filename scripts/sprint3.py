#!/usr/bin/env python3
import sys
import os
import pandas as pd
import numpy as np

# input is the csv passed from run_sprint3.sh

data = sys.argv[1]

#create output directory
out_dir = "out/evidence"
os.makedirs(out_dir, exist_ok = True)

#load csv
df = pd.read_csv(data)

#box score components to analyze
GAME_ID_COL = "gameId"
WIN_COL= "win"
COL_3PA  = "threePointersAttempted"
COL_3PCT = "threePointersPercentage"
COL_AST  = "assists"
COL_DREB = "reboundsDefensive"
COL_TOV  = "turnovers"
COL_FTA  = "freeThrowsAttempted"
COL_FGP  = "fieldGoalsPercentage"


#extract year from gamedatetime column:
DATE_COL = "gameDateTimeEst" 

# converts string column type to datetime type
df[DATE_COL] = pd.to_datetime(df[DATE_COL], errors = "coerce")

#extracts year number from datetime and create a new year column from datetime
df["year"] = df[DATE_COL].dt.year

# drop rows without year
df = df[df["year"].notna()].copy()

df["year"] = df["year"].astype(int) # converts year to int 

df["decade"] = (df["year"] // 10) * 10 #gets decade and creates decade column

df = df[df["decade"] >= 1980].copy() # only keeps decades after NBA merger

# creates list of decades ignoring NaN
decades = sorted(df["decade"].dropna().astype(int).unique().tolist())

#OUTPUT ONE: CORRELATION BY DECADE ANALYSIS
# computing correlation between win (0,1) and each box score component for every decade
#Pearson correlation is point biserial correlation

#list of stats (box score components) we are analyzing
# format is (label for output file, column in df)
stats = [("threePointersAttempted", COL_3PA), ("threePointersPercentage", COL_3PCT), ("assists", COL_AST), ("reboundsDefensive", COL_DREB), ("turnovers", COL_TOV), ("freeThrowsAttempted", COL_FTA), ("fieldGoalsPercentage", COL_FGP),]

correlation_rows = [] # list that the results will be appended to

#looping over each decade
for dec in decades:
    # filter dataframe to rows in this decade
    df_dec = df[df["decade"] == dec].copy()

    df_dec = df_dec[df_dec[WIN_COL].notna()] # remove rows where win is missing

    # loop over each stat in stats list (aka for each box score component)
    for label, col in stats:
        if col not in df_dec.columns:
            continue # skips past columns that don't exist

        # creates smaller dataframe consisting of two columns: the win column and
        # the current stat column. dropna() drops any rows with a missing value
        sub_frame = df_dec[[WIN_COL, col]].dropna()

        # computes correlation between win and this stat. takes into account linear
        # relationship between thw two variables and variability by standardizing
        # their relationship
        correlation = sub_frame[WIN_COL].corr(sub_frame[col])

        # each row appended is stored as a dictionary
        correlation_rows.append({
                "decade": int(dec), # which decade this row belongs to
                "stat":label, # easily readable label for output file
                "corr_win": correlation,# value of correlation 
                "sample_size": len(sub_frame) # number of rows used to calculate correlation, shows how reliable correlation is based on sampling size
        })
        
    # pd converts list of corr_rows into a table, and sort_values sorts the rows by
    # decade and then alphanetically for easy readability
    corr_df = pd.DataFrame(correlation_rows).sort_values(["decade", "stat"])

    #writes dataframe to a file under out/evidence using tab as dellimiter
    corr_df.to_csv(
        f"{out_dir}/correlation_by_decade.tsv",
        sep="\t",
        index=False,
        float_format="%.3f"
    )

#OUTPUT 2: computing average stats for winning and losing teams for each decade

cohort_stats = [
    ("threePointersAttempted", COL_3PA),
    ("threePointersPercentage", COL_3PCT),
    ("assists", COL_AST),
    ("reboundsDefensive", COL_DREB),
    ("turnovers", COL_TOV),
    ("freeThrowsAttempted", COL_FTA),
    ("fieldGoalsPercentage", COL_FGP),
]

cohort_rows = []

#looping through each decade 
for dec in decades:
    
    #only use this decade 
    df_dec = df[df["decade"] == dec].copy()

    #remove rows that don't have win
    df_dec = df_dec[df_dec[WIN_COL].notna()]

    # create two cohorts (win = 0 is lose, win = 1 is win)
    for val in [0,1]:

        #only keeping rows where win = val, aka allowing us to go through only 
        #wins or only losses once through each
        df_group = df_dec[df_dec[WIN_COL] == val]

        #builds one row in output
        row = { "decade": int(dec), "win": int(val) }

        # loop thru each stat to calculate the average
        for label, col in cohort_stats:

            #if column is missing, store NaN
            if col not in df_group.columns:
                row[label] = np/nan
                continue

            #calculate the mean while not including any missing values
            row[label] = df_group[col].dropna().mean()

        #add row
        cohort_rows.append(row)

#make a dataframe table out of the list
cohort_df = pd. DataFrame(cohort_rows)

#sort by decade
cohort_df = cohort_df.sort_values(["decade", "win"])

#save to tsv file
cohort_df.to_csv(
        f"{out_dir}/cohort_comparison_by_decade.tsv",
        sep="\t",
        index=False,
        float_format="%.3f"
)

#Output 3: assumption_tests.txt
#validates these assumptions:
# 1) win column must be binary 
# 2) no duplicate game rows
# 3) every row should have a decade

lines = []

#Assumption Test One - Win column is binary (0/1)
lines.append("Assumption Test 1: win column is binary (0,1)")

#counts the number of instances each value is in win column, including NaN
#values that are there
win_counts = df[WIN_COL].value_counts(dropna=False)

lines.append("win_value_counts:")
lines.append(win_counts.to_string())
lines.append("")

#gets unique non missing values
unique_vals = df[WIN_COL].dropna().unique().tolist()

#checkes whether each value is not 0 or 1
not_binary = []
for val in unique_vals:
    if val not in [0,1]:
        not_binary.append(val)

#if there are no unexpected values, then our assumption is true
lines.append(f"win_binary_ok={len(not_binary) == 0}")

#show any existing unexpeected values
if not_binary:
    lines.append(f"unexpected_win_values={not_binary}")

lines.append("")

#Assumption Test 2: check for duplicate game IDs
#there should only be 2 rows per game, one for each team. any games with 
#more than 2 rows are likely dplicates, any game with only 1 row might indicate
#missing data. we will check for these 2 scenarios
lines.append("Assumption test 2: duplicate game ID check")

if GAME_ID_COL not in df.columns:
    lines.append(f"ERROR: '{GAME_ID_COL}] column not found")
else:
    #count how many rows each game id appears in
    game_counts = df[GAME_ID_COL].value_counts()

    two_row_games = int((game_counts == 2).sum()) 
    one_row_games = int((game_counts == 1).sum())
    multiple_row_games = int((game_counts > 2).sum())

    lines.append(f"games_with_2_rows={two_row_games}")
    lines.append(f"games_with_only_1_row={one_row_games}")
    lines.append(f"games_with_more_than_2_rows={multiple_row_games}")

    if multiple_row_games > 0:
        lines.append("Some gameIds with more than 2 rows:")
        lines.append(game_counts[game_counts >2].head(5).to_string())

lines.append("")

#Assumption Test 3: every row with a valid date should have a year and decade
# we will check how many rows that are missing a year/decade
lines.append("Assumption Test 3: contains decade")

tot_rows = len(df) # count total number of rows in dataset

#counts how many rows do not have a valid year (sum counts true values)
missing_year = int(df["year"].isna().sum()) 

#counts how many rows do not have a valid decade 
missing_decade = int(df["decade"].isna().sum())

#writes results into lines
lines.append(f"total_rows={tot_rows}")
lines.append(f"rows_missing_year={missing_year}")
lines.append(f"rows_missing_decade={missing_decade}")

lines.append("")

#writes assumption tests into file
# "w" mode overwrites file instead of appending each run
with open(f"{out_dir}/assumption_tests.txt", "w") as f:
    f.write("\n".join(lines))

