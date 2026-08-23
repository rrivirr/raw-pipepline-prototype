
-- move these to control tables or configs for create task, these flow from the main timescale into the lake.

-- TODO: this should be a view, not a copy

CREATE OR REPLACE PROCEDURE take_data( start_at TIMESTAMP, until TIMESTAMP, lineage VARCHAR(36) )
  RETURNS STRING
  AS
  $$
DECLARE
  output_file STRING;
  copy_sql STRING;
BEGIN

LET prelude_date_part := 'MINUTE';
LET prelude_date_value := -30;
LET prelude TIMESTAMP := DATEADD(:prelude_date_part, :prelude_date_value, :start_at);

CREATE OR REPLACE TEMPORARY TABLE data_input_range AS
  SELECT 
    id,
    serial_number,
    rate,
    length,
    measured_at
  FROM TIGERLAKE_TSDB_PUBLIC_METER
  WHERE measured_at > :prelude
    AND measured_at < :until;

-- update lineage
CALL update_lineage(:lineage,  
    'processing_range',
    OBJECT_CONSTRUCT('prelude', :prelude, 'start_at', :start_at, 'until', :until, 'processed_at', TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDD_HH24MISS'))
  );


output_file :=  :lineage || '_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDD_HH24MISS') || '_data_input_range';

copy_sql := 'COPY INTO @correction_stage/' || output_file || '
               FROM data_input_range
               FILE_FORMAT = (TYPE = PARQUET)
               HEADER = TRUE
               SINGLE = TRUE
               OVERWRITE = FALSE';

EXECUTE IMMEDIATE copy_sql;




RETURN output_file;
END;
$$
;
