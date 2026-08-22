
-- move these to control tables or configs for create task, these flow from the main timescale into the lake.

-- TODO: this should be a view, not a copy

CREATE OR REPLACE PROCEDURE take_data( start_at TIMESTAMP, until TIMESTAMP, lineage VARCHAR(36) )
  RETURNS BOOLEAN
  AS
  $$
BEGIN

LET prelude_date_part := 'MINUTE';
LET prelude_date_value := -30;
LET prelude TIMESTAMP := DATEADD(:prelude_date_part, :prelude_date_value, start_at);

CREATE OR REPLACE TABLE "1_analysis_rows" AS
  SELECT *
  FROM TIGERLAKE_TSDB_PUBLIC_METER
  WHERE measured_at > :prelude
    AND measured_at < :until;

-- update lineage
-- todo:  make this a function
UPDATE lineage 
SET attributes = OBJECT_INSERT(
    attributes,
    'processing_range',
    OBJECT_CONSTRUCT('prelude', :prelude, 'start_at', :start_at, 'until', :until),
    TRUE)
WHERE id = :lineage;

RETURN TRUE;
END;
$$
;


--  Staring on a view based system.
-- --   LET prelude_date_part := 'MINUTE';
-- --   LET prelude_date_value := -30;
-- --   LET prelude TIMESTAMP := 

-- CREATE OR REPLACE FUNCTION data_range(start_at TIMESTAMP, until TIMESTAMP )
-- RETURNS TABLE (serial_number STRING, rate NUMBER(12:6), measured_at TIMESTAMP)
-- LANGUAGE SQL
-- AS
-- $$
 


--   SELECT *
--   FROM TIGERLAKE_TSDB_PUBLIC_METER
--   WHERE measured_at > DATEADD(:prelude_date_part, :prelude_date_value, start_at)
--     AND measured_at < :until

-- $$;

