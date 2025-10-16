select 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp
from {{ ref('stg_ecom__orders') }}
qualify row_number() over (partition by order_id order by _business_date desc) = 1