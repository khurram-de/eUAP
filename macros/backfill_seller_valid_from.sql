{% macro backfill_seller_valid_from() %}

  {% set update_query %}
    update {{ var('ecom_analytics_database') }}.{{ var('ecom_analytics_snapshot_schema') }}.sellers_snapshot s
    set dbt_valid_from = first_orders.first_order_date
    from (
        select 
            oi.seller_id,
            min(o.order_purchase_timestamp) as first_order_date
        from {{ ref('stg_ecom__order_items') }} oi
        inner join {{ ref('stg_ecom__orders') }} o
            on oi.order_id = o.order_id
        group by oi.seller_id
    ) first_orders
    where s.seller_id = first_orders.seller_id
  {% endset %}

  {% do run_query(update_query) %}

  {{ log("Backfill complete", info=True) }}

{% endmacro %}