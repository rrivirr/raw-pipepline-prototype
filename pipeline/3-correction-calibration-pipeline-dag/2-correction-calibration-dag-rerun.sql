
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
