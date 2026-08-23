-- This pipeline triggers directly off the correction pipeline for now
-- In the final design it will probably run on timer and grab all new data from a stage

CREATE OR REPLACE TASK apply_calibrations
  WAREHOUSE=COMPUTE_WH
  AFTER correct_low_cutoff -- just the last step in the correction pipeline for now
AS
DECLARE
  ctx VARIANT;
  output_staged_file STRING;
BEGIN

  CALL resolve_predecessor_context('CORRECT_WARMUP') INTO :ctx;
  CALL apply_calibrations(:ctx:lineage::STRING, :ctx:intake_file::STRING) INTO :output_staged_file;
  CALL SYSTEM$SET_RETURN_VALUE( :output_staged_file );
  
END;