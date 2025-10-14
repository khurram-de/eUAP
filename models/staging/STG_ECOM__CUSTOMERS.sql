select
    CUSTOMER_ID,
    CUSTOMER_UNIQUE_ID,
    CUSTOMER_ZIP_CODE_PREFIX,
    CUSTOMER_CITY,
    CUSTOMER_STATE,
    _business_date,
    _ingested_at,
    _source_file
from {{ source('ECOM_RAW_STAGING', 'CUSTOMERS') }}