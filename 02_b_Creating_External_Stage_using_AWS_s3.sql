--- 02_a_Creating_External_Stage_using_AWS_s3.sql
-- This script creates an external stage in Snowflake to connect to an AWS S3 bucket.
-- It uses a storage integration for secure access.
-- Replace the STORAGE_AWS_ROLE_ARN and URL with your actual AWS IAM role ARN and S3 bucket path.

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION sf_euap_s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::****************:role/*****************'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('s3://e-commerce-unified-analytics-platform/');

DESCRIBE INTEGRATION sf_euap_s3_integration;

---> creating External Stage with above integration
CREATE OR REPLACE STAGE dev_euap_stg
  URL = 's3://e-commerce-unified-analytics-platform/euap_dev'
  STORAGE_INTEGRATION = sf_euap_s3_integration;

---> List Named External Stage
ls @dev_euap_stg


