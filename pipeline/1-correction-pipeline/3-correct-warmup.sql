

--- any gap beyond the threshold indicated a warmup or a potential warmup (state unknown with data outage)
--- or flag periods with certain signature defined by the data scientist

CREATE OR REPLACE PROCEDURE correct_warmup(lineage VARCHAR(36), staged_file VARCHAR(255))
  RETURNS STRING
  AS
  $$
DECLARE
  copy_sql STRING;
  correction_sql STRING;
  step_name STRING;
  output_file STRING;
BEGIN



LET warmup_reset := 10 * 60; -- TODO: hard coded, add to dag config and run overrides

step_name := 'corrected_data_warmup';

CREATE OR REPLACE TEMPORARY TABLE file_intake LIKE TIGERLAKE_TSDB_PUBLIC_METER;

copy_sql := 'COPY INTO file_intake
               FROM @correction_stage/' || staged_file || '
               FILE_FORMAT = (TYPE = PARQUET)
               MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE';

EXECUTE IMMEDIATE copy_sql;

-- TODO: this detection logic needs to be improved.  the preceeding rows count is a not a precise method
correction_sql := '
CREATE OR REPLACE TABLE ' || step_name || ' AS
    SELECT 
        id,
        serial_number,
        rate,
        length,
        measured_at,
        max_gap,
        gap_length
    FROM (
        SELECT *,
        MAX(gap_length) OVER (
            PARTITION BY serial_number
            ORDER BY measured_at
            ROWS BETWEEN 300 PRECEDING and CURRENT ROW
        ) as max_gap
        FROM (
            SELECT *, 
            DATE_PART(EPOCH, measured_at) - LAG(DATE_PART(EPOCH, measured_at)) 
                OVER ( PARTITION BY serial_number ORDER BY measured_at) AS gap_length
            FROM file_intake
        )
    ) 
    WHERE max_gap < ' || warmup_reset || ';
';

EXECUTE IMMEDIATE correction_sql;
  
  
-- update lineage
CALL update_lineage(:lineage,  
    :step_name,
    OBJECT_CONSTRUCT('warmup_interval', :warmup_reset)
  );



output_file :=  :lineage || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDD_HH24MISS') || '_' || :step_name;

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


