-- create a table to hold configuration parameters
CREATE OR REPLACE TABLE task_params (
    task_name VARCHAR(36),
    manual_data_start_at TIMESTAMP_NTZ,
    manual_data_until TIMESTAMP_NTZ
);
INSERT INTO task_params (task_name, manual_data_start_at, manual_data_until) values ( 'correction_run', NULL, NULL);