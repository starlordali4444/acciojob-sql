Find products that were NEVER purchased

INSERT INTO products.products
VALUES(1217,'Demo Product','Grocery','Tata',45,12222)

Select 
    prod_id
from 
    products.products
EXCEPT
SELECT DISTINCT prod_id
FROM
    sales.order_items

Find employees NOT present in the attendance log for a date range

select emp_id  from stores.employees
except
select distinct emp_id from hr.attendance
WHERE "date" BETWEEN '2025-06-01' and '2025-06-07'

select * from hr.attendance


Find customers who ordered in Q1 but NOT in Q2

Select * from sales.orders

Date Time Function.
    Date
    YEAR
    Month
    weekday
    weeknum
    day
    HOUR
    minute
    second
    EXTRACT

select 
    distinct order_date,
    extract(year from order_date) as year,
    EXTRACT(month from order_date) as month,
    EXTRACT(day from order_date) as day
from sales.orders
LIMIT 10

SELECT current_date;

SELECT current_timestamp;
select now();
SELECT LOCALTIMESTAMP;

SELECT
    extract(year from CURRENT_TIMESTAMP) as year,
    extract(quarter from CURRENT_TIMESTAMP) as quarter,
    extract(month from CURRENT_TIMESTAMP) as month,
    extract(day from CURRENT_TIMESTAMP) as day,
    extract(hour from CURRENT_TIMESTAMP) as hour,
    extract(minute from CURRENT_TIMESTAMP) as minute,
    extract(second from CURRENT_TIMESTAMP) as second,
    extract(dow from CURRENT_TIMESTAMP) as day_of_week,
    extract(doy from CURRENT_TIMESTAMP) as day_of_year

Find customers who ordered in Q1 but NOT in Q2

SELECT DISTINCT cust_id
from sales.orders
WHERE extract(quarter from order_date)=1 and extract(year from order_date)=2025
except
SELECT DISTINCT cust_id
from sales.orders
WHERE extract(quarter from order_date)=2 and extract(year from order_date)=2025


==================================================================================

Marketing wants a list of active customers (those who actually made purchases).
Find customers who placed at least one order

select cust_id
from customers.customers
EXCEPT
select distinct cust_id
from sales.orders

select cust_id,full_name
from customers.customers
WHERE
cust_id not in (
    select distinct cust_id
    from sales.orders
)

select cust_id,full_name
from customers.customers c
WHERE
EXISTS (
    select 1
    from sales.orders o
    WHERE o.cust_id=c.cust_id
)

Find customers with delivered orders (NOT pending)

SELECT * from sales.orders

Select 
    c.cust_id,c.full_name
from customers.customers c
WHERE EXISTS (
    select 1
    from sales.orders o
    WHERE o.cust_id=c.cust_id
    and o.order_status ='Delivered'
)

select DISTINCT order_status from sales.orders

Select 
    c.cust_id
from customers.customers c
EXCEPT
select cust_id
from sales.orders o
WHERE o.order_status not in ('Shipped','Returned','Cancelled')

select order_status,count(DISTINCT cust_id)
from sales.orders
group by order_status

select 26438-23562

select distinct cust_id,order_status
from sales.orders o
order by 1,2

delivered 25 20
shipped 20 15
cancelled 25 10
returned 20 20
cust_id 90

OR , AND we use with column => Scalar

ANY,ALL,Except,Exist =>  2 D => Table


IN Operator: Returns TRUE if a value matches ANY value in a list or subquery result set.

Syntax: WHERE column IN (value1, value2, ...) OR WHERE column IN (SELECT ...)
Returns: TRUE/FALSE based on membership

ANY Operator: Compares a value to ANY value in a subquery using a comparison operator.

Syntax: WHERE column > ANY (SELECT ...) or WHERE column = ANY (SELECT ...)
More flexible than IN - allows comparisons other than equality
Can use: =, <>, <, >, <=, >=

ALL Operator: Compares a value to ALL values in a subquery using a comparison operator.

Syntax: WHERE column > ALL (SELECT ...) - "greater than every value"
More restrictive than ANY - must satisfy condition with EVERY value
Can use: =, <>, <, >, <=, >=

Find all customers who have made at least ONE purchase larger than ANY 500,1000,1500 amounts.

500,1000,1500

total_amount    => total_amount in ()

total_amount > 500 or total_amount>1000 or total_amount > 1500

select c.cust_id,c.full_name
FROM customers.customers c
where c.cust_id in (
    SELECT o.cust_id
    from sales.orders o
    where o.total_amount > any(array[500,1000,1500])
)

SELECT distinct o.cust_id
    from sales.orders o
    where o.total_amount > any(array[500,1000,1500])


SELECT distinct o.cust_id
    from sales.orders o
    where o.total_amount > all(array[500,1000,1500])


SELECT distinct o.cust_id
    from sales.orders o
    where o.total_amount > all(array[1500])





Find products priced higher than ALL budget category products.

select * from products.products
where category='Beauty'
order by price desc

select distinct category from products.products
where category='Budget'

select prod_id,prod_name,price,category
from products.products
where price > ALL(
    select price from products.products where category='Beauty'
)

select prod_id,prod_name,price,category
from products.products
where price > (
    select max(price) from products.products where category='Beauty'
)

Find stores with above-average revenue
    Find stores whose total sales exceeded the average sales of their region.

Do we have store wise total_amount

SELECT * from sales.orders

with store_wise_total_sales as(
    select store_id,sum(total_amount) as store_sales
    FROM sales.orders
    group by store_id
    order by store_id
),
region_wise_avg_sales as (
    select s.region,avg(o.total_amount) as region_avg
    from stores.stores s
    JOIN sales.orders o
    on o.store_id=s.store_id
    group by s.region
)
select s.store_id,s.store_name,ss.store_sales,rs.region_avg
from stores.stores s
join store_wise_total_sales ss
on s.store_id=ss.store_id
JOIN region_wise_avg_sales rs 
on s.region=rs.region and ss.store_sales > rs.region_avg


Find stores whose total sales exceeded the average sales of any region.
select s.store_id,s.store_name,s.region
from stores.stores s
WHERE
    s.store_id in (
        select o.store_id
        from sales.orders o
        group by o.store_id
        HAVING SUM(o.total_amount)> any(
            select regional_sales
            FROM (
                select s2.region,avg(o2.total_amount) as regional_sales
                from sales.orders o2
                JOIN stores.stores s2 
                on o2.store_id = s2.store_id
                GROUP BY s2.region
            ) regional
        )
    )

select s.store_id,s.store_name,s.region
from stores.stores s
WHERE
    s.store_id in (
        select o.store_id
        from sales.orders o
        group by o.store_id
        HAVING SUM(o.total_amount)> any(
            select regional_sales
            FROM (
                select s2.region,avg(o2.total_amount) as regional_sales
                from sales.orders o2
                JOIN stores.stores s2 
                on o2.store_id = s2.store_id and s2.region =s.region
                GROUP BY s2.region
            ) regional
        )
    )