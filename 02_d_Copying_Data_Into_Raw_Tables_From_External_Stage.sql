--- Copy data from external stage into raw tables
--- This script copies data from the external stage (S3 bucket) into the raw layer tables in Snowflake.
--- It uses the COPY INTO command to load data from CSV files into the corresponding tables.

USE ROLE SYSADMIN;

COPY INTO RAW.ECOM.CUSTOMERS
FROM (
    SELECT
        $1::string  AS CUSTOMER_ID,
        $2::string  AS CUSTOMER_UNIQUE_ID,
        $3::string  AS CUSTOMER_ZIP_CODE_PREFIX,
        $4::string  AS CUSTOMER_CITY,
        $5::string  AS CUSTOMER_STATE,

        CURRENT_DATE()       AS _business_date,  -- business load date, for test job using current date
        CURRENT_TIMESTAMP()  AS _ingested_at,    -- precise ingestion timestamp
        METADATA$FILENAME    AS _source_file     -- auto filename capture
    FROM @dev_euap_stg/olist_customers_dataset.csv
)
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'ABORT_STATEMENT';



COPY INTO RAW.ECOM.GEOLOCATION
FROM (
    SELECT
        $1::string  AS GEOLOCATION_ZIP_CODE_PREFIX,
        $2::string  AS GEOLOCATION_LAT,
        $3::string  AS GEOLOCATION_LNG,
        $4::string  AS GEOLOCATION_CITY,
        $5::string  AS GEOLOCATION_STATE,

        CURRENT_DATE()       AS _business_date,  -- business load date, for test job using current date
        CURRENT_TIMESTAMP()  AS _ingested_at,    -- precise ingestion timestamp
        METADATA$FILENAME    AS _source_file     -- auto filename capture
    FROM @dev_euap_stg/olist_geolocation_dataset.csv
)
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'ABORT_STATEMENT';




COPY INTO RAW.ECOM.ORDERS
FROM (
    SELECT
        $1::string          AS ORDER_ID,
        $2::string          AS CUSTOMER_ID,
        $3::string          AS ORDER_STATUS,
        $4::timestamp_ntz   AS ORDER_PURCHASE_TIMESTAMP,
        $5::timestamp_ntz   AS ORDER_APPROVED_AT,
        $6::timestamp_ntz   AS ORDER_DELIVERED_CARRIER_DATE,
        $7::timestamp_ntz   AS ORDER_DELIVERED_CUSTOMER_DATE,
        $8::date            AS ORDER_ESTIMATED_DELIVERY_DATE,

        CURRENT_DATE()       AS _business_date,  -- business load date, for test job using current date
        CURRENT_TIMESTAMP()  AS _ingested_at,    -- precise ingestion timestamp
        METADATA$FILENAME    AS _source_file     -- auto filename capture
    FROM @dev_euap_stg/olist_orders_dataset.csv
)
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'ABORT_STATEMENT';




COPY INTO RAW.ECOM.ORDER_ITEMS
FROM (
    SELECT
        $1::string AS ORDER_ID,
        $2::number AS ORDER_ITEM_ID,
        $3::string AS PRODUCT_ID,
        $4::string AS SELLER_ID,
        $5::timestamp_ntz AS SHIPPING_LIMIT_DATE,
        $6::number(10,2) AS PRICE,
        $7::number(10,2) AS FREIGHT_VALUE,

        CURRENT_DATE()       AS _business_date,  -- business load date, for test job using current date
        CURRENT_TIMESTAMP()  AS _ingested_at,    -- precise ingestion timestamp
        METADATA$FILENAME    AS _source_file     -- auto filename capture
    FROM @dev_euap_stg/olist_order_items_dataset.csv
)
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'ABORT_STATEMENT';



COPY INTO RAW.ECOM.PAYMENTS
FROM (
    SELECT
        $1::string AS ORDER_ID,
        $2::number AS PAYMENT_SEQUENTIAL,
        $3::string AS PAYMENT_TYPE,
        $4::number AS PAYMENT_INSTALLMENTS,
        $5::number(10,2) AS PAYMENT_VALUE,

        CURRENT_DATE()       AS _business_date,  -- business load date, for test job using current date
        CURRENT_TIMESTAMP()  AS _ingested_at,    -- precise ingestion timestamp
        METADATA$FILENAME    AS _source_file     -- auto filename capture
    FROM @dev_euap_stg/olist_order_payments_dataset.csv
)
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'ABORT_STATEMENT';



COPY INTO RAW.ECOM.PRODUCTS
FROM (
    SELECT
        $1::string AS PRODUCT_ID,
        $2::string AS PRODUCT_CATEGORY_NAME,
        $3::number(10,2) AS PRODUCT_NAME_LENGTH,
        $4::number(10,2) AS PRODUCT_DESCRIPTION_LENGTH,
        $5::number(10,2) AS PRODUCT_PHOTOS_QTY,
        $6::number(10,2) AS PRODUCT_WEIGHT_G,
        $7::number(10,2) AS PRODUCT_LENGTH_CM,
        $8::number(10,2) AS PRODUCT_HEIGHT_CM,
        $9::number(10,2) AS PRODUCT_WIDTH_CM,

        CURRENT_DATE()       AS _business_date,  -- business load date, for test job using current date
        CURRENT_TIMESTAMP()  AS _ingested_at,    -- precise ingestion timestamp
        METADATA$FILENAME    AS _source_file     -- auto filename capture
    FROM @dev_euap_stg/olist_products_dataset.csv
)
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'ABORT_STATEMENT';




COPY INTO RAW.ECOM.PRODUCT_CATEGORY
FROM (
    SELECT
        $1::string AS PRODUCT_CATEGORY_NAME,
        $2::string AS PRODUCT_CATEGORY_NAME_ENGLISH,

        CURRENT_DATE()       AS _business_date,  -- business load date, for test job using current date
        CURRENT_TIMESTAMP()  AS _ingested_at,    -- precise ingestion timestamp
        METADATA$FILENAME    AS _source_file     -- auto filename capture
    FROM @dev_euap_stg/product_category_name_translation.csv
)
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'ABORT_STATEMENT';


COPY INTO RAW.ECOM.REVIEWS
FROM (
    SELECT
        $1::string AS ORDER_ID,
        $2::string AS REVIEW_ID,
        $3::number AS REVIEW_SCORE,
        $4::string AS REVIEW_COMMENT_TITLE,
        $5::string AS REVIEW_COMMENT_MESSAGE,
        $6::timestamp_ntz AS REVIEW_CREATION_DATE,
        $7::timestamp_ntz AS REVIEW_ANSWER_TIMESTAMP,

        CURRENT_DATE()       AS _business_date,  -- business load date, for test job using current date
        CURRENT_TIMESTAMP()  AS _ingested_at,    -- precise ingestion timestamp
        METADATA$FILENAME    AS _source_file     -- auto filename capture
    FROM @dev_euap_stg/olist_order_reviews_dataset.csv
)
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'ABORT_STATEMENT';



COPY INTO RAW.ECOM.SELLERS
FROM (
    SELECT
        $1::string AS SELLER_ID,
        $2::string AS SELLER_ZIP_CODE_PREFIX,
        $3::string AS SELLER_CITY,
        $4::string AS SELLER_STATE,

        CURRENT_DATE()       AS _business_date,  -- business load date, for test job using current date
        CURRENT_TIMESTAMP()  AS _ingested_at,    -- precise ingestion timestamp
        METADATA$FILENAME    AS _source_file     -- auto filename capture
    FROM @dev_euap_stg/olist_sellers_dataset.csv
)
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'ABORT_STATEMENT';