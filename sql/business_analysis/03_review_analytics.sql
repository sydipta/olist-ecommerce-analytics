-- Review analytics (delivered orders with a review, Jan 2017 - Aug 2018)
-- Late order: delivered on a later calendar day than the estimated delivery date.
-- Low review: review_score of 1 or 2.
-- Rule: orders with multiple reviews keep only the latest review (by review_answer_timestamp).


-- Q1: How many orders have more than one review?
with cte1 as (
    select
        order_id,
        count(*) as reviews
    from order_reviews
    group by order_id
)
select count(*) as orders_with_mul_review
from cte1
where reviews > 1;

-- Total reviewed orders (denominator for Q1)
select count(distinct order_id) as total_reviewed_orders
from order_reviews;


-- Q1b: Verify that deduplication leaves one review per order (expect 98,673 and 98,673).
with ranked as (
    select
        order_id,
        review_score,
        row_number() over (partition by order_id order by review_answer_timestamp desc) as rn
    from order_reviews
)
select
    count(*) as rows_kept,
    count(distinct order_id) as distinct_orders
from ranked
where rn = 1;


-- Q2: Do late orders get lower reviews?
-- Inner join: delivered orders without a review are excluded.
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
        case when o.order_estimated_delivery_date::date < o.order_delivered_customer_date::date
             then 'late' else 'on_time'
        end as delivery_status,
        r.review_score
    from orders o
    join cte2 r
        on r.order_id = o.order_id
    where o.order_status = 'delivered'
      and o.order_delivered_customer_date is not null
      and to_char(o.order_purchase_timestamp, 'YYYY-MM') between '2017-01' and '2018-08'
)
select
    delivery_status,
    count(*) as orders,
    round(avg(review_score), 2) as avg_review,
    round(
        count(*) filter (where review_score <= 2) * 100.0 / count(*)
    , 2) as pct_low_review
from cte3
group by delivery_status
order by delivery_status;


-- Q3: How does review score change with how late the delivery is?
-- Inner join: delivered orders without a review are excluded.
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