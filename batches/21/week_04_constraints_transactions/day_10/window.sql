No Of orders for each Status

SELECT * from sales.orders

Select order_status,count(order_id)
FROM sales.orders
group by order_status

What is the higest amount in each Order Status

Select order_status,MAX(total_amount)
FROM sales.orders
group by order_status

What is the Second Highest Amount for each order_status


with filtered_customer as (
    SELECT full_name,join_date
    from customers.customers
    limit 10
),
ranked_customer as (
    select 
        *,
        row_number() over(order by join_date) as rnk_asc,
        row_number() over(order by join_date desc) as rnk_desc
    FROM filtered_customer
)
SELECT * FROM ranked_customer where rnk_asc=2

create table daily.ex_window(
    id int,
    dept text,
    salary numeric(10,2)
)


select * from daily.ex_window

Insert into daily.ex_window VALUES 
(1	,'a',	95166),
(2	,'a',	96478),
(3	,'s',	64899),
(4	,'s',	94476),
(5	,'s',	56765),
(6	,'d',	94476),
(7	,'d',	86279),
(8	,'a',	95166),
(9	,'e',	92685),
(10,'e',98356)

SELECT 
    *,
    lag(salary) OVER() as lg_previous,
    lead(salary) OVER() as ld_next,
    row_number() over(ORDER BY salary) as row_n,
    rank() OVER(ORDER BY salary) as rnk,
    dense_rank() OVER(ORDER BY salary) as dense_rnk
FROM
    daily.ex_window





