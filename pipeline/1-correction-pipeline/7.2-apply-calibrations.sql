
CREATE OR REPLACE PROCEDURE apply_calibrations(lineage VARCHAR(36), staged_file VARCHAR(255))
  RETURNS STRING
  AS
  $$
DECLARE
  copy_sql STRING;
  calibration_sql STRING;
  step_name STRING;
  output_file STRING;
BEGIN


step_name := 'apply_calibrations';

CREATE OR REPLACE TEMPORARY TABLE file_intake LIKE TIGERLAKE_TSDB_PUBLIC_METER;

copy_sql := 'COPY INTO file_intake
               FROM @correction_stage/' || staged_file || '
               FILE_FORMAT = (TYPE = PARQUET)
               MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE';

EXECUTE IMMEDIATE copy_sql;

-- TODO: JSON is not right here, terrible performance.  Transmit an array of decimal values instead

calibration_sql := '
CREATE OR REPLACE TEMPORARY TABLE ' || step_name || ' AS
  SELECT file_intake.id, file_intake.serial_number, measured_at, calibration_type, rate,
    CASE calibration_type
      WHEN \'linear\' THEN  calibration_linear(rate, PARSE_JSON(parameters):m::FLOAT, PARSE_JSON(parameters):b::FLOAT)
      WHEN \'parabolic\' THEN 0
      WHEN \'piecewise_linear_4\' THEN 0
    END AS calibrated_value
  FROM file_intake 
  JOIN tigerlake_tsdb_public_calibration
  ON (
    file_intake.serial_number = tigerlake_tsdb_public_calibration.serial_number
    AND file_intake.measured_at >= tigerlake_tsdb_public_calibration.start_date
    AND file_intake.measured_at < COALESCE(tigerlake_tsdb_public_calibration.end_date, CURRENT_TIMESTAMP())
  );
  ';

EXECUTE IMMEDIATE calibration_sql;

    
-- TODO: what goes into the lineage here?  we need to expose the date range change overs
-- update lineage
CALL update_lineage(:lineage,  
    :step_name,
    OBJECT_CONSTRUCT('calibration', 'applied')
  );



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
$$
;


