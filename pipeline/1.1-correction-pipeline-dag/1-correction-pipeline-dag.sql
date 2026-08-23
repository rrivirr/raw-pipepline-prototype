ALTER TASK start_new_processing_lineage SUSPEND;
ALTER TASK take_data SUSPEND;
ALTER TASK correct_warmup SUSPEND;
ALTER TASK export SUSPEND;



CREATE OR REPLACE  TASK start_new_processing_lineage
  warehouse=COMPUTE_WH
  schedule='USING CRON 10 * * * * America/Los_Angeles'
AS 
DECLARE
  lineage STRING;
BEGIN
  CALL new_processing_lineage() INTO lineage;
  CALL SYSTEM$SET_RETURN_VALUE( :lineage );
END;
    
    
    --   SCHEDULE = 'USING CRON */5 * * * * UTC'



CREATE OR REPLACE TASK take_data
  WAREHOUSE=COMPUTE_WH
  AFTER start_new_processing_lineage
AS 
DECLARE
  output_staged_file STRING;
BEGIN
  LET lineage := SYSTEM$GET_PREDECESSOR_RETURN_VALUE('START_NEW_PROCESSING_LINEAGE');
  LET start_at := TO_TIMESTAMP(SELECT DATE_PART(EPOCH, date_trunc('hour', SYSDATE() - INTERVAL '1 hour')))); -- start of last hour
  LET until DATETIME := (SELECT DATEADD('hour', 1, :start_at));
  CALL take_data(:start_at, :until, :lineage) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE( :output_staged_file );
END;



CREATE OR REPLACE TASK correct_warmup
  WAREHOUSE=COMPUTE_WH
  AFTER take_data
AS 
DECLARE
  output_staged_file STRING;
BEGIN
  LET lineage := (SELECT SYSTEM$GET_PREDECESSOR_RETURN_VALUE('START_NEW_PROCESSING_LINEAGE'));
  LET intake_file := (SELECT SYSTEM$GET_PREDECESSOR_RETURN_VALUE('TAKE_DATA'));
  CALL correct_warmup(:lineage, :intake_file) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE( :output_staged_file );
END;


CREATE OR REPLACE TASK correct_low_cutoff
  WAREHOUSE=COMPUTE_WH
  AFTER correct_warmup
AS 
DECLARE
  output_staged_file STRING;
BEGIN
  LET lineage := (SELECT SYSTEM$GET_PREDECESSOR_RETURN_VALUE('START_NEW_PROCESSING_LINEAGE'));
  LET intake_file := (SELECT SYSTEM$GET_PREDECESSOR_RETURN_VALUE('CORRECT_WARMUP'));
  CALL correct_low_cutoff(:lineage, :intake_file) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE( :output_staged_file );
END;



-- the EXPORT needs to ignore the prelude
CREATE OR REPLACE TASK export
  WAREHOUSE=COMPUTE_WH
  AFTER correct_low_cutoff
AS
BEGIN
  LET intake_file := (SELECT SYSTEM$GET_PREDECESSOR_RETURN_VALUE('CORRECT_WARMUP'));
  CALL export_corrected_data(:intake_file);
  CALL export_new_lineage_records();
END;


ALTER TASK export RESUME;
ALTER TASK correct_warmup RESUME;
ALTER TASK correct_low_cutoff RESUME;
ALTER TASK take_data RESUME;
ALTER TASK start_new_processing_lineage RESUME;
