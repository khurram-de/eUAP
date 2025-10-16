select distinct
    payment_type as payment_method_key,
    case payment_type
        when 'credit_card' then 'Credit Card'
        when 'boleto' then 'Boleto Bancário'
        when 'voucher' then 'Voucher'
        when 'debit_card' then 'Debit Card'
        else initcap(payment_type)
    end as payment_method_name,
    
    case payment_type
        when 'credit_card' then 'Card Payment'
        when 'debit_card' then 'Card Payment'
        when 'boleto' then 'Bank Transfer'
        when 'voucher' then 'Digital Payment'
        else 'Other'
    end as payment_category,
    
    case payment_type
        when 'credit_card' then true
        when 'voucher' then true
        else false
    end as allows_installments
    
from {{ ref('stg_ecom__payments') }}