{{
    config(
        materialized='incremental',
        unique_key='order_id',
        on_schema_change='append_new_columns'
    )
}}

with orders as (
    select 
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        _business_date
    from {{ ref('stg_ecom__orders') }}
    qualify row_number() over (partition by order_id order by _business_date desc) = 1
), 
customers as (
    select 
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    from {{ ref('stg_ecom__customers') }}
    qualify row_number() over (partition by customer_id order by _business_date desc) = 1
)

select 
    -- Order attributes:
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- derived attributes:
    DATEDIFF( hour, o.order_purchase_timestamp, o.order_approved_at ) as hours_to_approval,
    DATEDIFF( day, o.order_approved_at, o.order_delivered_carrier_date ) as approval_to_carrier_days,
    DATEDIFF( day, o.order_delivered_carrier_date, o.order_delivered_customer_date ) as carrier_to_customer_days,
    DATEDIFF( day, o.order_purchase_timestamp, o.order_delivered_customer_date ) as purchase_to_customer_days,
    CASE
        WHEN o.order_status = 'canceled' THEN NULL
        WHEN o.order_delivered_customer_date IS NULL THEN NULL
        -- NOTE: in a live system, this branch would also flag undelivered
        -- orders as overdue once their estimated delivery date plus a
        -- configurable lag buffer has passed, e.g.:
        -- WHEN order_estimated_delivery_date < dateadd(day, -2, current_timestamp())
        --      AND order_delivered_customer_date IS NULL THEN 0
        -- Not implemented as live logic here because Olist is a static
        -- historical dataset — every order is already in a final state
        -- (delivered or cancelled), so this branch is untestable.
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1
        ELSE 0
    END as is_on_time,

    CASE
        WHEN o.order_status = 'canceled' THEN 'canceled'
        WHEN o.order_status = 'delivered' THEN 'delivered'
        ELSE 'in_progress'
    END as order_status_category,

    -- Foreign Keys to dimensions:
    o.customer_id,  -- FK to dim_customers
    p.primary_payment_method_key,  -- FK to dim_payment_methods
    
    -- Customer attributes (or remove if using proper dim):
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,

    -- Payment measures:
    p.total_payment_value,
    p.payment_installments_count,
    p.distinct_payment_methods_count,
    p.is_split_payment,
    p.credit_card_amount,
    p.boleto_amount,
    p.voucher_amount,
    p.debit_card_amount,

    -- Business date for incremental processing:
    o._business_date
    
from orders o
left join {{ ref('int_payments_aggregated') }} p 
    on o.order_id = p.order_id
left join customers c 
    on o.customer_id = c.customer_id

{% if is_incremental() %}
where o._business_date > (select dateadd(day, -3, max(t._business_date)) from {{ this }} as t)
-- we are loading Olist data therefore using _business_date from orders, 
-- but in a real scenario we would use the most appropriate date for incremental loading
-- (e.g. order_purchase_timestamp or order_approved_at).
{% endif %}
