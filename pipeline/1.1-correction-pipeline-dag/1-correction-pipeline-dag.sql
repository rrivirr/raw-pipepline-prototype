
CREATE OR REPLACE TASK run_correction
  warehouse=COMPUTE_WH
  schedule='USING CRON 10 * * * * America/Los_Angeles'
AS 
DECLARE
  lineage STRING;
  output_staged_file STRING;
  effective_start_at: DATETIME;
  effective_until: DATETIME;
BEGIN

  -- check if this is a manual re-run
  SELECT 
    COALESCE(manual_data_start_at, TO_TIMESTAMP(SELECT DATE_PART(EPOCH, date_trunc('hour', SYSDATE() - INTERVAL '1 hour')))),
    COALESCE(manual_data_until, (SELECT DATEADD('hour', 1, TO_TIMESTAMP(SELECT DATE_PART(EPOCH, date_trunc('hour', SYSDATE() - INTERVAL '1 hour'))) )))
    INTO :effective_start_at, :effective_until
    FROM task_params WHERE task_name = 'correction_run';

  UPDATE task_params SET manual_data_start_at = NULL, manual_data_until = NULL WHERE task_name = 'correction_run';

  CALL new_processing_lineage() INTO lineage;

  CALL take_data(:effective_start_at, :effective_until, :lineage) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE( :output_staged_file );
END;
    
    
 --   SCHEDULE = 'USING CRON */5 * * * * UTC'



CREATE OR REPLACE TASK correct_warmup
  WAREHOUSE=COMPUTE_WH
  AFTER run_correction
AS 
DECLARE
  output_staged_file STRING;
  ctx VARIANT;
BEGIN
  CALL resolve_predecessor_context('RUN_CORRECTION') INTO :ctx;
  CALL correct_warmup(:ctx:lineage::STRING, :ctx:intake_file::STRING) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE( :output_staged_file );
END;


CREATE OR REPLACE TASK correct_low_cutoff
  WAREHOUSE=COMPUTE_WH
  AFTER correct_warmup
AS 
DECLARE
  output_staged_file STRING;
ctx VARIANT;
BEGIN
  CALL resolve_predecessor_context('CORRECT_WARMUP') INTO :ctx;
  CALL correct_low_cutoff(:ctx:lineage::STRING, :ctx:intake_file::STRING) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE( :output_staged_file );
END;




-- TODO: the EXPORT needs to ignore the prelude
CREATE OR REPLACE TASK export
  WAREHOUSE=COMPUTE_WH
  AFTER correct_low_cutoff
AS
DECLARE
  ctx VARIANT;
BEGIN
  CALL resolve_predecessor_context('CORRECT_LOW_CUTOFF') INTO :ctx;
  CALL export_corrected_data(:ctx:lineage::STRING, :ctx:intake_file::STRING);
  CALL export_new_lineage_records();
END;


ALTER TASK export RESUME;
ALTER TASK correct_low_cutoff RESUME;
ALTER TASK correct_warmup RESUME;
ALTER TASK run_correction RESUME;
