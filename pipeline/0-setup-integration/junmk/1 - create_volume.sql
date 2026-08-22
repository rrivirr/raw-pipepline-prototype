#
# Not needed??
#



!define S3_BUCKET = s3://rriv-sensor-data/;
!define VOLUME_AWS_ROLE_ARN = arn:aws:iam::069717478125:role/snowflake_iceberg_access;
!define VOLUME_NAME = rriv-sensor-data;
!set variable_substitution=true

-- Snowflake CLI (snow) Define variables in your snowflake.yml project definition file under the env section, then reference them using the <% ctx.env.variable_name %> syntax in your SQL script.

-- new dev account
-- CREATE OR REPLACE STORAGE INTEGRATION identifier($INTEGRATION_NAME)
--   TYPE = EXTERNAL_STAGE
--   STORAGE_PROVIDER = 'S3'
--   ENABLED = TRUE
--   STORAGE_AWS_ROLE_ARN = $STORAGE_AWS_ROLE_ARN
--   STORAGE_ALLOWED_LOCATIONS = ($S3_BUCKET);


CREATE OR REPLACE EXTERNAL VOLUME iceberg_external_volume
   STORAGE_LOCATIONS =
      (
         (
            NAME = '&VOLUME_NAME'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = '&S3_BUCKET'
            STORAGE_AWS_ROLE_ARN = '&VOLUME_AWS_ROLE_ARN'
            STORAGE_AWS_EXTERNAL_ID = 'iceberg_table_external_id'
         )
      )
      ALLOW_WRITES = TRUE;