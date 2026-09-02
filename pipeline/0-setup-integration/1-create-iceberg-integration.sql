
CREATE OR REPLACE CATALOG INTEGRATION tiger_s3tables_catalog
  CATALOG_SOURCE = ICEBERG_REST
  TABLE_FORMAT = ICEBERG
  CATALOG_NAMESPACE = '&S3_TABLE_NAMESPACE'
  REST_CONFIG = (
    CATALOG_URI = '&CATALOG_URI'
    CATALOG_API_TYPE = AWS_GLUE
    WAREHOUSE = '&AWS_ACCOUNT_ID:s3tablescatalog/&S3_BUCKET'
    ACCESS_DELEGATION_MODE = VENDED_CREDENTIALS
  )
  REST_AUTHENTICATION = (
    TYPE = SIGV4
    SIGV4_IAM_ROLE = 'arn:aws:iam::&AWS_ACCOUNT_ID:role/snowflake-s3tables-reader'
    SIGV4_SIGNING_REGION = '&AWS_REGION'
  )
  REFRESH_INTERVAL_SECONDS = 120
  ENABLED = TRUE;

-- correction pipeline requirements
CREATE OR REPLACE ICEBERG TABLE tigerlake_tsdb_public_meter
    CATALOG = 'tiger_s3tables_catalog'
    CATALOG_TABLE_NAME = 'tigerlake_tsdb_public_meter'
    AUTO_REFRESH = TRUE;


-- calibration pipeline requirements
CREATE OR REPLACE ICEBERG TABLE tigerlake_tsdb_public_calibration
    CATALOG = 'tiger_s3tables_catalog'
    CATALOG_TABLE_NAME = 'tigerlake_tsdb_public_calibration'
    AUTO_REFRESH = TRUE;