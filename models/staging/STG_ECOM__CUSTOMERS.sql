select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    _business_date,
    _ingested_at,
    _source_file
from {{ source('ecom_raw_staging', 'customers') }}