-- File: 02_kpi_queries/sales_analytics.sql

-- ============================================
-- SALES ANALYTICS - COMPREHENSIVE MODULE
-- ============================================

-- ---------------------------------------------
-- 1. DAILY SALES SUMMARY
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_daily_sales_summary AS
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
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.cust_id) as unique_customers,
    COUNT(DISTINCT o.store_id) as active_stores,
    -- Revenue Metrics
    COALESCE(SUM(o.total_amount), 0) as total_revenue,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    COALESCE(MIN(o.total_amount), 0) as min_order_value,
    COALESCE(MAX(o.total_amount), 0) as max_order_value,
    -- Item Metrics
    COALESCE(SUM(oi.quantity), 0) as total_items_sold,
    COALESCE(AVG(items_per_order.item_count), 0) as avg_items_per_order,
    -- Discount Metrics
    COALESCE(SUM(oi.quantity * oi.unit_price * oi.discount / 100), 0) as total_discount_amount,
    COALESCE(AVG(oi.discount), 0) as avg_discount_percentage
FROM core.dim_date d
LEFT JOIN sales.orders o ON d.date_key = o.order_date AND o.order_status = 'Delivered'
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

-- Test the view
SELECT * FROM analytics.vw_daily_sales_summary
WHERE date_key >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY date_key DESC;


-- ---------------------------------------------
-- 2. MONTHLY SALES DASHBOARD WITH TRENDS
-- ---------------------------------------------
CREATE MATERIALIZED VIEW analytics.mv_monthly_sales_dashboard AS
WITH monthly_base AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        d.quarter,
        COUNT(DISTINCT o.order_id) as total_orders,
        COUNT(DISTINCT o.cust_id) as unique_customers,
        SUM(o.total_amount) as total_revenue,
        AVG(o.total_amount) as avg_order_value,
        SUM(oi.quantity) as total_units_sold,
        SUM(oi.quantity * oi.unit_price * oi.discount / 100) as total_discounts
    FROM sales.orders o
    JOIN core.dim_date d ON o.order_date = d.date_key
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY d.year, d.month, d.month_name, d.quarter
),
growth_calculations AS (
    SELECT 
        *,
        -- Previous Month Metrics
        LAG(total_revenue, 1) OVER (ORDER BY year, month) as prev_month_revenue,
        LAG(total_orders, 1) OVER (ORDER BY year, month) as prev_month_orders,
        -- Same Month Last Year
        LAG(total_revenue, 12) OVER (ORDER BY year, month) as same_month_last_year_revenue,
        -- Running Totals
        SUM(total_revenue) OVER (
            PARTITION BY year 
            ORDER BY month 
            ROWS UNBOUNDED PRECEDING
        ) as ytd_revenue,
        -- Moving Averages
        AVG(total_revenue) OVER (
            ORDER BY year, month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) as moving_avg_3month,
        AVG(total_revenue) OVER (
            ORDER BY year, month 
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
        ) as moving_avg_6month
    FROM monthly_base
)
SELECT 
    year,
    month,
    month_name,
    quarter,
    total_orders,
    unique_customers,
    ROUND(total_revenue, 2) as total_revenue,
    ROUND(avg_order_value, 2) as avg_order_value,
    total_units_sold,
    ROUND(total_discounts, 2) as total_discounts,
    ROUND(total_revenue - total_discounts, 2) as net_revenue,
    ROUND(total_revenue / NULLIF(unique_customers, 0), 2) as revenue_per_customer,
    -- Growth Metrics
    ROUND(prev_month_revenue, 2) as prev_month_revenue,
    ROUND((total_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100, 2) as mom_growth_pct,
    ROUND(same_month_last_year_revenue, 2) as same_month_last_year,
    ROUND((total_revenue - same_month_last_year_revenue) / NULLIF(same_month_last_year_revenue, 0) * 100, 2) as yoy_growth_pct,
    -- Running Totals
    ROUND(ytd_revenue, 2) as ytd_revenue,
    ROUND(moving_avg_3month, 2) as moving_avg_3month,
    ROUND(moving_avg_6month, 2) as moving_avg_6month,
    -- Performance Status
    CASE 
        WHEN (total_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100 > 10 THEN 'Excellent Growth'
        WHEN (total_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100 > 0 THEN 'Positive Growth'
        WHEN (total_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100 > -10 THEN 'Slight Decline'
        ELSE 'Significant Decline'
    END as performance_status
FROM growth_calculations
ORDER BY year DESC, month DESC;

-- Create index for performance
CREATE INDEX idx_monthly_sales_year_month 
ON analytics.mv_monthly_sales_dashboard(year, month);

-- Refresh the materialized view
REFRESH MATERIALIZED VIEW analytics.mv_monthly_sales_dashboard;


-- ---------------------------------------------
-- 3. SALES BY DAY OF WEEK ANALYSIS
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_sales_by_dayofweek AS
SELECT 
    d.day_name,
    CASE d.day_name
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END as day_order,
    d.is_weekend,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(AVG(COUNT(DISTINCT o.order_id)) OVER (), 0) as avg_orders,
    SUM(o.total_amount) as total_revenue,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    COUNT(DISTINCT o.cust_id) as unique_customers,
    -- Performance vs Average
    ROUND(
        (COUNT(DISTINCT o.order_id) - AVG(COUNT(DISTINCT o.order_id)) OVER ()) / 
        NULLIF(AVG(COUNT(DISTINCT o.order_id)) OVER (), 0) * 100,
        2
    ) as variance_from_avg_pct
FROM sales.orders o
JOIN core.dim_date d ON o.order_date = d.date_key
WHERE o.order_status = 'Completed'
GROUP BY d.day_name, d.is_weekend
ORDER BY day_order;


-- ---------------------------------------------
-- 4. HOURLY SALES PATTERN (if timestamp available)
-- Note: This assumes order_date is a timestamp, adjust if date only
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_sales_by_hour AS
SELECT 
    EXTRACT(HOUR FROM o.order_date) as hour_of_day,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_amount) as total_revenue,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    CASE 
        WHEN EXTRACT(HOUR FROM o.order_date) BETWEEN 6 AND 11 THEN 'Morning (6-11 AM)'
        WHEN EXTRACT(HOUR FROM o.order_date) BETWEEN 12 AND 17 THEN 'Afternoon (12-5 PM)'
        WHEN EXTRACT(HOUR FROM o.order_date) BETWEEN 18 AND 21 THEN 'Evening (6-9 PM)'
        ELSE 'Night (10 PM-5 AM)'
    END as time_period
FROM sales.orders o
WHERE o.order_status = 'Completed'
GROUP BY EXTRACT(HOUR FROM o.order_date)
ORDER BY hour_of_day;


-- ---------------------------------------------
-- 5. SALES BY PAYMENT MODE
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_sales_by_payment_mode AS
SELECT 
    p.payment_mode,
    COUNT(DISTINCT p.payment_id) as transaction_count,
    COUNT(DISTINCT p.order_id) as order_count,
    SUM(p.amount) as total_amount,
    ROUND(AVG(p.amount), 2) as avg_transaction_amount,
    ROUND(
        100.0 * SUM(p.amount) / SUM(SUM(p.amount)) OVER (),
        2
    ) as pct_of_total_revenue,
    ROUND(
        100.0 * COUNT(DISTINCT p.payment_id) / SUM(COUNT(DISTINCT p.payment_id)) OVER (),
        2
    ) as pct_of_transactions
FROM sales.payments p
JOIN sales.orders o ON p.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.payment_mode
ORDER BY total_amount DESC;


-- ---------------------------------------------
-- 6. SALES VS RETURNS ANALYSIS
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_sales_returns_analysis AS
WITH sales_data AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as gross_sales
    FROM sales.orders o
    JOIN core.dim_date d ON o.order_date = d.date_key
    WHERE o.order_status = 'Completed'
    GROUP BY d.year, d.month, d.month_name
),
returns_data AS (
    SELECT 
        d.year,
        d.month,
        COUNT(DISTINCT r.return_id) as total_returns,
        COUNT(DISTINCT r.order_id) as orders_with_returns,
        SUM(r.refund_amount) as total_refunds
    FROM sales.returns r
    JOIN core.dim_date d ON r.return_date = d.date_key
    GROUP BY d.year, d.month
)
SELECT 
    s.year,
    s.month,
    s.month_name,
    s.total_orders,
    ROUND(s.gross_sales, 2) as gross_sales,
    COALESCE(r.total_returns, 0) as total_returns,
    COALESCE(r.orders_with_returns, 0) as orders_with_returns,
    COALESCE(ROUND(r.total_refunds, 2), 0) as total_refunds,
    ROUND(s.gross_sales - COALESCE(r.total_refunds, 0), 2) as net_sales,
    ROUND(
        100.0 * COALESCE(r.orders_with_returns, 0) / NULLIF(s.total_orders, 0),
        2
    ) as return_rate_pct,
    ROUND(
        100.0 * COALESCE(r.total_refunds, 0) / NULLIF(s.gross_sales, 0),
        2
    ) as refund_rate_pct
FROM sales_data s
LEFT JOIN returns_data r ON s.year = r.year AND s.month = r.month
ORDER BY s.year DESC, s.month DESC;


-- ---------------------------------------------
-- 7. QUARTERLY SALES PERFORMANCE
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_quarterly_sales AS
SELECT 
    d.year,
    d.quarter,
    'Q' || d.quarter || ' ' || d.year as quarter_label,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.cust_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    SUM(oi.quantity) as total_units_sold,
    -- Quarter over Quarter Growth
    LAG(SUM(o.total_amount), 1) OVER (ORDER BY d.year, d.quarter) as prev_quarter_revenue,
    ROUND(
        (SUM(o.total_amount) - LAG(SUM(o.total_amount), 1) OVER (ORDER BY d.year, d.quarter)) / 
        NULLIF(LAG(SUM(o.total_amount), 1) OVER (ORDER BY d.year, d.quarter), 0) * 100,
        2
    ) as qoq_growth_pct,
    -- Year over Year (same quarter)
    LAG(SUM(o.total_amount), 4) OVER (ORDER BY d.year, d.quarter) as same_quarter_last_year,
    ROUND(
        (SUM(o.total_amount) - LAG(SUM(o.total_amount), 4) OVER (ORDER BY d.year, d.quarter)) / 
        NULLIF(LAG(SUM(o.total_amount), 4) OVER (ORDER BY d.year, d.quarter), 0) * 100,
        2
    ) as yoy_growth_pct
FROM sales.orders o
JOIN core.dim_date d ON o.order_date = d.date_key
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY d.year, d.quarter
ORDER BY d.year DESC, d.quarter DESC;


-- ---------------------------------------------
-- 8. EXPORT DATA FOR VISUALIZATION
-- ---------------------------------------------

-- Create a summary table for dashboard
CREATE TABLE IF NOT EXISTS analytics.dashboard_sales_summary AS
SELECT 
    'Last 30 Days' as period,
    COUNT(DISTINCT order_id) as total_orders,
    COUNT(DISTINCT cust_id) as unique_customers,
    ROUND(SUM(total_amount), 2) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_order_value
FROM sales.orders
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
    AND order_status = 'Completed'

UNION ALL

SELECT 
    'Last 7 Days',
    COUNT(DISTINCT order_id),
    COUNT(DISTINCT cust_id),
    ROUND(SUM(total_amount), 2),
    ROUND(AVG(total_amount), 2)
FROM sales.orders
WHERE order_date >= CURRENT_DATE - INTERVAL '7 days'
    AND order_status = 'Completed'

UNION ALL

SELECT 
    'Today',
    COUNT(DISTINCT order_id),
    COUNT(DISTINCT cust_id),
    ROUND(SUM(total_amount), 2),
    ROUND(AVG(total_amount), 2)
FROM sales.orders
WHERE order_date = CURRENT_DATE
    AND order_status = 'Completed';

SELECT 'Sales Analytics Module Created Successfully!' as status;