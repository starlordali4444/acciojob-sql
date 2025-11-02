Find total orders per customer using a CTE.

with customer_orders as (
    select
        cust_id,count(order_id) as total_orders
    FROM
        sales.orders
    GROUP BY
        cust_id
)
select * from customer_orders

Top 3 stores by revenue.

select store_id,sum(total_amount) as revenue
FROM sales.orders
GROUP BY store_id
order by revenue desc
LIMIT 3

with store_revenue as (
    select store_id,sum(total_amount) as revenue
    FROM sales.orders
    GROUP BY store_id
)
SELECT * 
FROM store_revenue
order by revenue DESC
limit 3

with store_revenue as (
    select store_id,sum(total_amount) as revenue
    FROM sales.orders
    GROUP BY store_id
),
top_stores as (
    select * from store_revenue
    ORDER BY revenue
),
top_3 as (
    select * from top_stores
    limit 3
)
SELECT * 
FROM top_3