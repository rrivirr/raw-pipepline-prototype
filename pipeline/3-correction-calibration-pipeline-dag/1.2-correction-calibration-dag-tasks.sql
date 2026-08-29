
ALTER TASK IF EXISTS run_correction SUSPEND;


CREATE OR REPLACE TASK run_correction
  WAREHOUSE=COMPUTE_WH
  SCHEDULE='USING CRON 10 * * * * America/Los_Angeles'
AS 
  CALL run_correction_setup();
    

CREATE OR REPLACE TASK correct_warmup
  WAREHOUSE=COMPUTE_WH
  AFTER run_correction
AS 
  CALL run_correct_warmup();


CREATE OR REPLACE TASK correct_low_cutoff
  WAREHOUSE=COMPUTE_WH
  AFTER correct_warmup
AS 
  CALL run_correct_low_cutoff();


--TODO: add task here to cut out the prelude


CREATE OR REPLACE TASK apply_calibrations
  WAREHOUSE=COMPUTE_WH
  AFTER correct_low_cutoff -- just the last step in the correction pipeline for now
AS
  CALL run_apply_calibrations();



CREATE OR REPLACE TASK export
  WAREHOUSE=COMPUTE_WH
  AFTER apply_calibrations
AS
  CALL run_export();


ALTER TASK export RESUME;
ALTER TASK apply_calibrations RESUME;
ALTER TASK correct_low_cutoff RESUME;
ALTER TASK correct_warmup RESUME;
ALTER TASK run_correction RESUME;
