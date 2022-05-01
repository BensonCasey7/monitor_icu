#!/bin/sh

rm -r ./data/
mkdir data

python3 preprocess/split_data.py
python3 preprocess/aggregation.py
