-- List all the orders with Customer NAMES
SELECT
    *
FROM
    "customers"."customers";

SELECT
    *
FROM
    "sales"."orders";

SELECT
    count(*) as inner_join
FROM
    sales.orders as o
INNER JOIN
    customers.customers as c
ON
    c.cust_id = o.cust_id;

SELECT
    count(*) as left_join
FROM
    sales.orders as o
LEFT JOIN
    customers.customers as c
ON
    c.cust_id = o.cust_id;

SELECT
    count(*) as right_join
FROM
    sales.orders as o
RIGHT JOIN
    customers.customers as c
ON
    c.cust_id = o.cust_id;

SELECT
    count(*) as full_join
FROM
    sales.orders as o
FULL JOIN
    customers.customers as c
ON
    c.cust_id = o.cust_id;

Inner           =>  150000
Left            =>  150000
RIGHT           =>  152482
FULL            =>  152482

Left TABLE      =>  orders
RIGHT Table     => customers

For each Orders we have customers
For Customers we dont have Orders

Can you find those Customers
SELECT
    count(*) as inner_join
FROM
    sales.orders as o
INNER JOIN
    customers.customers as c
ON
    c.cust_id != o.cust_id;


SELECT
    o.*,c.full_name
    -- ,count(*) as full_join
FROM
    sales.orders as o
FULL JOIN
    customers.customers as c
ON
    c.cust_id = o.cust_id
WHERE
    o.order_id is NULL;

-- 2️⃣ Fetch order items with corresponding product names
Select 
    count(*) as inner_join
FROM
    "sales"."order_items" o
INNER JOIN
    products.products p
ON
    p.prod_id = o.prod_id;

Select 
    count(*) as left_join
FROM
    "sales"."order_items" o
LEFT JOIN
    products.products p
ON
    p.prod_id = o.prod_id;

Select 
    count(*) as right_join
FROM
    "sales"."order_items" o
RIGHT JOIN
    products.products p
ON
    p.prod_id = o.prod_id;

Select 
    count(*) as full_join
FROM
    "sales"."order_items" o
FULL JOIN
    products.products p
ON
    p.prod_id = o.prod_id;

-- It means all the products are sold atleast once

-- 1️⃣ List all customers and their orders (including those without any)
SELECT
    count(*) as right_join
FROM
    sales.orders as o
RIGHT JOIN
    customers.customers as c
ON
    c.cust_id = o.cust_id;

SELECT
    count(*) as left_join
FROM
    customers.customers as c
LEFT JOIN
    sales.orders as o
ON
    c.cust_id = o.cust_id;

-- 3️⃣ List stores and employees (including stores without employees)

SELECT
    *
FROM
    "stores"."stores";

SELECT
    *
FROM
    "stores"."employees";


SELECT
    *
FROM
    "stores"."stores" s
LEFT JOIN
    stores.employees  e
ON
    e.store_id = s.store_id;

-- Every store have atleast 1 employee.

-- 5️⃣ Categories and their products (include categories with no products)

SELECT
    *
FROM
    products.products p
RIGHT JOIN
    core.dim_category c
ON
    p.category=c.category_name

Select * from 
core.dim_category

SELECT
    DISTINCT category
FROM
    products.products


-- 4️⃣ Cities and customers (include missing from either side)
SELECT
    c.full_name,a.city
FROM
    "customers"."customers" c
FULL JOIN
    customers.addresses a
ON
    c.cust_id = a.cust_id

SELECT
    c.full_name,a.city
FROM
    "customers"."customers" c
FULL JOIN
    customers.addresses a
ON
    c.city = a.city


SELECT
    count(*)
FROM
    "customers"."customers" c

SELECT
    count(*)
FROM
    customers.addresses a

SELECT
    *
FROM
    customers.addresses a

with customer_city as (
    SELECT
        city,COUNT(city) as cust_city
    FROM
        "customers"."customers" c
    GROUP BY
        1
),
address_city as (
    SELECT
        city,COUNT(city) as add_city
    FROM
        customers.addresses a
    GROUP BY
        1
)
select sum(cust_city*add_city) as total_combination from customer_city as cc 
JOIN
    address_city ac
ON
    cc.city=ac.city;


/*SELECT DISTINCT
     COALESCE((SELECT DISTINCT Salary 
     FROM Employee 
     ORDER BY Salary DESC 
     LIMIT 1 OFFSET 1),NULL) AS SecondHighestSalary
FROM Employee;*/
/*SELECT Salary 
FROM Employee 
WHERE Salary<(SELECT MAX(Salary) AS SecondHighestSalary FROM Employee)
LIMIT 1 
OFFSET 1;*/
WITH CTE_Salary AS(
         SELECT 
         DISTINCT Salary AS SecondHighestSalary
         FROM Employee
         ORDER BY Salary DESC
         LIMIT 1 OFFSET 1 
)
SELECT 
     COALESCE(SecondHighestSalary,NULL)
FROM CTE_Salary;

-- Concept: Multi-table INNER JOIN + aggregation.

-- Q1. Department-wise Total Sales Across Stores

Store
    Department
                Total Sales

Select * from "sales"."orders" limit 100;
Select * from "sales"."order_items" limit 100;
Select * from stores.departments limit 100;
Select * from stores.stores limit 100;
Select * from "products"."products" limit 100;
Select * from "products"."inventory" limit 100;
Select * from "stores"."employees" limit 100;

-- sales.orders
--     store_id
--     total_amount
-- stores.departments
--     dept_id
--     dept_name
-- stores.stores
--     store_id
--     store_name
-- stores.employees
--     dept_id
--     store_id

-- It might be possible for some store some department we have 0 sales
--     Orders as base table it will ignore these stores or depatments
--     Store as base it will cover that
--     We want sales dept wise and store wise

-- Identfy the required Columns
-- Identify the required tables
-- Identify the relationship and common columns
-- Transform the input as desired


SELECT
    s.store_name,d.dept_name,sum(o.total_amount) as total_sales
FROM
    stores.stores s
JOIN
    stores.employees e
    ON s.store_id = e.store_id
JOIN
    stores.departments d
    ON d.dept_id = e.dept_id
JOIN
    sales.orders o
    ON  o.store_id = s.store_id
GROUP BY
    s.store_name,d.dept_name
ORDER BY
    s.store_name,total_sales desc;

SELECT
    s.store_name,d.dept_name,sum(o.total_amount) as total_sales
FROM
    stores.stores s
left JOIN
    stores.employees e
    ON s.store_id = e.store_id
left JOIN
    stores.departments d
    ON d.dept_id = e.dept_id
left JOIN
    sales.orders o
    ON  o.store_id = s.store_id
GROUP BY
    s.store_name,d.dept_name
ORDER BY
    s.store_name,total_sales desc;

🔸 Q2. Products Never Sold (Anti-Join Logic)

Concept: LEFT JOIN + NULL check.

SELECT p.product_id, p.product_name, c.category_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE oi.order_id IS NULL;


🧩 Teaches: detecting missing matches using LEFT JOIN.

🔸 Q3. Customers and Their Last Known City Even If No Orders

Concept: LEFT JOIN to keep all customers; COALESCE to handle NULL city.

SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    COALESCE(ci.city_name, 'Unknown') AS city_name
FROM customers c
LEFT JOIN cities ci ON c.city_id = ci.city_id;


🧩 Teaches: LEFT JOIN + NULL handling using COALESCE.

🔸 Q4. Orders Without Matching Store or Customer (Data Audit)

Concept: FULL JOIN to detect missing foreign keys.

SELECT 
    o.order_id, 
    o.customer_id, 
    c.customer_id AS matched_customer, 
    o.store_id, 
    s.store_id AS matched_store
FROM orders o
FULL JOIN customers c ON o.customer_id = c.customer_id
FULL JOIN stores s    ON o.store_id = s.store_id
WHERE c.customer_id IS NULL OR s.store_id IS NULL;


🧩 Teaches: FULL JOIN for mismatch detection.

🔸 Q5. City-wise Revenue and Number of Orders

Concept: Multi-JOIN + aggregation with GROUP BY.

SELECT 
    ci.city_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN cities ci ON s.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;


🧩 Teaches: multiple joins with GROUP BY on higher-level dimension.

🔸 Q6. Product Category Sales With NULL Replacements

Concept: Handle missing category names using COALESCE.

SELECT 
    COALESCE(c.category_name, 'Uncategorized') AS category_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN categories c ON p.category_id = c.category_id
GROUP BY COALESCE(c.category_name, 'Uncategorized')
ORDER BY total_sales DESC;


🧩 Teaches: LEFT JOIN + NULL handling in GROUP BY.

🔸 Q7. Employee Count per Store Including Stores With No Employees

Concept: LEFT JOIN + GROUP BY.

SELECT 
    s.store_name,
    COUNT(e.employee_id) AS total_employees
FROM stores s
LEFT JOIN employees e ON s.store_id = e.store_id
GROUP BY s.store_name
ORDER BY total_employees DESC;


🧩 Teaches: preserving unmatched rows using LEFT JOIN.

🔸 Q8. Cross Join to Generate Product–Store Availability Matrix

Concept: CROSS JOIN to show every possible combination.

SELECT 
    p.product_name,
    s.store_name
FROM products p
CROSS JOIN stores s
ORDER BY p.product_name, s.store_name;


🧩 Teaches: Cartesian logic → use carefully.

🔸 Q9. Store Performance Category Using CASE

Concept: Derived column with CASE using JOIN results.

SELECT 
    s.store_name,
    SUM(o.total_amount) AS total_revenue,
    CASE 
        WHEN SUM(o.total_amount) > 500000 THEN 'High Performer'
        WHEN SUM(o.total_amount) BETWEEN 200000 AND 500000 THEN 'Average'
        ELSE 'Low Performer'
    END AS performance_category
FROM stores s
LEFT JOIN orders o ON s.store_id = o.store_id
GROUP BY s.store_name;


🧩 Teaches: CASE WHEN + aggregates.

🔸 Q10. Compare Customer’s Order City vs Registered City

Concept: Join through multiple levels and conditional check.

SELECT 
    c.first_name,
    ci1.city_name AS registered_city,
    ci2.city_name AS order_city,
    CASE 
        WHEN ci1.city_name = ci2.city_name THEN 'Same City'
        ELSE 'Different City'
    END AS match_status
FROM customers c
JOIN cities ci1 ON c.city_id = ci1.city_id
JOIN orders o ON c.customer_id = o.customer_id
JOIN stores s ON o.store_id = s.store_id
JOIN cities ci2 ON s.city_id = ci2.city_id;


🧩 Teaches: multi-level join + CASE logic.







