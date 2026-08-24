-- run quality metric on a device type specific basis
-- not implemented
CREATE OR REPLACE PROCEDURE identify_quality(lineage VARCHAR(36), staged_file VARCHAR(255))
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
    OBJECT_CONSTRUCT('identify_quality', 'skipped', 'quality', 'passed')
  );
  
  RETURN staged_file;

END;
$$;