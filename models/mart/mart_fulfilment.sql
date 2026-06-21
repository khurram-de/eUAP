{{
    config(
        materialized='table'
    )
}}

select
    date_trunc('week', ORDER_PURCHASE_TIMESTAMP) as start_of_week,
    CUSTOMER_STATE,
    avg(HOURS_TO_APPROVAL) as avg_hours_to_approval,
    avg(APPROVAL_TO_CARRIER_DAYS) as avg_approval_to_carrier_days,
    avg(CARRIER_TO_CUSTOMER_DAYS) as avg_carrier_to_customer_days,
    avg(PURCHASE_TO_CUSTOMER_DAYS) as avg_delivery_duration,
    DIV0NULL(sum(IS_ON_TIME), SUM(case when IS_ON_TIME IS NULL THEN 0 ELSE 1 END )) as on_time_rate,
    count(distinct order_id) as total_orders,
    sum(case order_status_category when 'canceled' then 1 else 0 end) as canceled_orders,
    sum(case order_status_category when 'delivered' then 1 else 0 end) as delivered_orders,
    sum(case order_status_category when 'in_progress' then 1 else 0 end) as in_progress_orders
from {{ref('fct_orders')}}
group by start_of_week, CUSTOMER_STATE