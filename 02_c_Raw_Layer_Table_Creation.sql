--- 02_b_Raw_Layer_Table_Creation.sql
-- This script creates the raw layer tables for the ECOM data warehouse.
-- It defines the schema for each table based on the source data structure.
-- Adjust data types and constraints as necessary to fit the actual data.
-- Added _business_date, _ingested_at, and _source_file are metadata columns for tracking.

USE ROLE SYSADMIN;

CREATE OR REPLACE TABLE RAW.ECOM.ORDERS (
  order_id varchar NOT NULL,
  customer_id varchar NOT NULL,
  order_status varchar,
  order_purchase_timestamp timestamp,
  order_approved_at timestamp,
  order_delivered_carrier_date timestamp,
  order_delivered_customer_date timestamp,
  order_estimated_delivery_date date,
  _business_date date,
  _ingested_at timestamp,
  _source_file string 
);


CREATE OR REPLACE TABLE RAW.ECOM.PRODUCTS (
  product_id varchar NOT NULL,
  product_category_name varchar,
  product_name_length int,
  product_description_length int,
  product_photos_qty int,
  product_weight_g int,
  product_length_cm int,
  product_height_cm int,
  product_width_cm int,
  _business_date date,
  _ingested_at timestamp,
  _source_file string 
);



CREATE OR REPLACE TABLE RAW.ECOM.ORDER_ITEMS (
  order_id varchar NOT NULL,
  order_item_id int NOT NULL,
  product_id varchar NOT NULL,
  seller_id varchar NOT NULL,
  shipping_limit_date timestamp,
  price decimal(10,2),
  freight_value decimal(10,2),
  _business_date date,
  _ingested_at timestamp,
  _source_file string 
);


CREATE OR REPLACE TABLE RAW.ECOM.SELLERS (
  seller_id varchar NOT NULL,
  seller_zip_code_prefix varchar,
  seller_city varchar,
  seller_state varchar,
  _business_date date,
  _ingested_at timestamp,
  _source_file string 
);


CREATE OR REPLACE TABLE RAW.ECOM.PRODUCT_CATEGORY (
  product_category_name varchar,
  product_category_name_english varchar,
  _business_date date,
  _ingested_at timestamp,
  _source_file string 
);


CREATE OR REPLACE TABLE RAW.ECOM.CUSTOMERS (
  customer_id varchar,
  customer_unique_id varchar,
  customer_zip_code_prefix varchar,
  customer_city varchar,
  customer_state varchar,
  _business_date date,
  _ingested_at timestamp,
  _source_file string 
);


CREATE OR REPLACE TABLE RAW.ECOM.GEOLOCATION (
  geolocation_zip_code_prefix varchar,
  geolocation_lat varchar,
  geolocation_lng varchar,
  geolocation_city varchar,
  geolocation_state varchar,
  _business_date date,
  _ingested_at timestamp,
  _source_file string 
);



CREATE OR REPLACE TABLE RAW.ECOM.PAYMENTS (
  order_id varchar NOT NULL,
  payment_sequential int NOT NULL,
  payment_type varchar,
  payment_installments int,
  payment_value decimal(10,2),
  _business_date date,
  _ingested_at timestamp,
  _source_file string 
);


CREATE OR REPLACE TABLE RAW.ECOM.REVIEWS (
  order_id  varchar,
  review_id varchar,
  review_score int,
  review_comment_title varchar,
  review_comment_message varchar,
  review_creation_date timestamp,
  review_answer_timestamp timestamp,
  _business_date date,
  _ingested_at timestamp,
  _source_file string 
);
