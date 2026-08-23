CREATE STAGE IF NOT EXISTS correction_stage
  FILE_FORMAT = (TYPE = PARQUET);



CREATE OR REPLACE PROCEDURE load_from_stage (suffix VARCHAR(36), staged_file VARCHAR(36))
  -- CREATE OR REPLACE TEMPORARY TABLE file_intake LIKE TIGERLAKE_TSDB_PUBLIC_METER;
RETURNS STRING
  AS
  $$
BEGIN

let tablename := 'file_intake_' || suffix;

let create_sql := '
CREATE OR REPLACE TEMPORARY TABLE ' || tablename || ' 
  LIKE TIGERLAKE_TSDB_PUBLIC_METER;';

EXECUTE IMMEDIATE create_sql;


let copy_sql := '
COPY INTO ' || tablename || ' 
  FROM @correction_stage/' || staged_file || '
  FILE_FORMAT = (TYPE = PARQUET)
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE';

EXECUTE IMMEDIATE copy_sql;

RETURN tablename;
END;
$$
;