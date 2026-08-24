CREATE OR REPLACE TABLE lineage (
    id VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    attributes VARIANT DEFAULT PARSE_JSON('{}')
);

CREATE OR REPLACE TABLE device_lineage (
    id VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    group_lineage VARCHAR(36),
    serial_number VARCHAR(36),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    attributes VARIANT DEFAULT PARSE_JSON('{}')
);


CREATE OR REPLACE PROCEDURE update_lineage(lineage_id VARCHAR(36), object_key VARCHAR, object_values OBJECT)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    UPDATE lineage
    SET attributes = OBJECT_INSERT(attributes, :object_key, :object_values, TRUE)
    WHERE id = :lineage_id;

    RETURN 'Updated lineage row ' || lineage_id;
END;
$$;