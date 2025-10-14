select
	order_id as order_id,
	order_item_id as order_item_id,
	product_id as product_id,
	seller_id as seller_id,
	shipping_limit_date as shipping_limit_date,
	price as price,
	freight_value as freight_value,
    _business_date,
    _ingested_at,
    _source_file
from {{ source('ecom_raw_staging', 'order_items') }}