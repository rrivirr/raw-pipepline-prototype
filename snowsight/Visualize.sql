
-- LIST @corrected_outputs_stage/flow_0001/2026/08/21/10; -- UPDATE HERE

-- SELECT $1 FROM @corrected_outputs_stage/flow_0001/2026/08/22/02/ee676ae9-0d7f-4373-a3dd-7532781c606f/data_01c69898-010a-dac4-0031-da6f0008ec3e_007_4_0.snappy.parquet limit 1;

CREATE OR REPLACE TEMPORARY TABLE calibrated_values (
    serial_number VARCHAR(36),
    measured_at TIMESTAMP,
    calibrated_value NUMERIC(12,6),
    partition_path VARCHAR(100),
    lineage VARCHAR(36)
);

COPY INTO calibrated_values 
FROM @corrected_outputs_stage/flow_0001/2026/08/21  -- UPDATE HERE
 FILE_FORMAT = (TYPE = PARQUET)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

UPDATE calibrated_values
SET lineage = SUBSTRING(partition_path, POSITION('/', REVERSE(partition_path)) * -1 + LENGTH('/') + 2);

SELECT DISTINCT lineage FROM calibrated_values;

SELECT * FROM calibrated_values where lineage = 'aed56d-a1ce-4daa-96fe-eb48937b25dc';
SELECT * FROM calibrated_values where lineage = '40f904-e791-4189-a6ec-f5960b0671df';


-- each lineage needs to be a column in order to plot this
-- join the different groups of columns into a new table



select * from lineage;



SELECT
    l.id,
    l.created_at,
    l.attributes,
    ARRAY_AGG(
        OBJECT_CONSTRUCT(
            'serial_number', dl.serial_number,
            'attributes', dl.attributes
        )
    ) AS devices
FROM lineage l
LEFT JOIN device_lineage dl
    ON dl.group_lineage = l.id
GROUP BY l.id, l.created_at, l.attributes;