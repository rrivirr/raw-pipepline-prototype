
CREATE TABLE correction_control (
    serial_number STRING,
    warmup_prelude_seconds INT,
    low_cutoff FLOAT
);

INSERT INTO correction_control 
(serial_number, warmup_prelude_seconds, low_cutoff)
VALUES
('DEFAULT', 10 * 60, 0.009);

INSERT INTO correction_control 
(serial_number, warmup_prelude_seconds, low_cutoff)
VALUES
('flow_0001', 10 * 60, 0.007);



-- test
-- SELECT
--     a.serial_number,
--     COALESCE(cc.low_flow_cutoff, defaults.low_flow_cutoff) AS low_flow_cutoff
-- FROM TIGERLAKE_TSDB_PUBLIC_METER a
-- LEFT JOIN correction_control cc
--     ON a.serial_number = cc.serial_number
-- CROSS JOIN (
--     SELECT low_flow_cutoff
--     FROM correction_control
--     WHERE serial_number = 'DEFAULT'
-- ) defaults;