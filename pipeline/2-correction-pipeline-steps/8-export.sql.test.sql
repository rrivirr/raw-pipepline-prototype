-- test that the function runs
SELECT $1 FROM @correction_stage/edc699de-50c2-4a11-986f-55ca3b8fe191_20260823_010755_corrected_data_warmup limit 10;
CALL export_corrected_data('edc699de-50c2-4a11-986f-55ca3b8fe191', 'edc699de-50c2-4a11-986f-55ca3b8fe191_20260823_010755_corrected_data_warmup');
LIST @corrected_outputs_stage/flow_0001/2026/08/20;
SELECT $1 FROM @corrected_outputs_stage/flow_0001/2026/08/20 limit 2;
