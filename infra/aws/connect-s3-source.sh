aws iam create-role \
  --role-name timescale-s3-role-rriv-corrected-raw \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::142548018081:role/timescale-s3-connections"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringLike": {
            "sts:ExternalId": "cd63s5urs1/soacxtauxx"
          }
        }
      }
    ]
  }'


aws iam put-role-policy \
  --role-name timescale-s3-role-rriv-corrected-raw \
  --policy-name S3AccessPolicy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::rriv-corrected-raw",
          "arn:aws:s3:::rriv-corrected-raw/*"
        ]
      }
    ]
  }'



aws iam put-role-policy \
  --role-name timescale-s3-role-rriv-corrected-raw \
  --policy-name S3AccessPolicy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::rriv-corrected-raw",
          "arn:aws:s3:::rriv-corrected-raw/*"
        ]
      }
    ]
  }'
