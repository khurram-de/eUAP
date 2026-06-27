WITH DEFAULT_CURRENT_DATE as(
    select 
        max(ORDER_PURCHASE_TIMESTAMP) as CURRENTDATE
    from {{ref('fct_orders')}}
), MART_STATS as(
    select 
        start_of_week,
        customer_state,
        total_orders
    from {{ref('mart_fulfilment')}}
    join DEFAULT_CURRENT_DATE
    on 1 = 1
    where start_of_week in(
        date_trunc('week', DEFAULT_CURRENT_DATE.CURRENTDATE),
        date_trunc('week', dateadd('day', -7, DEFAULT_CURRENT_DATE.CURRENTDATE))
    )
), FCT_ORDERS_STATS as (
    select
        date_trunc('week', ORDER_PURCHASE_TIMESTAMP) as start_of_week,
        customer_state,
        count(distinct order_id) as total_orders
        from {{ref('fct_orders')}}
        join DEFAULT_CURRENT_DATE
        on 1 = 1
        where date_trunc('week', ORDER_PURCHASE_TIMESTAMP) in(
            date_trunc('week', DEFAULT_CURRENT_DATE.CURRENTDATE),
            date_trunc('week',  dateadd('day', -7, DEFAULT_CURRENT_DATE.CURRENTDATE))
        )
        group by start_of_week, customer_state
) select 
    f.start_of_week,
    f.customer_state,
    f.total_orders as ORDER_COUNT_FROM_FCT_ORDERS,
    m.total_orders as ORDER_COUNT_FROM_MART_FULFILLMENT 
    from MART_STATS m
    FULL OUTER JOIN FCT_ORDERS_STATS f
    on m.start_of_week = f.start_of_week
    and m.customer_state = f.customer_state
    where
        f.total_orders IS DISTINCT FROM m.total_orders