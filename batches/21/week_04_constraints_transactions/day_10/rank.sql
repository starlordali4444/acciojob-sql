Rank stores within each region by total sales.

Partition By => region
Order By => Total Sales

Select * from "finance"."revenue_summary"
Select * from sales.orders

select * from stores.stores

SELECT
    s.region,
    s.store_name,
    SUM(r.total_sales) as total_sales,
    Rank() OVER(PARTITION BY s.region ORDER BY SUM(r.total_sales) desc) as sales_rnk
FROM
    finance.revenue_summary r
JOIN
    stores.stores s
ON
    s.store_id = r.store_id
GROUP BY
    s.region,s.store_name

