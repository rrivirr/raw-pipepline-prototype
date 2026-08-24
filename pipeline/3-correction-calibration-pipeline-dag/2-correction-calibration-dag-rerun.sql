
-- create a table to hold configuration parameters
CREATE OR REPLACE TABLE task_params (
    task_name VARCHAR(36),
    manual_data_start_at TIMESTAMP_NTZ,
    manual_data_until TIMESTAMP_NTZ
);
INSERT INTO task_params (task_name, manual_data_start_at, manual_data_until) values ( 'correction_run', NULL, NULL);

-- trigger into the pipeline where the configuration parameters are picked up
CREATE OR REPLACE PROCEDURE run_correction(start_at TIMESTAMP, until TIMESTAMP)
  RETURNS BOOLEAN
  AS
  $$
BEGIN
  UPDATE task_params SET manual_data_start_at = :start_at, manual_data_until = :until WHERE task_name = 'correction_run';
  EXECUTE TASK run_correction;
  RETURN TRUE;
END;
$$;
