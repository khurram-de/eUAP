select
	product_id as product_id,
	upper(trim(product_category_name)) as product_category_name,
	product_name_length as product_name_length,
	product_description_length as product_description_length,
	product_photos_qty as product_photos_qty,
	product_weight_g as product_weight_g,
	product_length_cm as product_length_cm,
	product_height_cm as product_height_cm,
	product_width_cm as product_width_cm,
    _business_date,
    _ingested_at,
    _source_file
from {{ source('ecom_raw_staging', 'products') }}