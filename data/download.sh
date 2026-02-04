#!/bin/bash
# Download Historical NBA Data and Player Box Scores dataset
# Run this script from the data directory: ./download.sh

echo "Downloading Historical NBA Data and Player Box Scores..."
curl -L -o historical-nba-data-and-player-box-scores.zip \
  https://www.kaggle.com/api/v1/datasets/download/eoinamoore/historical-nba-data-and-player-box-scores

if [ $? -eq 0 ]; then
    echo "Download complete!"
    echo "Unzipping files..."
    unzip -q historical-nba-data-and-player-box-scores.zip
    if [ $? -eq 0 ]; then
        echo "Extraction complete!"
        echo "Cleaning up zip file..."
        rm historical-nba-data-and-player-box-scores.zip
        echo "Done! Dataset files are ready in the data directory."
    else
        echo "Error: Failed to extract the zip file."
        exit 1
    fi
else
    echo "Error: Download failed."
    exit 1
fi
