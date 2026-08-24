CREATE OR REPLACE PROCEDURE correct_low_cutoff(lineage VARCHAR(36), staged_file VARCHAR(255))
  RETURNS STRING
  AS
  $$
DECLARE
  copy_sql STRING;
  correction_sql STRING;
  step_name STRING;
  output_file STRING;
BEGIN

  -- placeholder for low cutoff correction algorithm, return staged file input
  RETURN staged_file;

  -- this one easy

END;
$$;