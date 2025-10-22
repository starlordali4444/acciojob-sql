-- Select all the rows of Products TABLE

-- Switch SCHEMA
SET SEARCH_PATH to products;

-- Show the selected SCHEMA
show search_path;

-- Two ways to acces the TABLES
--     1 => Change the schema using set search_path to <schema_name>.

SELECT
    *
FROM
    products;

--     2=> Use <schema_name>.<table_name> while retriving the records.

SELECT
    * --> to select all the columns
FROM
    products.products;

-- Select only prod_name,category,price

SELECT
    prod_name,
    category,
    price
FROM
    products.products;

-- Select only those product where price is greater than 2000

SELECT
    *
FROM
    products.products
WHERE
    price > 2000;

-- Select only those products where Category is Electronics and price is greater than 10000

SELECT
    *
FROM
    products.products
WHERE
    category = 'Electronics'
    AND
        price>10000;

-- Select customers from Delhi Or Mumbai or leh or Gaya or Vadodara

SELECT
    *
FROM
    "customers"."customers"
WHERE
    city = 'Delhi' or city = 'Mumbai';


SELECT
    *
FROM
    "customers"."customers"
WHERE
    city = 'Delhi' or city = 'Mumbai' or city = 'Leh' or city = 'Gaya' or city = 'Vadodara';

-- Obtimised used In Clause
SELECT
    *
FROM
    "customers"."customers"
WHERE
    city in ('Delhi','Mumbai','Leh','Gaya','Vadodara');

-- Select all the products which are not from Books Category
-- Total => 1216 Books =>25 Others=> 1191
SELECT
    *
FROM
    products.products
WHERE
    not 
        category='Books'

SELECT
    *
FROM
    products.products
WHERE
    category!='Books'

SELECT
    *
FROM
    products.products
WHERE
    category<>'Books'

-- Select all the products which are not from Books or Fashion Category
SELECT
    *
FROM
    products.products
WHERE
    not
    (category = 'Books' or category='Fashion')

SELECT
    *
FROM
    products.products
WHERE
    (category != 'Books' and category!='Fashion')
-- Demorgan's Law
    -- (A U B)` = A` n B`

SELECT
    *
FROM
    products.products
WHERE
    NOT
    category in ('Books','Fashion')

SELECT
    *
FROM
    products.products
WHERE
    category not in ('Books','Fashion')

-- BETWEEN

-- Select  all sales records where total_amount is between 1000 and 5000

SELECT
    *
FROM
    "sales"."orders"
WHERE
    total_amount>1000
    AND
        total_amount<5000;

SELECT
    *
FROM
    "sales"."orders"
WHERE
    total_amount BETWEEN 1000 and 5000;


-- Select all the orders where sales was done in 2024 and total_amount is BETWEEN 5000 and 10000

SELECT
    *
FROM
    "sales"."orders"
WHERE
    (total_amount BETWEEN 5000 AND 10000)
    AND
        (order_date BETWEEN '2023-12-31' AND '2025-01-01')    

SELECT
    distinct order_date
FROM
    "sales"."orders"
ORDER BY
    order_date

-- Startswith
--     'S*' => 'S%'
-- Endswith
--     '*S' => '%S'
-- Contains
--     '*S*' => '%S%'

-- Select All the customers whose name startswith S

SELECT
    *
FROM
    "customers"."customers"
WHERE
    full_name LIKE 'S%'

SELECT
    distinct cust_id
FROM
    "customers"."customers"
WHERE
    full_name LIKE 'S%'

-- Select all the customer where there is no Joining Date
SELECT
    *
FROM
    "customers"."customers"
WHERE
    join_date = NULL

SELECT
    *
FROM
    "customers"."customers"
WHERE
    join_date IS NOT NULL

-- Filtering
--     WHERE
--     =, !=, <>, >=,<=,<,>
--     IS NULL
--     IS NOT NULL
--     NOT
--     OR
--     AND
--     BETWEEN
--     LIKE
--     IN
--     NOT IN