{{
    config(
        materialized= 'incremental',
        unique_key= ['order_id', 'order_item_id']
    )
}}

with order_items as (
    select 
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price,
        freight_value,
        _business_date
    from {{ ref('stg_ecom__order_items') }}
),
orders as (
    select 
        order_id,
        order_purchase_timestamp 
    from {{ ref('stg_ecom__orders') }}
    qualify row_number() over (partition by order_id order by _business_date desc) = 1
    )

select 
    -- order item attributes:
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.shipping_limit_date,
    oi.price,
    oi.freight_value,

    -- order attributes for correct historical state.
    o.order_purchase_timestamp,

    -- Seller attributed (seller region, etc.) 
    s.seller_zip_code_prefix,
    s.seller_state,
    s.seller_city,

    -- Business date for incremental processing:
    oi._business_date

    
from order_items oi

left join orders o
    on oi.order_id = o.order_id

left join {{ref('dim_sellers')}} s
    on oi.seller_id = s.seller_id
    and o.order_purchase_timestamp >= s.dbt_valid_from
    and o.order_purchase_timestamp < s.dbt_valid_to

{% if is_incremental() %}
where _business_date > (select dateadd(day, -3, max(t._business_date)) from {{ this }} as t)
-- we are loading Olist data therefore using _business_date from order_items, 
-- but in a real scenario we would use the most appropriate date for incremental loading
-- (e.g. order_purchase_timestamp or order_approved_at).
{% endif %}
