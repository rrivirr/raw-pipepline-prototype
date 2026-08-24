-- correct for sensor drift on a device specific basis
-- not implemented
CREATE OR REPLACE PROCEDURE correct_drift(lineage VARCHAR(36), staged_file VARCHAR(255))
  RETURNS STRING
  AS
  $$
DECLARE
  copy_sql STRING;
  correction_sql STRING;
  step_name STRING;
  output_file STRING;
  insert_sql STRING;
BEGIN

  CALL update_lineage(:lineage,  
    :step_name,
    OBJECT_CONSTRUCT('correct_drift', 'skipped')
  );
  
  RETURN staged_file;

END;
$$;