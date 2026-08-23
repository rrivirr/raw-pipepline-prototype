-- copy the data into the s3 that goes back to tiger data for service

-- corrected data is exported to drive two processes
-- first, as a feed into the calibration pipeline 
-- second, as a patch to append/overwrite the most up to date raw import for serving



CREATE OR REPLACE PROCEDURE export_corrected_data()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  file_path STRING;
  copy_sql STRING;
BEGIN

 file_path := 's3://rriv-corrected-raw/corrected-data-export/'
               || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYY-MM-DD"T"HH24-MI-SS')
               || '_corrected_data.parquet';

-- todo: this needs to read from the final processing table.
  copy_sql := 'COPY INTO ''' || file_path || '''
               FROM ( SELECT serial_number, rate, length, measured_at, id FROM "3_correct_warmup" )
               STORAGE_INTEGRATION = correction_s3_integration
               FILE_FORMAT = (TYPE = PARQUET)
               ';

    EXECUTE IMMEDIATE copy_sql;

END;
$$;

-- export the new lineage records as well
CREATE OR REPLACE PROCEDURE export_new_lineage_records()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  last_wm TIMESTAMP_NTZ;
  new_wm TIMESTAMP_NTZ;
  file_path STRING;
  copy_sql STRING;
BEGIN
  SELECT last_exported_at INTO :last_wm FROM lineage_export_watermark;
  SELECT MAX(created_at) INTO :new_wm FROM lineage WHERE created_at > :last_wm;

  IF (new_wm IS NULL) THEN
    RETURN 'No new records to export';
  END IF;

  file_path := 's3://rriv-corrected-raw/lineage-export/'
               || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYY-MM-DD"T"HH24-MI-SS')
               || '_lineage.parquet';

  copy_sql := 'COPY INTO ''' || file_path || '''
               FROM (SELECT * FROM lineage WHERE created_at > TO_TIMESTAMP_NTZ(''' || last_wm::STRING || '''))
               STORAGE_INTEGRATION = correction_s3_integration
               FILE_FORMAT = (TYPE = PARQUET)
               SINGLE = TRUE';

  EXECUTE IMMEDIATE copy_sql;

  UPDATE lineage_export_watermark SET last_exported_at = :new_wm;

  RETURN 'Exported records through ' || new_wm::STRING;
END;
$$;

