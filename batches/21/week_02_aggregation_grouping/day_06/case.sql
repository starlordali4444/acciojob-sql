CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE result3
END

Categorise Our customers on the basis of their sales
    total_amount > 100000  => Excellent
    total_amount > 50000   => Good
    total_amount > 25000   => Average
    total_amount > 10000   => Bad
    Other                  => Very Bad
    
SELECT
    total_amount,
    CASE
        WHEN total_amount>100000 THEN 'Excellent'
        WHEN total_amount>50000  THEN 'Good'
        WHEN total_amount>25000  THEN 'Average'
        WHEN total_amount>10000  THEN 'Bad'
        ELSE 'Very Bad'
    END AS customer_category
FROM

SELECT
    CASE
        WHEN total_amount>100000 THEN 'Excellent'
        WHEN total_amount>50000  THEN 'Good'
        WHEN total_amount>25000  THEN 'Average'
        WHEN total_amount>10000  THEN 'Bad'
        ELSE 'Very Bad'
    END AS customer_category,
    count(*)
FROM
    "sales"."orders"
GROUP BY
    customer_category

Categorise Product as Premium | Mid Range | Budget

SELECT 
    prod_name,
    "products".price,
    CASE
        WHEN price >= 50000 THEN 'Premium Product'
        WHEN price BETWEEN 20000 AND 49999 THEN 'Mid Range'
        ELSE 'Budget Product'
    END as price_category
FROM
    "products"."products"

SELECT 
    *,
    ROUND(("order_items".quantity * unit_price) - ((discount/100) * ("order_items".quantity * unit_price)),2) as selling_price,
    ROUND(("order_items".quantity * unit_price) * (1 - (discount/100)),2)
FROM
    "sales"."order_items"
LIMIT 100;

Categorise Customers based on City Type | Metro , Non Metro
SELECT 
    full_name,
    city,
    CASE
        WHEN city in ('Mumbai','Delhi','Bengaluru','Hyderabad','Kolkata','Chennai') THEN 'Metro'
        ELSE 'Non Metro'
    END as city_type
FROM
    "customers"."customers"
LIMIT 100;

SELECT
    distinct city
FROM
    "customers"."customers"
order by 
    city

SELECT 
    full_name,
    city,
    CASE
        WHEN city in ('Mumbai','Delhi','Bengaluru','Hyderabad','Kolkata','Chennai') THEN 'Metro'
    END as city_type
FROM
    "customers"."customers"
LIMIT 100;

Categorize each customer based on age and handle missing values.
    <25         =>  Youth
    25 and 45   => Adult
    46 and 60   => Mid-Age
    Senior Citizen

SELECT
    full_name,
    coalesce(age,0) as actual_age,
    CASE
        WHEN COALESCE(age,0)=0 THEN 'Unknown'
        WHEN age<25 THEN 'Youth'
        WHEN age<25 THEN 'Adult'
        WHEN age<25 THEN 'Mid-Age'
        Else    'Senior Citizen'
    end as age_group
FROM
    customers.customers

Goal: classify products into price bands.
    Price can be NULL
    >= 50000 Premium
    20000 and 49999 Mid RANGE
    Budget

SELECT
    prod_id,
    prod_name,
    price,
    COALESCE(price,0) AS safe_price,
    CASE
        WHEN COALESCE(price,0) >= 50000 THEN 'Premium'
        WHEN COALESCE(price,0) BETWEEN 20000 AND 49999 THEN 'Mid-Range'
        ELSE 'Budget'
    END AS price_band
FROM products.products
ORDER BY safe_price DESC;

