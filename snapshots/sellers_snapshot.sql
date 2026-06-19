{% snapshot sellers_snapshot %}
    {{ config(
        target_database=var('ecom_analytics_database'),
        target_schema=var('ecom_analytics_snapshot_schema'),
        strategy='check',
        unique_key='seller_id',
        check_cols=['seller_zip_code_prefix', 'seller_city', 'seller_state'],
        dbt_valid_to_current="to_date('9999-12-31')"
    ) }}
    
    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state,
        _business_date

    from {{ ref('stg_ecom__sellers') }}

{% endsnapshot %}