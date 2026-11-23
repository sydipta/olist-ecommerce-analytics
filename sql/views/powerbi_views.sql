create view vw_monthly_sales as 
with cte1 as (select 
	to_char(o.order_purchase_timestamp, 'YYYY-MM') as month_of_sale,
	sum(oi.price) as sale_amount,
	count(distinct o.order_id) as completed_orders,
	(sum(oi.price)/count(distinct o.order_id)) as mon_aov
from orders o
inner join order_items oi
on o.order_id = oi.order_id
where o.order_status = 'delivered' 
and (o.order_purchase_timestamp >= '2017-01-01' and o.order_purchase_timestamp<'2018-09-01')
group by to_char(o.order_purchase_timestamp, 'YYYY-MM')
),
cte2 as (select 
	month_of_sale, 
	sale_amount, 
	completed_orders,
	mon_aov,
	lag(sale_amount) over(order by month_of_sale) as prev_month_sale,
	lag(completed_orders) over(order by month_of_sale) as prev_month_orders,
	lag(mon_aov) over(order by month_of_sale) as prev_month_aov 
from cte1
)

select 
	month_of_sale, 
	sale_amount, 
	completed_orders,
	round(mon_aov, 2)as monthly_aov,
	round((sale_amount - prev_month_sale)*100.0/nullif(prev_month_sale,0),2) as MoM_growth,
	round(
		(completed_orders-prev_month_orders)*100.0/nullif(prev_month_orders,0)
	,2) as order_growth_pct,
	round(
		(mon_aov-prev_month_aov)*100.0/nullif(prev_month_aov,0) 
	,2) as aov_growth_pct
from cte2
order by month_of_sale;

create view vw_monthly_yoy as
with cte1 as(select
	to_char(o.order_purchase_timestamp, 'YYYY-MM') as month_of_sale,
	sum(oi.price) as sale_amount
	from orders o join order_items oi
	on o.order_id = oi.order_id
	where o.order_status = 'delivered'
	and to_char(o.order_purchase_timestamp, 'YYYY-MM') between '2017-01' and '2018-08'
	group by to_char(o.order_purchase_timestamp, 'YYYY-MM')
),
cte2 as (select month_of_sale,
	sale_amount,
	lag(sale_amount, 12) over(order by month_of_sale) as sale_last_year
from cte1)
select 
	month_of_sale,
	sale_amount,
	sale_last_year,
	round((sale_amount-sale_last_year)*100.0/nullif(sale_last_year, 0), 2) as yoy_growth_pct
from cte2
order by month_of_sale;

create view vw_rfm_segments as 
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

create view vw_monthly_delivery as 
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

create view vw_delivery_by_state as
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

create view vw_review_by_delay as
with ranked as (
    select
        order_id,
        review_score,
        row_number() over (partition by order_id order by review_answer_timestamp desc) as rn
    from order_reviews
), cte2 as (
    select
        order_id,
        review_score
    from ranked
    where rn = 1
), cte3 as (
    select
        o.order_id,
        case
            when o.order_estimated_delivery_date::date >= o.order_delivered_customer_date::date
                then '0 on_time'
            when (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) <= 3
                then '1 late 1-3d'
            when (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) <= 7
                then '2 late 4-7d'
            else '3 late 8+d'
        end as delay_bucket,
        r.review_score
    from orders o
    join cte2 r
        on r.order_id = o.order_id
    where o.order_status = 'delivered'
      and o.order_delivered_customer_date is not null
      and to_char(o.order_purchase_timestamp, 'YYYY-MM') between '2017-01' and '2018-08'
)
select
    delay_bucket,
    count(*) as orders,
    round(avg(review_score), 2) as avg_review,
    round(
        count(*) filter (where review_score <= 2) * 100.0 / count(*)
    , 2) as pct_low_review
from cte3
group by 1
order by 1;

select 'vw_monthly_sales' as view_name, count(*) as row_count from vw_monthly_sales
union all select 'vw_monthly_yoy', count(*) from vw_monthly_yoy
union all select 'vw_rfm_segments', count(*) from vw_rfm_segments
union all select 'vw_monthly_delivery', count(*) from vw_monthly_delivery
union all select 'vw_delivery_by_state', count(*) from vw_delivery_by_state
union all select 'vw_review_by_delay', count(*) from vw_review_by_delay;