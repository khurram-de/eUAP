-- analysis/01_data_profiling.sql
-- =================================================================
-- DATA PROFILING: ORDERS
-- =================================================================

-- QUESTION 1: Basic Counts
-- How many total rows? How many unique orders? Date range?

select 
    count(*) as total_rows,
    count(distinct order_id) as unique_orders,
    min(order_purchase_timestamp::date) as earliest_order_date,
    max(order_purchase_timestamp::date) as latest_order_date,
    datediff('day', min(order_purchase_timestamp::date), 
             max(order_purchase_timestamp::date)) as date_range_days
from {{ ref('stg_ecom__orders') }}

--result
TOTAL_ROWS,UNIQUE_ORDERS,EARLIEST_ORDER_DATE,LATEST_ORDER_DATE,DATE_RANGE_DAYS
99441,99441,2016-09-04,2018-10-17,773

-----------------------------------------------------------------
-- QUESTION 2: Duplicate Analysis
-- Are there duplicate order_ids? If yes, how many and why?

--result
-- No duplicates as per above query [TOTAL_ROWS = UNIQUE_ORDERS]

----------------------------------------------------------------
-- QUESTION 3: Status Distribution
-- What order statuses exist? How many of each?
select 
    order_status,
    count(*) as count_per_status
from {{ ref('stg_ecom__orders') }}
group by order_status

--result
ORDER_STATUS,COUNT_PER_STATUS
unavailable,609
canceled,625
invoiced,314
approved,2
created,5
shipped,1107
delivered,96478
processing,301

----------------------------------------------------------------

-- QUESTION 4: NULL Analysis
-- Which fields have NULLs? What percentage?
-- Check: order_approved_at, order_delivered_carrier_date, 
--        order_delivered_customer_date

SELECT
    sum(CASE when order_approved_at is null then 1 else 0 end) as order_approved_at_nulls,
    sum(case when order_delivered_carrier_date is null then 1 else 0 end) as order_delivered_carrier_date_nulls,
    sum(case when order_delivered_customer_date is null then 1 else 0 end) as order_delivered_customer_date_nulls
from {{ ref('stg_ecom__orders') }}

ORDER_APPROVED_AT_NULLS,ORDER_DELIVERED_CARRIER_DATE_NULLS,ORDER_DELIVERED_CUSTOMER_DATE_NULLS
160,1783,2965

----------------------------------------------------------------

-- QUESTION 5: Date Logic Validation
-- Are there orders where delivered_date < purchase_date?
-- Are there orders where approved_at is NULL but status = 'delivered'?

select
    sum(case when ORDER_ESTIMATED_DELIVERY_DATE < ORDER_PURCHASE_TIMESTAMP then 1 else 0 end) as invalid_date_logic,
    sum(case when lower(ORDER_STATUS) = 'delivered' and ORDER_APPROVED_AT is null then 1 else 0 end) as invalid_approval_date_logic
from {{ ref('stg_ecom__orders') }}
--result
INVALID_DATE_LOGIC,INVALID_APPROVAL_DATE_LOGIC
0,14

-- =================================================================
-- DATA PROFILING: PAYMENTS
-- =================================================================

-- QUESTION 6: Payment Patterns
-- How many payments per order? (distribution)
-- What's the max number of payments for a single order?

with payment_distribution as(
    select order_id, count(*) as order_cnt
    from raw.ecom.payments
    group by order_id
)
select order_cnt, count(*)
from {{ ref('stg_ecom__payments') }}
payment_distribution
group by 1

--result
ORDER_CNT,COUNT(*)
8,11
3,301
29,1
12,8
19,2
5,52
10,5
6,36
26,1
4,108
11,8
13,3
21,1
1,96479
14,2
2,2382
9,9
7,28
15,2
22,1

-- QUESTION 7: Payment Types
-- What payment types exist? Count each.
select 
    payment_type,
    count(*) as count_per_type
from {{ ref('stg_ecom__payments') }}
group by payment_type

--result
PAYMENT_TYPE,COUNT_PER_TYPE
debit_card,1529
not_defined,3
credit_card,76795
voucher,5775
boleto,19784

-- QUESTION 8: Installment Analysis
-- What's the distribution of payment_installments?
-- Do all payment types allow installments?

select payment_type, count(*)
from {{ ref('stg_ecom__payments') }}
group by 1

--result
PAYMENT_TYPE,COUNT(*)
debit_card,1529
not_defined,3
credit_card,76795
voucher,5775
boleto,19784




-- QUESTION 9: Multi-Payment Orders
-- How many orders use multiple payment TYPES (not installments)?


-- QUESTION 10: Payment vs Order Relationship
-- Are there orders in orders table but NOT in payments?
-- Are there payments with order_ids NOT in orders?