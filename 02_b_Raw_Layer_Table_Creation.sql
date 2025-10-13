USE ROLE SYSADMIN;

CREATE OR REPLACE TABLE RAW.ECOM.ORDERS (
  order_id varchar NOT NULL,
  customer_id varchar NOT NULL,
  order_status varchar,
  order_purchase_timestamp timestamp,
  order_approved_at timestamp,
  order_delivered_carrier_date timestamp,
  order_delivered_customer_date timestamp,
  order_estimated_delivery_date date
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
  product_width_cm int
);


CREATE OR REPLACE TABLE RAW.ECOM.ORDER_ITEMS (
  order_id varchar NOT NULL,
  order_item_id int NOT NULL,
  product_id varchar NOT NULL,
  seller_id varchar NOT NULL,
  shipping_limit_date timestamp,
  price decimal(10,2),
  freight_value decimal(10,2)
);


CREATE OR REPLACE TABLE RAW.ECOM.SELLERS (
  seller_id varchar NOT NULL,
  seller_zip_code_prefix varchar,
  seller_city varchar,
  seller_state varchar
);


CREATE OR REPLACE TABLE RAW.ECOM.PRODUCT_CATEGORY (
  product_category_name varchar,
  product_category_name_english varchar
);


CREATE OR REPLACE TABLE RAW.ECOM.CUSTOMERS (
  customer_id varchar,
  customer_unique_id varchar,
  customer_zip_code_prefix int,
  customer_city varchar,
  customer_state varchar
);


CREATE OR REPLACE TABLE RAW.ECOM.GEOLOCATION (
  geolocation_zip_code_prefix varchar,
  geolocation_lat varchar,
  geolocation_lng varchar,
  geolocation_city varchar,
  geolocation_state varchar
);


CREATE OR REPLACE TABLE RAW.ECOM.PAYMENTS (
  order_id varchar NOT NULL,
  payment_sequential int NOT NULL,
  payment_type varchar,
  payment_installments int,
  payment_value decimal(10,2)
);


CREATE OR REPLACE TABLE RAW.ECOM.REVIEWS (
  order_id  varchar,
  review_id varchar,
  review_score int,
  review_comment_title varchar,
  review_comment_message varchar,
  review_creation_date timestamp,
  review_answer_timestamp timestamp
);
