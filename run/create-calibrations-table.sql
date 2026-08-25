CREATE OR REPLACE TABLE TIGERLAKE_TSDB_PUBLIC_CALIBRATION (
    id NUMBER(10,0) PRIMARY KEY,
    serial_number VARCHAR,
    calibration_type VARCHAR,
    parameters VARCHAR,
    start_date TIMESTAMP_NTZ(6),
    end_date TIMESTAMP_NTZ(6)
);

INSERT INTO TIGERLAKE_TSDB_PUBLIC_CALIBRATION (id, serial_number, calibration_type, parameters, start_date, end_date)
VALUES (2, 'flow_0001', 'linear', '{"m":0.9, "b":0.33}', '2025-08-23 07:14:27.857'::TIMESTAMP_NTZ, NULL);
