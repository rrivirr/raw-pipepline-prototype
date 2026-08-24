CREATE OR REPLACE PROCEDURE correct_low_cutoff(lineage VARCHAR(36), staged_file VARCHAR(255))
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

  step_name := 'corrected_low_cutoff';

  CREATE OR REPLACE TEMPORARY TABLE file_intake LIKE TIGERLAKE_TSDB_PUBLIC_METER;

  copy_sql := 'COPY INTO file_intake
                FROM @correction_stage/' || staged_file || '
                FILE_FORMAT = (TYPE = PARQUET)
                MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE';

  EXECUTE IMMEDIATE copy_sql;

  CREATE OR REPLACE TEMPORARY TABLE cutoffs AS
    SELECT
      DISTINCT(a.serial_number),
      COALESCE(cc.low_cutoff, defaults.low_cutoff) AS low_cutoff
        FROM TIGERLAKE_TSDB_PUBLIC_METER a
        LEFT JOIN correction_control cc
      ON a.serial_number = cc.serial_number
    CROSS JOIN (
        SELECT low_cutoff
        FROM correction_control
        WHERE serial_number = 'DEFAULT'
    ) defaults;
  

  correction_sql := '
  CREATE OR REPLACE TEMPORARY TABLE ' || :step_name || ' AS
     SELECT 
        id,
        file_intake.serial_number,
        CASE WHEN file_intake.rate < low_cutoff THEN 0 ELSE file_intake.rate END AS rate,
        length,
        measured_at
      FROM file_intake
      JOIN cutoffs
      ON cutoffs.serial_number = file_intake.serial_number;
  ';

  EXECUTE IMMEDIATE correction_sql;


  CALL update_lineage(:lineage,  
    :step_name,
    OBJECT_CONSTRUCT('low_cutoff', 'applied')
  );

  -- update device lineage
  insert_sql := '
    INSERT INTO device_lineage (group_lineage, serial_number, attributes)
    SELECT
        ''' || :lineage || ''',
        serial_number,
        OBJECT_CONSTRUCT(''low_cutoff'', low_cutoff)
    FROM cutoffs;
  ';
 
  EXECUTE IMMEDIATE insert_sql;

  output_file :=  :lineage || '_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDD_HH24MISS') || '_' || :step_name;

  copy_sql := 'COPY INTO @correction_stage/' || output_file || '
                FROM ' || :step_name || '
                FILE_FORMAT = (TYPE = PARQUET)
                  HEADER = TRUE
                SINGLE = TRUE
                OVERWRITE = FALSE';

  EXECUTE IMMEDIATE copy_sql;


  RETURN output_file;

 

END;
$$;