select 
    order_id,
    count(*) as payment_installments_count,
    sum(payment_value) as total_payment_value,
    max_by(payment_type, payment_value) as primary_payment_method_key,
    count(distinct payment_type) as distinct_payment_methods_count,
    count(distinct payment_type) > 1 as is_split_payment,
    sum(case when payment_type = 'credit_card' then payment_value else 0 end) as credit_card_amount,
    sum(case when payment_type = 'boleto' then payment_value else 0 end) as boleto_amount,
    sum(case when payment_type = 'voucher' then payment_value else 0 end) as voucher_amount,
    sum(case when payment_type = 'debit_card' then payment_value else 0 end) as debit_card_amount,
    
    max(_business_date) as latest_business_date
    
from {{ ref('stg_ecom__payments') }}
group by order_id