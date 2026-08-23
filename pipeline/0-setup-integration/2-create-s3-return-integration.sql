SET S3_BUCKET = 's3://rriv-corrected-raw/';
SET STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::069717478125:role/snowflake_s3_write';
SET INTEGRATION_NAME = 'correction_s3_integration';

-- new dev account
CREATE OR REPLACE STORAGE INTEGRATION identifier($INTEGRATION_NAME)
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = $STORAGE_AWS_ROLE_ARN
  STORAGE_ALLOWED_LOCATIONS = ($S3_BUCKET);


DESC INTEGRATION identifier($INTEGRATION_NAME);

CREATE OR REPLACE FILE FORMAT corrected_raw_parquet_formmat
  TYPE = parquet;

--- not needed, this for import
CREATE OR REPLACE STAGE corrected_raw
  STORAGE_INTEGRATION = $INTEGRATION_NAME
  URL = $S3_BUCKET
  FILE_FORMAT = corrected_raw_parquet_formmat;


LIST @corrected_raw;




-----------Test
-- COPY INTO 's3://rriv-corrected-raw/lineage-export/'
-- FROM lineage
-- STORAGE_INTEGRATION = correction_s3_integration   -- or use CREDENTIALS = (...) inline
-- FILE_FORMAT = (TYPE = PARQUET)
-- HEADER = TRUE;