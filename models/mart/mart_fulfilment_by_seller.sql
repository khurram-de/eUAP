{{
    config(
        materialized='table'
    )
}}

with seller_attributes as(
    select 
    distinct
    order_id,
    seller_state
    from {{ ref('fct_order_items') }}
    -- qualify row_number() over(partition by order_id, seller_state order by order_id desc) = 1
), 
sellers_orders as (
    select 
    o.order_id,
    o.order_purchase_timestamp,
    o.order_status,
    o.hours_to_approval,
    o.approval_to_carrier_days,
    o.carrier_to_customer_days,
    o.purchase_to_customer_days,
    o.is_on_time,
    o.order_status_category,
    oi.seller_state 
    from {{ ref('fct_orders') }} o
    left join seller_attributes oi
        on o.order_id = oi.order_id
)
    select 
        date_trunc('week', ORDER_PURCHASE_TIMESTAMP) as start_of_week,
        seller_state,
        avg(HOURS_TO_APPROVAL) as avg_hours_to_approval,
        avg(APPROVAL_TO_CARRIER_DAYS) as avg_approval_to_carrier_days,
        avg(CARRIER_TO_CUSTOMER_DAYS) as avg_carrier_to_customer_days,
        avg(PURCHASE_TO_CUSTOMER_DAYS) as avg_delivery_duration,
        DIV0NULL(sum(IS_ON_TIME), SUM(case when IS_ON_TIME IS NULL THEN 0 ELSE 1 END )) as on_time_rate,
        count(distinct order_id) as total_orders,
        sum(case order_status_category when 'canceled' then 1 else 0 end) as canceled_orders,
        sum(case order_status_category when 'delivered' then 1 else 0 end) as delivered_orders,
        sum(case order_status_category when 'in_progress' then 1 else 0 end) as in_progress_orders
    from sellers_orders
    group by start_of_week, seller_state