SELECT * FROM analytics.kpi_metadata;

select * from core.dim_date;

SELECT * from analytics.vw_daily_sales_summary;


SELECT 
    d.date_key,
    d.year,
    d.month,
    d.month_name,
    d.day_name,
    d.quarter,
    CASE WHEN d.day_name in ('Sat','Sun') THEN 1
    ELSE 0
    END is_weekend,
    -- Order Metrics
    COUNT(DISTINCT o.order_id) as total_orders
    -- COUNT(DISTINCT o.cust_id) as unique_customers,
    -- COUNT(DISTINCT o.store_id) as active_stores,
    -- -- Revenue Metrics
    -- COALESCE(SUM(o.total_amount), 0) as total_revenue,
    -- COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    -- COALESCE(MIN(o.total_amount), 0) as min_order_value,
    -- COALESCE(MAX(o.total_amount), 0) as max_order_value,
    -- -- Item Metrics
    -- COALESCE(SUM(oi.quantity), 0) as total_items_sold,
    -- COALESCE(AVG(items_per_order.item_count), 0) as avg_items_per_order,
    -- -- Discount Metrics
    -- COALESCE(SUM(oi.quantity * oi.unit_price * oi.discount / 100), 0) as total_discount_amount,
    -- COALESCE(AVG(oi.discount), 0) as avg_discount_percentage
FROM core.dim_date d
LEFT JOIN sales.orders o ON d.date_key = o.order_date AND o.order_status = 'Completed'
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
LEFT JOIN (
    SELECT order_id, COUNT(*) as item_count
    FROM sales.order_items
    GROUP BY order_id
) items_per_order ON o.order_id = items_per_order.order_id
GROUP BY 
    d.date_key, d.year, d.month, d.month_name, 
    d.day_name, d.quarter, is_weekend
ORDER BY d.date_key DESC;

select order_date,count(DISTINCT order_id) from sales.orders
group by order_date

select distinct order_date from sales.orders ORDER BY order_date
select distinct orders.order_status from sales.orders ORDER BY order_date

select distinct date_key from core.dim_date ORDER BY date_key;

SELECT


SELECT 
    d.date_key,
    d.year,
    d.month,
    d.month_name,
    d.day_name,
    d.quarter,
    CASE WHEN d.day_name in ('Sat','Sun') THEN 1
    ELSE 0
    END is_weekend,
    -- Order Metrics
    COUNT(DISTINCT o.order_id) as total_orders
FROM core.dim_date d
LEFT JOIN sales.orders o ON d.date_key = o.order_date 
-- AND o.order_status = 'Completed'

GROUP BY 
    d.date_key, d.year, d.month, d.month_name, 
    d.day_name, d.quarter, is_weekend

Select * FROM
    analytics.mv_monthly_sales_dashboard

    total_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100, 2) as mom_growth_pct


Select year,month,total_revenue, prev_month_revenue,mom_growth_pct FROM
    analytics.mv_monthly_sales_dashboard
with date_wise_sale as (
    select extract( year from order_date) as order_year,
    extract( month from order_date) as order_month,sum(total_amount) as total_revenue
    FROM sales.orders
    group by extract( year from order_date),extract( month from order_date)
)
SELECT *,
    SUM(total_revenue) OVER(partition by order_year order by order_month),
    SUM(total_revenue) OVER(partition by order_year order by order_month ROWS UNBOUNDED PRECEDING),
    AVG(total_revenue) OVER ( ORDER BY order_year, order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) as moving_avg_3month
from date_wise_sale
