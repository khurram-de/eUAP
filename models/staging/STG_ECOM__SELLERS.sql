select 
	seller_id as seller_id,
	seller_zip_code_prefix as seller_zip_code_prefix,
	upper(trim(seller_city)) as seller_city,
	upper(trim(seller_state)) as seller_state,
    _business_date,
    _ingested_at,
    _source_file
from {{ source('ecom_raw_staging', 'sellers') }}