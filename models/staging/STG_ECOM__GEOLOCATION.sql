select
    geolocation_zip_code_prefix as geolocation_zip_code_prefix,
	geolocation_lat as geolocation_lat,
	geolocation_lng as geolocation_lng,
	geolocation_city as geolocation_city,
	geolocation_state as geolocation_state,
    _business_date,
    _ingested_at,
    _source_file
from {{ source('ecom_raw_staging', 'geolocation') }}