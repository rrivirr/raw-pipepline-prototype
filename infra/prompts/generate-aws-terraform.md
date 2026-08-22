Generate terraform IaC that creates an AWS IAM role that grants access to the table rriv-sensor-data.     For the terraform backend, use local storage.  Place all generated files in the subfolder 'aws'.  The generated IAM role terraform must be placed in the subfolder iam, as a submodule. Use the same file organization as the terraform found in the folter 'tigercloud.'


The policy to use for the role follows:
{
"Version": "2012-10-17",
"Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion"
         ],
         "Resource": "arn:aws:s3:::<my_bucket>/*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
         ],
         "Resource": "arn:aws:s3:::<my_bucket>",
         "Condition": {
            "StringLike": {
                  "s3:prefix": [
                     "*"
                  ]
            }
         }
      }
]
}
