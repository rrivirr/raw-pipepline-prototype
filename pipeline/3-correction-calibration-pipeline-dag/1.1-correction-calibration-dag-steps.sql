
CREATE OR REPLACE PROCEDURE run_correction_setup()
 RETURNS STRING
 EXECUTE AS CALLER
  AS
  $$
DECLARE
  lineage STRING;
  output_staged_file STRING;
  effective_start_at TIMESTAMP;
  effective_until TIMESTAMP;
BEGIN

  -- check if this is a manual re-run
  SELECT 
    COALESCE(manual_data_start_at, TO_TIMESTAMP(DATE_PART(EPOCH, date_trunc('hour', SYSDATE() - INTERVAL '1 hour')))),
    COALESCE(manual_data_until, (SELECT DATEADD('hour', 1, TO_TIMESTAMP(DATE_PART(EPOCH, date_trunc('hour', SYSDATE() - INTERVAL '1 hour'))) )))
    INTO :effective_start_at, :effective_until
    FROM task_params WHERE task_name = 'correction_run';

  UPDATE task_params SET manual_data_start_at = NULL, manual_data_until = NULL WHERE task_name = 'correction_run';

  CALL new_processing_lineage() INTO :lineage;

  CALL take_data(:effective_start_at, :effective_until, :lineage) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE(:output_staged_file);
  RETURN :output_staged_file;

END;
$$;
    

CREATE OR REPLACE PROCEDURE run_correct_warmup()
 RETURNS STRING
 EXECUTE AS CALLER
  AS
  $$
DECLARE
  ctx VARIANT;  
  output_staged_file STRING;
BEGIN
  CALL resolve_predecessor_context('RUN_CORRECTION') INTO :ctx;
  CALL correct_warmup(:ctx:lineage::STRING, :ctx:intake_file::STRING) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE(:output_staged_file);
  RETURN :output_staged_file;
END;
$$;

CREATE OR REPLACE PROCEDURE run_correct_low_cutoff()
  RETURNS STRING
  EXECUTE AS CALLER
  AS
  $$
DECLARE
  output_staged_file STRING;
  ctx VARIANT;
BEGIN
  CALL resolve_predecessor_context('CORRECT_WARMUP') INTO :ctx;
  CALL correct_low_cutoff(:ctx:lineage::STRING, :ctx:intake_file::STRING) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE(:output_staged_file);
  RETURN :output_staged_file;
END;
$$;


--TODO: add task here to cut out the prelude

CREATE OR REPLACE PROCEDURE run_apply_calibrations()
  RETURNS STRING
  EXECUTE AS CALLER
  AS
  $$
DECLARE
  output_staged_file STRING;
  ctx VARIANT;
BEGIN
  CALL resolve_predecessor_context('CORRECT_LOW_CUTOFF') INTO :ctx;
  CALL apply_calibrations(:ctx:lineage::STRING, :ctx:intake_file::STRING) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE(:output_staged_file);
  RETURN :output_staged_file;
END;
$$;



CREATE OR REPLACE PROCEDURE run_export()
  RETURNS STRING
  AS
  $$
DECLARE
  output_staged_file STRING;
  ctx VARIANT;
BEGIN
  CALL resolve_predecessor_context('APPLY_CALIBRATIONS') INTO :ctx;
  CALL export_corrected_data(:ctx:lineage::STRING, :ctx:intake_file::STRING);
  CALL export_new_lineage_records();
END;
$$;
