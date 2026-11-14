--Q1-Q3: Monthly sales, orders, AOV and MoM growth
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

-- Q4a: How does each month of 2018 compare with the same month of 2017?
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

-- Q4b: What is the overall Jan-Aug growth, 2018 vs 2017?
with cte1 as (
    select
        to_char(o.order_purchase_timestamp, 'YYYY-MM') as month_of_sale,
        sum(oi.price) as sale_amount
    from orders o
    join order_items oi
        on o.order_id = oi.order_id
    where o.order_status = 'delivered'
      and to_char(o.order_purchase_timestamp, 'YYYY-MM') between '2017-01' and '2018-08'
    group by to_char(o.order_purchase_timestamp, 'YYYY-MM')
),
cte2 as (
    select
        sum(case when left(month_of_sale, 4) = '2017'
                  and right(month_of_sale, 2) between '01' and '08'
                 then sale_amount end) as sales_jan_aug_2017,
        sum(case when left(month_of_sale, 4) = '2018'
                  and right(month_of_sale, 2) between '01' and '08'
                 then sale_amount end) as sales_jan_aug_2018
    from cte1
)
select
    sales_jan_aug_2017,
    sales_jan_aug_2018,
    round((sales_jan_aug_2018 - sales_jan_aug_2017) * 100.0
          / nullif(sales_jan_aug_2017, 0), 2) as yoy_growth_pct
from cte2;