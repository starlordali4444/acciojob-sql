Give seat numbers to employees alphabetically.

SELECT 
    emp_name,
    row_number() OVER(order by emp_name) as seat_no
FROM
    stores.employees

Number stores within each region.

SELECT
    region,store_name,
    row_number() OVER(PARTITION BY region order by store_name desc) as store_no
FROM
    stores.stores;

SELECT
    region,COUNT(store_id)
FROM
    stores.stores
group by region;

Rank products within each category by price.

SELECT
    category,prod_name,price,
    row_number() OVER(PARTITION by category ORDER BY price DESC) as rnk_in_cat
FROM
    products.products
GROUP BY
    category,prod_name,price

SELECT
    category,prod_name,price
FROM
    products.products
GROUP BY
    category,prod_name,price

-- We have to include all non AGGREGATE column in group by and  we cant add window fucntion in group by clause


Concert
    Ticket
    Jigri DOst

GROUP BY    
    non AGGREGATEd COLUMN
    Window

SELECT
    category,prod_name,price,
    row_number() OVER(PARTITION by category ORDER BY price DESC) as rnk_in_cat
FROM
    products.products
WHERE rnk_in_cat in (1,2,3)
GROUP BY
    category,prod_name,price

SELECT * FROM (
   SELECT
        category,prod_name,price,
        row_number() OVER(PARTITION by category ORDER BY price DESC) as rnk_in_cat
    FROM
        products.products
    GROUP BY
        category,prod_name,price 
)
WHERE rnk_in_cat in (2)

with ranked_category as (
   SELECT
        category,prod_name,price,
        row_number() OVER(PARTITION by category ORDER BY price DESC) as rnk_in_cat
    FROM
        products.products
    GROUP BY
        category,prod_name,price   
)
select * from ranked_category where rnk_in_cat =2

2nd highest salary per department.

CRAZY HARD EXAMPLE: Product Cannibalization Detection

WITH monthly_product_sales AS (
    SELECT 
        DATE_TRUNC('month', o.order_date)::DATE AS month,
        p.category,
        p.prod_id,
        p.prod_name,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        COUNT(DISTINCT o.cust_id) AS unique_buyers
    FROM sales.order_items oi
    JOIN sales.orders o ON oi.order_id = o.order_id
    JOIN products.products p ON oi.prod_id = p.prod_id
    GROUP BY DATE_TRUNC('month', o.order_date), p.category, p.prod_id, p.prod_name
)
SELECT 
    month,
    category,
    prod_name,
    units_sold,
    revenue,
    unique_buyers,
    RANK() OVER (PARTITION BY month, category ORDER BY revenue DESC) AS monthly_cat_rank,
    LAG(revenue) OVER (PARTITION BY prod_id ORDER BY month) AS prev_month_revenue,
    revenue - LAG(revenue) OVER (PARTITION BY prod_id ORDER BY month) AS revenue_change,
    LAG(unique_buyers) OVER (PARTITION BY prod_id ORDER BY month) AS prev_month_buyers,
    unique_buyers - LAG(unique_buyers) OVER (PARTITION BY prod_id ORDER BY month) AS buyer_change,
    CASE 
        WHEN RANK() OVER (PARTITION BY month, category ORDER BY revenue DESC) = 1 THEN '👑 Category Leader'
        WHEN revenue > LAG(revenue) OVER (PARTITION BY prod_id ORDER BY month) THEN '📈 Growing'
        WHEN revenue < LAG(revenue) OVER (PARTITION BY prod_id ORDER BY month) AND 
             unique_buyers > LAG(unique_buyers) OVER (PARTITION BY prod_id ORDER BY month) THEN '⚠️ Margin Pressure'
        WHEN revenue < LAG(revenue) OVER (PARTITION BY prod_id ORDER BY month) THEN '📉 Declining'
        ELSE '→ Stable'
    END AS trend_status
FROM monthly_product_sales
ORDER BY month DESC, category, revenue DESC;

WITH ranked AS (
  SELECT dept_id, emp_name, salary,
  ROW_NUMBER() OVER(PARTITION BY dept_id ORDER BY salary DESC) AS rn
  FROM stores.employees)
SELECT * FROM ranked WHERE rn = 2;



