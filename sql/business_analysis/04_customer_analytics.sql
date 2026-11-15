-- Customer analytics (delivered orders, Jan 2017 - Aug 2018)
-- Customers are identified by customer_unique_id (customer_id is created per order).
-- Repeat customer: more than one delivered order inside the period.


-- Q1: How many customers place more than one order?
with cte1 as (
    select
        c.customer_unique_id,
        count(o.order_id) as orders
    from customers c
    join orders o
        on c.customer_id = o.customer_id
    where o.order_status = 'delivered'
      and to_char(o.order_purchase_timestamp, 'YYYY-MM') between '2017-01' and '2018-08'
    group by 1
)
select
    count(*) as total_customers,
    count(*) filter (where orders > 1) as repeat_customers,
    round(count(*) filter (where orders > 1) * 100.0 / count(*), 2) as pct_repeat_customers
from cte1;


-- Q2: How much of the sales come from repeat customers?
with cte1 as (
    select
        c.customer_unique_id,
        count(distinct o.order_id) as orders,
        sum(oi.price) as sales
    from customers c
    join orders o
        on c.customer_id = o.customer_id
    join order_items oi
        on oi.order_id = o.order_id
    where o.order_status = 'delivered'
      and to_char(o.order_purchase_timestamp, 'YYYY-MM') between '2017-01' and '2018-08'
    group by 1
)
select
    case when orders = 1 then 'one-time' else 'repeat' end as ordering_customers,
    count(*) as no_of_customers,
    sum(sales) as sales,
    round(sum(sales) * 100.0 / sum(sum(sales)) over (), 2) as pct_of_sales,
    round(sum(sales) / count(*), 2) as avg_sales_per_customer
from cte1
group by 1
order by 1;


-- Q3: RFM segments
-- Recency: days from the last order to 2018-09-01. Frequency: delivered orders. Monetary: product spend.
-- r_score and m_score: NTILE(5), 5 = best. f_score: 1, 2 or 3+ orders (97% of customers have one order).
-- Segment rules (first match wins):
--   repeat_customers = f_score >= 2; recent_big_spenders = r_score >= 4 and m_score >= 4;
--   lapsed = r_score <= 2; everything else = regular.
-- Note: NTILE splits ties by position, so customers with identical spend can get different
-- scores at group boundaries. The customer_unique_id tiebreaker makes the result repeatable.
with cte as (
    select
        c.customer_unique_id,
        '2018-09-01'::date - max(o.order_purchase_timestamp)::date as recency_days,
        count(distinct o.order_id) as frequency,
        sum(oi.price) as monetary
    from customers c
    join orders o
        on c.customer_id = o.customer_id
    join order_items oi
        on oi.order_id = o.order_id
    where o.order_status = 'delivered'
      and to_char(o.order_purchase_timestamp, 'YYYY-MM') between '2017-01' and '2018-08'
    group by 1
),
scored as (
    select *,
        ntile(5) over (order by recency_days desc, customer_unique_id) as r_score,
        case
            when frequency = 1 then 1
            when frequency = 2 then 2
            else 3
        end as f_score,
        ntile(5) over (order by monetary, customer_unique_id) as m_score
    from cte
)
select
    case
        when f_score >= 2 then 'repeat_customers'
        when r_score >= 4 and m_score >= 4 then 'recent_big_spenders'
        when r_score <= 2 then 'lapsed'
        else 'regular'
    end as segment,
    count(*) as customers,
    round(count(*) * 100.0 / sum(count(*)) over (), 2) as pct_of_customers,
    round(sum(monetary), 2) as total_monetary,
    round(avg(monetary), 2) as avg_monetary
from scored
group by 1
order by 1;