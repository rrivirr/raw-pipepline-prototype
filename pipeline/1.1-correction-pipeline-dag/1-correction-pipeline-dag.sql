CREATE OR REPLACE  TASK start_new_processing_lineage
    warehouse=COMPUTE_WH
    schedule='USING CRON 10 * * * * America/Los_Angeles'
    as CALL new_processing_lineage$SET_RETURN_VALUE();

CREATE OR REPLACE TASK take_data
  AFTER start_new_processing_lineage
  AS
    BEGIN
      LET lineage := (SELECT SYSTEM$GET_PREDECESSOR_RETURN_VALUE('start_new_processing_lineage'));
      LET start_at := SELECT DATE_PART(EPOCH, date_trunc('hour', SYSDATE() - INTERVAL '1 hour')); -- start of last hour
      LET until := SELECT DATEADD(hour, 1, start_at);
      CALL take_data$SET_RETURN_VALUE(start_at, until, :lineage);
    END;

CREATE OR REPLACE TASK correct_warmup
  AFTER take_data
  AS
    BEGIN
      LET lineage := (SELECT SYSTEM$GET_PREDECESSOR_RETURN_VALUE('start_new_processing_lineage'));
      LET input_stage := (SELECT SYSTEM$GET_PREDECESSOR_RETURN_VALUE('take_data'));
      CALL correct_warmup(lineage, input_stage);