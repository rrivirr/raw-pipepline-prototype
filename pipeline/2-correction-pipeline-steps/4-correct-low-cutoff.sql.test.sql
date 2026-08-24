-- generate the staged data
COPY INTO @correction_stage/test/low-flow-test
  FROM (
    SELECT *
    FROM TIGERLAKE_TSDB_PUBLIC_METER
    WHERE measured_at >= '2026-08-22 00:00:00'::TIMESTAMP
    AND measured_at < '2026-08-23 00:00:00'::TIMESTAMP
  )
  FILE_FORMAT = (TYPE = PARQUET)
  HEADER = TRUE
  SINGLE = TRUE
  OVERWRITE = TRUE;


-- test the function
CALL new_processing_lineage();
SET lineage = (SELECT "NEW_PROCESSING_LINEAGE" FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())));
CALL correct_low_cutoff($lineage, 'test/low-flow-test');

