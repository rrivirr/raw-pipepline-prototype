
create or replace task LOAD_DATA_FOR_CORRECTION
	warehouse=COMPUTE_WH
	schedule='USING CRON 10 * * * * America/Los_Angeles'
	as CALL load_data();




create or replace task IDENTIFY_ZERO_CORRECTION
	warehouse=COMPUTE_WH
    AFTER LOAD_DATA_FOR_CORRECTION
	as CALL identify_zero_correction();


create or replace task PUBLISH_ZERO_CORRECTIONS
	warehouse=COMPUTE_WH
    AFTER IDENTIFY_ZERO_CORRECTION
	as CALL publish_zero_corrections();


create or replace task PUBLISH_ZERO_CORRECTIONS_DEV
	warehouse=COMPUTE_WH
    AFTER IDENTIFY_ZERO_CORRECTION
	as CALL publish_zero_corrections_dev();


create or replace task STORE_ZERO_HISTORY
	warehouse=COMPUTE_WH
    AFTER IDENTIFY_ZERO_CORRECTION
	as
INSERT INTO zero_history (serial_number, zero_offset)
SELECT serial_number, selected_zero 
FROM "7_updated_zeros";


