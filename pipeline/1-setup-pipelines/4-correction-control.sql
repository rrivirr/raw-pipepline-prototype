
CREATE OR REPLACE TABLE correction_control (
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


INSERT INTO correction_control 
(serial_number, warmup_prelude_seconds, low_cutoff)
VALUES
('flow_002', 10 * 60, 0.005);