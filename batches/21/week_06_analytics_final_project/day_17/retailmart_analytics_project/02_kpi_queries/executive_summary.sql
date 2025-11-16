-- File: 02_kpi_queries/executive_summary.sql

-- ============================================
-- EXECUTIVE SUMMARY - KEY METRICS
-- ============================================

-- ---------------------------------------------
-- 1. EXECUTIVE KPI SUMMARY
-- ---------------------------------------------
CREATE MATERIALIZED VIEW analytics.mv_executive_summary AS
WITH overall_metrics AS (
    SELECT 
        COUNT(DISTINCT order_id) as total_orders,
        COUNT(DISTINCT cust_id) as total_customers,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM sales.orders
    WHERE order_status = 'Completed'
),
last_30_days AS (
    SELECT 
        COUNT(DISTINCT order_id) as orders_last_30,
        SUM(total_amount) as revenue_last_30
    FROM sales.orders
    WHERE order_status = 'Completed'
        AND order_date >= CURRENT_DATE - INTERVAL '30 days'
),
previous_30_days AS (
    SELECT 
        COUNT(DISTINCT order_id) as orders_prev_30,
        SUM(total_amount) as revenue_prev_30
    FROM sales.orders
    WHERE order_status = 'Completed'
        AND order_date >= CURRENT_DATE - INTERVAL '60 days'
        AND order_date < CURRENT_DATE - INTERVAL '30 days'
),
product_metrics AS (
    SELECT 
        COUNT(DISTINCT prod_id) as total_products,
        COUNT(DISTINCT category) as total_categories,
        COUNT(DISTINCT brand) as total_brands
    FROM products.products
),
store_metrics AS (
    SELECT 
        COUNT(DISTINCT store_id) as total_stores,
        COUNT(DISTINCT region) as total_regions
    FROM stores.stores
)
SELECT 
    -- Overall Metrics
    om.total_orders,
    om.total_customers,
    ROUND(om.total_revenue, 2) as total_revenue,
    ROUND(om.avg_order_value, 2) as avg_order_value,
    
    -- Last 30 Days
    l30.orders_last_30,
    ROUND(l30.revenue_last_30, 2) as revenue_last_30,
    
    -- Growth Calculations
    ROUND(
        100.0 * (l30.revenue_last_30 - p30.revenue_prev_30) / NULLIF(p30.revenue_prev_30, 0),
        2
    ) as revenue_growth_pct_30d,
    
    -- Product & Store Counts
    pm.total_products,
    pm.total_categories,
    pm.total_brands,
    sm.total_stores,
    sm.total_regions,
    
    -- Timestamp
    CURRENT_TIMESTAMP as last_updated
FROM overall_metrics om
CROSS JOIN last_30_days l30
CROSS JOIN previous_30_days p30
CROSS JOIN product_metrics pm
CROSS JOIN store_metrics sm;

REFRESH MATERIALIZED VIEW analytics.mv_executive_summary;


-- ---------------------------------------------
-- 2. TOP 10 PRODUCTS (QUICK VIEW)
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_top10_products_quick AS
SELECT 
    prod_name,
    category,
    brand,
    ROUND(net_revenue, 2) as revenue,
    total_units_sold as units_sold,
    revenue_rank
FROM analytics.mv_top_products
WHERE revenue_rank <= 10
ORDER BY revenue_rank;


-- ---------------------------------------------
-- 3. TOP 10 CUSTOMERS (QUICK VIEW)
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_top10_customers_quick AS
SELECT 
    full_name,
    city,
    state,
    total_orders,
    ROUND(total_revenue, 2) as total_spent,
    clv_tier
FROM analytics.mv_customer_lifetime_value
ORDER BY total_revenue DESC
LIMIT 10;


-- ---------------------------------------------
-- 4. MONTHLY TREND (LAST 12 MONTHS)
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_monthly_trend_12m AS
SELECT 
    year,
    month,
    month_name,
    total_revenue,
    total_orders,
    unique_customers,
    mom_growth_pct,
    performance_status
FROM analytics.mv_monthly_sales_dashboard
WHERE (year * 100 + month) >= EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '12 months') * 100 + EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL '12 months')
ORDER BY year DESC, month DESC;


SELECT 'Executive Summary Dashboard Created Successfully!' as status;