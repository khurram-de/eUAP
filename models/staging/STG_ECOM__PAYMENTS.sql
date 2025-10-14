select 
	order_id as order_id,
	payment_sequential as payment_sequential,
	payment_type as payment_type,
	payment_installments as payment_installments,
	payment_value as payment_value,
    _business_date,
    _ingested_at,
    _source_file
from {{ source('ecom_raw_staging', 'payments') }}