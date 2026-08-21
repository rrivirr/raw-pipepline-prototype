aws cloudformation create-stack \
  --capabilities CAPABILITY_IAM \
  --template-url https://tigerlake.s3.us-east-1.amazonaws.com/tigerlake-connect-cloudformation.yaml \
  --region "us-west-2" \
  --stack-name "rriv-sensor-data-tables" \
  --parameters \
    ParameterKey=BucketName,ParameterValue="rriv-sensor-data" \
    ParameterKey=ProjectID,ParameterValue="cd63s5urs1" \
    ParameterKey=ServiceID,ParameterValue="soacxtauxx"

aws cloudformation describe-stacks --stack-name "rriv-sensor-data-tables" --region "us-west-2"
