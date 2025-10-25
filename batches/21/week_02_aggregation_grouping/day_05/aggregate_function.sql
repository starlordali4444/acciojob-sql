-- Total No of Orders
SELECT
    COUNT(*)
FROM
    "sales"."orders"

-- count(*) and count(id)
-- orders
-- id 1 2 3 4 5
-- amount 52 55 56 NULL 55

-- How many customers have provided a age

SELECT
    count(age)
FROM
    "customers"."customers"

SELECT
    *
FROM
    "customers"."customers"
WHERE
    cust_id=3

UPDATE
    customers.customers
SET
    age = 20
WHERE
    cust_id=3

Create TABLE daily.agg_ex_1(
    id int,
    name text
);

INSERT INTO daily.agg_ex_1 VALUES (NULL,NULL)

SELECT * from daily.agg_ex_1;
SELECT count(*) from daily.agg_ex_1;

SELECT
    count(category)
FROM
    products.products

-- How many unique categories are there in the TABLE

SELECT
    COUNT(DISTINCT category) as no_of_unique_categories,
    'Siraj' as my_name,
    VERSION() as psql_version,
    CURRENT_DATE as today_date
FROM
    products.products

-- Count
--     count(*)                    RETURNS count of all available records in the table (including null records)
--     count(<col_name>)           RETURNS count of all non null VALUES
--     count(DISTINCT <col_name>)   RETURNS count of distinct COLUMN VALUES

--=====================================================================
-- SUM
-- Total Revenue

SELECT
    SUM(total_amount) as total_revenue
FROM
    sales.orders

-- Total Revenue Order Status Wise
SELECT
   order_status, SUM(total_amount)
FROM
    sales.orders
GROUP BY
    order_status;

SELECT
    SUM(total_amount)
FROM
    sales.orders
WHERE
    orders.order_status='Delivered';

-- Total Quantity sold per products

SELECT
    prod_id as p_id,SUM(quantity) as total_qty
FROM
    sales.order_items
GROUP BY
    p_id
ORDER BY
    total_qty desc
LIMIT
    5

SELECT
    *
FROM
    customers.customers


-- Count of customer for each combinatio of state and city
SELECT
    state,city,COUNT(cust_id) as no_of_cust
FROM
    customers.customers
GROUP BY
    state,city
ORDER BY
    3 desc

SELECT
    state,city,COUNT(cust_id) as no_of_cust
FROM
    customers.customers
GROUP BY
    1,2
ORDER BY
    3 desc

-- I want to see only those combination where no_of_cust is greater than 500
SELECT
    state,city,COUNT(cust_id) as no_of_cust
FROM
    customers.customers
GROUP BY
    1,2
HAVING 
    COUNT(cust_id)>700
ORDER BY
    3 desc

-- Total total_amount , min total_amount, max total_amount, avg total_amount

SELECT
    *
FROM
    sales.orders

SELECT
    SUM(orders.total_amount),
    min(orders.total_amount),
    max(orders.total_amount),
    avg(orders.total_amount)
FROM
    sales.orders

SELECT
    store_id,
    cust_id,
    SUM(orders.total_amount),
    min(orders.total_amount),
    max(orders.total_amount),
    avg(orders.total_amount)
FROM
    sales.orders
GROUP BY
    store_id,cust_id

-- I want only those combiantion where 
--     min amount is greater than 10000
--     max amount is between 150000,300000
--     which were placed after 01-04-2025

SELECT
    store_id,
    cust_id,
    SUM(orders.total_amount),
    min(orders.total_amount),
    max(orders.total_amount),
    avg(orders.total_amount)
FROM
    sales.orders
WHERE
    orders.order_date > '2025-04-01'
GROUP BY
    store_id,cust_id
HAVING
    (min(orders.total_amount)>100000)
    AND
        (max(orders.total_amount) BETWEEN 150000 AND 300000)


SELECT
    *
FROM
    customers.customers

-- Find the top 5 categories having the highest average price, considering only active products priced > ₹500.

SELECT
    category,
    AVG(price)
FROM
    products.products 
WHERE
    products.price>500
GROUP BY
    products.category
ORDER BY
    AVG(products.price) DESC
LIMIT 5;