
-- INSERT INTO lineage (id, created_at, data)
-- SELECT UUID_STRING(), CURRENT_TIMESTAMP(), PARSE_JSON('{}');

CREATE OR REPLACE PROCEDURE new_lineage_row()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
  new_id VARCHAR;
BEGIN
  new_id := UUID_STRING();

  INSERT INTO lineage (id, created_at, attributes)
  SELECT :new_id, CURRENT_TIMESTAMP(), PARSE_JSON('{}');

  RETURN new_id;
END;
$$;
