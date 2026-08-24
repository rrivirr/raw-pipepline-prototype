-- watermark tracking tables
CREATE TABLE IF NOT EXISTS lineage_export_watermark (
    last_exported_at TIMESTAMP_NTZ
);
INSERT INTO lineage_export_watermark (last_exported_at)
SELECT '1970-01-01'::TIMESTAMP_NTZ
WHERE NOT EXISTS (SELECT 1 FROM lineage_export_watermark);



-- get the lineage from the passed staged file
CREATE OR REPLACE PROCEDURE resolve_predecessor_context(predecessor_task_name VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
  intake_file STRING;
BEGIN
  intake_file := SYSTEM$GET_PREDECESSOR_RETURN_VALUE(:predecessor_task_name);
  RETURN OBJECT_CONSTRUCT(
      'intake_file', intake_file,
      'lineage', extract_lineage_id(intake_file)
  );
END;
$$;

CREATE OR REPLACE FUNCTION extract_lineage_id(intake_file VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
  SUBSTRING(intake_file, 1, POSITION('_' IN intake_file) - 1)
$$;