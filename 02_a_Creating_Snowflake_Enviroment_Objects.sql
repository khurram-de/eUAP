--- 02_a_Creating_Snowflake_Enviroment_Objects.sql
-- This script sets up the Snowflake environment for the e-commerce data warehouse.
-- It creates a dedicated role, warehouse, databases, and schemas.
-- It also creates a user for dbt with the necessary permissions.

-- Use admin privileges
USE ROLE ACCOUNTADMIN;

------------------------------------------------------------
-- 1️⃣  Create a dedicated role for dbt / analytics user   --
------------------------------------------------------------
CREATE ROLE IF NOT EXISTS TRANSFORMER;

------------------------------------------------------------
-- 2️⃣  Create a dedicated warehouse                       --
------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS WH_ECOM
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

-- Grant usage on warehouse to the role
GRANT USAGE ON WAREHOUSE WH_ECOM TO ROLE TRANSFORMER;

------------------------------------------------------------
-- 3️⃣  Create RAW database and schema (for source data)   --
------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS RAW.ECOM;

-- Grant permissions on RAW to TRANSFORMER
GRANT USAGE ON DATABASE RAW TO ROLE TRANSFORMER;
GRANT USAGE ON SCHEMA RAW.ECOM TO ROLE TRANSFORMER;
GRANT SELECT ON ALL TABLES IN SCHEMA RAW.ECOM TO ROLE TRANSFORMER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA RAW.ECOM TO ROLE TRANSFORMER;

------------------------------------------------------------
-- 4️⃣  Create ANALYTICS database and schema (for dbt models)
------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS ANALYTICS;
CREATE SCHEMA IF NOT EXISTS ANALYTICS.ECOM;

-- Grant permissions on ANALYTICS to TRANSFORMER
GRANT USAGE ON DATABASE ANALYTICS TO ROLE TRANSFORMER;
GRANT USAGE ON SCHEMA ANALYTICS.ECOM TO ROLE TRANSFORMER;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ANALYTICS.ECOM TO ROLE TRANSFORMER;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA ANALYTICS.ECOM TO ROLE TRANSFORMER;

------------------------------------------------------------
-- 5️⃣  (Optional) Create a user and assign role           --
------------------------------------------------------------

CREATE USER IF NOT EXISTS DBT_USER
  PASSWORD = '***********************'  -- Replace with a strong password
  DEFAULT_ROLE = TRANSFORMER
  DEFAULT_WAREHOUSE = WH_ECOM
  DEFAULT_NAMESPACE = ANALYTICS.ECOM
  MUST_CHANGE_PASSWORD = FALSE;

GRANT ROLE TRANSFORMER TO USER DBT_USER;

------------------------------------------------------------
-- 6️⃣  (Optional) Allow TRANSFORMER to use the warehouse  --
------------------------------------------------------------
GRANT OPERATE ON WAREHOUSE WH_ECOM TO ROLE TRANSFORMER;
