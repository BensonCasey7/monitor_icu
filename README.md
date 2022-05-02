# Monitoring ICU Mortality Risk with A Long Short-Term Memory Recurrent Neural Network

This is a project to reproduce the authors' claims in the paper mentioned above. We will be implementing techniques such as Latent Semantic Analysis, 
Self-attention, Long Short Term Memory, bi-LSTM, Average pooling, SAPS-II as mentioned in the paper.

## Install Dependencies

`pip3 install -r requirements.txt`

## Acquiring Data

You must obtain access to the [MIMIC-III Clinical Database](https://physionet.org/content/mimiciii/1.4/).

Once data is acquired, follow instructions in [mimic-code](https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iii/buildmimic/mysql) to load the dataset into a MySQL database (This process may take multiple hours to complete). This database will be used in the data aggregation process.

## Aggregating Data

Open a shell in your MySQL database. Run `source ./preprocess/extract_mimic_data.sql` to extract relevant data out of the raw MIMIC-III dataset (This may take over 30 minutes). Note: `innodb_buffer_pool_size` must be increased for your MySQL instance. `2147483648` is sufficient.

Export the `KY_MIMIC_EVENTS_V4` and `KY_ADM_LENGTH` tables as CSVs with column headers to `./raw_data/MIMIC_FULL_BATCH.csv` and `./raw_data/MIMIC_ADM_INFO.csv` respectively.

Run `./aggregate_data.sh` to further aggregate the MIMIC-III data into a format that will be usable by the model.

## Model Training and Evaluation

Run `./run_pipeline_module.sh` to train and evaluate the model. Results and status updates will be put in `./logs/exp_name_train.log`. Training and evaluation may take over an hour.

### Research credit to:

Yu, K., Zhang, M., Cui, T., & Hauskrecht, M. (2020). Monitoring ICU Mortality Risk with A Long Short-Term Memory Recurrent Neural Network. Pacific Symposium on Biocomputing. Pacific Symposium on Biocomputing, 25, 103–114.
