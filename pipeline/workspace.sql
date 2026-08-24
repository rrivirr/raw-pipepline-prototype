SELECT take_data (TO_TIMESTAMP('2026-08-22', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-08-22 01:00', 'YYYY-M-DD HH24:MI:SS'));

SELECT TO_TIMESTAMP('2024-01-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS');


-- idea for overrides
CREATE OR REPLACE PROCEDURE unload_lineage_to_stage()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  effective_minutes INTEGER;
  prelude TIMESTAMP_NTZ;
BEGIN
  SELECT COALESCE(override_prelude_minutes, prelude_minutes)
    INTO :effective_minutes
    FROM task_params WHERE task_name = 'unload_lineage';

  prelude := DATEADD(minute, -effective_minutes, CURRENT_TIMESTAMP());

  -- clear the one-time override so subsequent scheduled runs use the default again
  UPDATE task_params SET override_prelude_minutes = NULL WHERE task_name = 'unload_lineage';

  -- ... unload logic using :prelude ...

  RETURN 'Ran with prelude_minutes = ' || effective_minutes;
END;
$$;

DECLARE
  lineage STRING;
  staged_file STRING;
BEGIN
  CALL new_processing_lineage() INTO :lineage;
  CALL take_data (TO_TIMESTAMP('2026-08-22 02:00', 'YYYY-MM-DD HH24:MI'), 
                TO_TIMESTAMP('2026-08-22 03:00', 'YYYY-MM-DD HH24:MI'), 
                :lineage) INTO staged_file;
  CALL correct_warmup(:lineage, 
                      :staged_file);
END;


CALL new_processing_lineage();
CALL take_data (TO_TIMESTAMP('2026-08-22 02:00', 'YYYY-MM-DD HH24:MI'), 
                TO_TIMESTAMP('2026-08-22 03:00', 'YYYY-MM-DD HH24:MI'), 
                '625ccbbe-d150-418e-a150-fd74cdad36cd');
CALL correct_warmup('625ccbbe-d150-418e-a150-fd74cdad36cd', 
                    '625ccbbe-d150-418e-a150-fd74cdad36cd_20260822_225106_data_input_range');
CALL export_corrected_data('036eeb9c-1df5-42df-9584-c93494190222_20260822_195223_corrected_data_warmup');

SELECT $1
FROM @correction_stage/036eeb9c-1df5-42df-9584-c93494190222_20260822_191515_data_input_range
LIMIT 10;



ALTER TASK run_correction SUSPEND;
ALTER TASK take_data SUSPEND;
ALTER TASK correct_warmup SUSPEND;
ALTER TASK export SUSPEND;



SELECT SUBSTRING('ok_ok', 1, POSITION('_', 'ok_ok')-1)



SELECT
    ARRAY_AGG(
        OBJECT_CONSTRUCT(
            'serial_number', dl.serial_number,
            'attributes', dl.attributes
        )
    ) AS devices
FROM file_intake 
JOIN tigerlake_tsdb_public_calibration
    ON (
  -- file_intake.serial_number = tigerlake_tsdb_public_calibration.serial_number
  -- AND
  tigerlake_tsdb_public_calibration.active = true
  AND file_intake.measured_at >= tigerlake_tsdb_public_calibration.start_date
  AND file_intake.measured_at < COALESCE(tigerlake_tsdb_public_calibration.end_date, CURRENT_TIMESTAMP())
  
);
GROUP BY l.id, l.created_at, l.attributes;


CREATE OR REPLACE TEMPORARY TABLE ' || :step_name || ' AS
  SELECT file_intake.id, file_intake.serial_number, measured_at, calibration_type, rate, parameters
    CASE calibration_type
      WHEN \'linear\' THEN  calibration_linear(rate, PARSE_JSON(parameters):m::FLOAT, PARSE_JSON(parameters):b::FLOAT)
      WHEN \'parabolic\' THEN 0
      WHEN \'piecewise_linear_4\' THEN 0
    END AS calibrated_value
  FROM file_intake 
  JOIN tigerlake_tsdb_public_calibration
  ON (
    -- file_intake.serial_number = tigerlake_tsdb_public_calibration.serial_number
    -- AND
    tigerlake_tsdb_public_calibration.active = true
    AND file_intake.measured_at >= tigerlake_tsdb_public_calibration.start_date
    AND file_intake.measured_at < COALESCE(tigerlake_tsdb_public_calibration.end_date, CURRENT_TIMESTAMP())
    
  );