# https://www.tigerdata.com/docs/integrate/connectors/destination/snowflake

aws iam create-role \
  --role-name snowflake-s3tables-reader \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::299014720730:user/zbw32000-s"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "sts:ExternalId": "QKB19465_SFCRole=5_rqwhRUBxGReD74Aj6Kf1gJgZsLE="
          }
        }
      },
      {
        "Effect": "Allow",
        "Principal": {
            "Service": "lakeformation.amazonaws.com"
        },
        "Action": [
            "sts:AssumeRole",
            "sts:SetContext",
            "sts:SetSourceIdentity"
        ],
        "Condition": {
            "StringEquals": {
                "aws:SourceAccount": "069717478125"
            },
            "ArnEquals": {
                "aws:SourceArn": "arn:aws:lakeformation:us-west-2:069717478125:*"
            }
        }
      }
    ]
  }'

  aws iam put-role-policy \
  --role-name snowflake-s3tables-reader \
  --policy-name snowflake-s3tables-access \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "GlueAccess",
        "Effect": "Allow",
        "Action": [
          "glue:GetCatalog",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables"
        ],
        "Resource": "*"
      },
      {
        "Sid": "LakeFormationAccess",
        "Effect": "Allow",
        "Action": [
          "lakeformation:GetDataAccess"
        ],
        "Resource": "*"
      },
      {
        "Sid": "S3TablesReadAccess",
        "Effect": "Allow",
        "Action": [
          "s3tables:GetTableBucket",
          "s3tables:GetNamespace",
          "s3tables:ListNamespaces",
          "s3tables:GetTable",
          "s3tables:ListTables",
          "s3tables:GetTableData",
          "s3tables:GetTableMetadataLocation"
        ],
        "Resource": [
          "arn:aws:s3tables:us-west-2:069717478125:bucket/rriv-sensor-data",
          "arn:aws:s3tables:us-west-2:069717478125:bucket/rriv-sensor-data/table/*"
        ]
      }
    ]
  }'



  aws iam put-role-policy \
  --role-name snowflake-s3tables-reader \
  --policy-name snowflake-s3tables-access \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "GlueAccess",
        "Effect": "Allow",
        "Action": [
          "glue:GetCatalog",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables"
        ],
        "Resource": "*"
      },
      {
        "Sid": "LakeFormationAccess",
        "Effect": "Allow",
        "Action": [
          "lakeformation:GetDataAccess"
        ],
        "Resource": "*"
      },
      {
        "Sid": "S3TablesReadAccess",
        "Effect": "Allow",
        "Action": [
          "s3tables:GetTableBucket",
          "s3tables:GetNamespace",
          "s3tables:ListNamespaces",
          "s3tables:GetTable",
          "s3tables:ListTables",
          "s3tables:GetTableData",
          "s3tables:GetTableMetadataLocation"
        ],
        "Resource": [
          "arn:aws:s3tables:us-west-2:069717478125:bucket/rriv-sensor-data",
          "arn:aws:s3tables:us-west-2:069717478125:bucket/rriv-sensor-data/table/*"
        ]
      }
    ]
  }'


# From the official documentation, but unnecessary and doesn't work to grant access
# with the next s3tables sigv4 integration
#
#   aws lakeformation grant-permissions \
#   --region us-west-2 \
#   --principal DataLakePrincipalIdentifier=arn:aws:iam::069717478125:role/snowflake-s3tables-reader \
#   --resource '{
#     "Table": {
#       "CatalogId": "069717478125:s3tablescatalog/rriv-sensor-data",
#       "DatabaseName": "timescaledb",
#       "TableWildcard": {}
#     }
#   }' \
#   --permissions "SELECT" "DESCRIBE"



#   aws glue create-catalog \
#   --name s3tablescatalog \
#   --catalog-input '{
#     "Name": "s3tablescatalog",
#     "CatalogInput": {
#       "FederatedCatalog": {
#         "Identifier": "arn:aws:s3tables:us-west-2:069717478125:bucket/*",
#         "ConnectionName": "aws:s3tables"
#       },
#       "AllowFullTableExternalDataAccess": "True"
#     }
#   }'