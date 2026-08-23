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
                '036eeb9c-1df5-42df-9584-c93494190222');
CALL correct_warmup('036eeb9c-1df5-42df-9584-c93494190222', 
                    '036eeb9c-1df5-42df-9584-c93494190222_20260822_191515_data_input_range');


SELECT $1
FROM @correction_stage/036eeb9c-1df5-42df-9584-c93494190222_20260822_191515_data_input_range
LIMIT 10;