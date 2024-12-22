#!/bin/bash

# Variables
BUCKET_NAME="knapp.hertigcarl.se"  # Replace with your S3 bucket name
AWS_REGION="eu-north-1"       # Replace with your AWS region (e.g., us-east-1)
FILE_PATH="index.html"               # Path to your index.html file

# Check for required dependencies
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it and try again."
    exit 1
fi

# Step 1: Create the S3 bucket
echo "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"

# Step 2: Configure bucket for public access
echo "Configuring the bucket for public access"
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy '{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::'"$BUCKET_NAME"'/*"
    }
  ]
}'

echo "Disabling Block Public Access for the bucket"
aws s3api put-public-access-block --bucket "$BUCKET_NAME" --public-access-block-configuration '{
  "BlockPublicAcls": false,
  "IgnorePublicAcls": false,
  "BlockPublicPolicy": false,
  "RestrictPublicBuckets": false
}'

# Step 3: Upload the index.html file
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: $FILE_PATH not found. Please make sure the file exists and try again."
    exit 1
fi
echo "Uploading $FILE_PATH to S3 bucket"
aws s3 cp "$FILE_PATH" "s3://$BUCKET_NAME/"

# Step 4: Configure