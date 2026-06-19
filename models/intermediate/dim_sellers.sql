{{ config(materialized='table') }}
select 
    seller_id,
    {{ dbt_utils.generate_surrogate_key(['seller_id','dbt_valid_from']) }} as seller_record_id,
    seller_zip_code_prefix,
    seller_state,
    seller_city,
    dbt_valid_from,
    dbt_valid_to,
    case
        when dbt_valid_to = to_date('9999-12-31') then true
        else false
    end as is_current 
    from
    {{ref('sellers_snapshot')}}
