-- Delivery performance analysis (delivered orders, Jan 2017 - Aug 2018)
-- Late order: delivered on a later calendar day than the estimated delivery date.
-- Delivered orders with no delivery date are excluded.


-- Q-a: How does delivery performance change month by month?
with cte1 as (
    select
        to_char(order_purchase_timestamp, 'YYYY-MM') as order_month,
        count(*) as delivered_orders,
        round(
            avg(order_delivered_customer_date::date - order_purchase_timestamp::date)
        , 2) as avg_delivery_days,
        round(
            avg(order_estimated_delivery_date::date - order_purchase_timestamp::date)
        , 2) as avg_estimated_days,
        count(*) filter (
            where order_delivered_customer_date::date > order_estimated_delivery_date::date
        ) as late_orders
    from orders
    where order_status = 'delivered'
      and to_char(order_purchase_timestamp, 'YYYY-MM') between '2017-01' and '2018-08'
      and order_delivered_customer_date is not null
    group by to_char(order_purchase_timestamp, 'YYYY-MM')
)
select *,
    round(late_orders * 100.0 / delivered_orders, 2) as late_pct
from cte1
order by order_month;


-- Q-b: What is the overall delivery performance?
select
    count(*) as delivered_orders,
    round(
        avg(order_delivered_customer_date::date - order_purchase_timestamp::date)
    , 2) as avg_delivery_days,
    round(
        avg(order_estimated_delivery_date::date - order_purchase_timestamp::date)
    , 2) as avg_estimated_days,
    count(*) filter (
        where order_delivered_customer_date::date > order_estimated_delivery_date::date
    ) as late_orders,
    round(
        count(*) filter (
            where order_delivered_customer_date::date > order_estimated_delivery_date::date
        ) * 100.0 / count(*)
    , 2) as late_pct
from orders
where order_status = 'delivered'
  and to_char(order_purchase_timestamp, 'YYYY-MM') between '2017-01' and '2018-08'
  and order_delivered_customer_date is not null;


-- Q-c: Which states have the worst delivery performance?
-- States with fewer than 500 delivered orders are excluded: small samples make late_pct unreliable.
select
    c.customer_state,
    count(*) as delivered_orders,
    round(
        avg(o.order_delivered_customer_date::date - o.order_purchase_timestamp::date)
    , 2) as avg_delivery_days,
    round(
        avg(o.order_estimated_delivery_date::date - o.order_purchase_timestamp::date)
    , 2) as avg_estimated_days,
    count(*) filter (
        where o.order_delivered_customer_date::date > o.order_estimated_delivery_date::date
    ) as late_orders,
    round(
        count(*) filter (
            where o.order_delivered_customer_date::date > o.order_estimated_delivery_date::date
        ) * 100.0 / count(*)
    , 2) as late_pct
from orders o
join customers c
    on o.customer_id = c.customer_id
where o.order_status = 'delivered'
  and to_char(o.order_purchase_timestamp, 'YYYY-MM') between '2017-01' and '2018-08'
  and o.order_delivered_customer_date is not null
group by c.customer_state
having count(*) >= 500
order by late_pct desc;