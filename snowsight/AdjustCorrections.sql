UPDATE correction_control
SET low_cutoff = 0.003
WHERE serial_number = 'flow_0001';

CALL test_run_correction_run('2026-08-18 00:00:00'::TIMESTAMP, DATEADD('day', 1, '2026-08-22 00:00:00'::TIMESTAMP));

