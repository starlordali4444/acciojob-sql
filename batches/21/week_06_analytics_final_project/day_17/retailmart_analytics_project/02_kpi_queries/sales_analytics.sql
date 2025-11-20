-- ============================================================================
-- FILE: 02_kpi_queries/sales_analytics.sql
-- PURPOSE: Sales Analytics Module - Complete sales performance tracking
-- AUTHOR: RetailMart Analytics Team
-- CREATED: 2024
-- DESCRIPTION: 
--   - Daily, monthly, quarterly sales analysis
--   - Payment mode analysis
--   - Returns tracking
--   - Executive summary KPIs
--   - JSON export functions for dashboard integration
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                    SALES ANALYTICS MODULE - STARTING                       '
\echo '============================================================================'
\echo ''
\echo 'This module creates:'
\echo '  - 7 Regular Views (daily, trends, payment modes, returns, etc.)'
\echo '  - 2 Materialized Views (monthly dashboard, executive summary)'
\echo '  - 1 Export Table (dashboard summary)'
\echo '  - 7 JSON Export Functions (for dashboard integration)'
\echo ''

-- ============================================================================
-- 1. DAILY SALES SUMMARY VIEW
-- ============================================================================
-- PURPOSE: Provides granular daily sales metrics for trend analysis
-- UPDATES: Real-time (view refreshes on query)
-- USAGE: SELECT * FROM analytics.vw_daily_sales_summary WHERE date_key >= '2024-01-01';
-- ============================================================================

\echo '[1/10] Creating view: vw_daily_sales_summary...'
\echo '       - Aggregates sales by day with order, revenue, and item metrics'
\echo '       - Includes weekend flag for day-of-week analysis'

CREATE OR REPLACE VIEW analytics.vw_daily_sales_summary AS
SELECT 
    -- Date Dimensions
    d.date_key,                                      -- Primary date identifier
    d.year,                                          -- Year (e.g., 2024)
    d.month,                                         -- Month number (1-12)
    d.month_name,                                    -- Month name (Jan, Feb, etc.)
    d.day_name,                                      -- Day name (Mon, Tue, etc.)
    d.quarter,                                       -- Quarter (1-4)
    CASE WHEN d.day_name IN ('Sat','Sun') THEN 1 
         ELSE 0 
    END as is_weekend,                               -- Weekend flag (1=weekend, 0=weekday)
    
    -- Order Metrics
    COUNT(DISTINCT o.order_id) as total_orders,      -- Total number of orders placed
    COUNT(DISTINCT o.cust_id) as unique_customers,   -- Number of unique customers
    COUNT(DISTINCT o.store_id) as active_stores,     -- Number of stores with sales
    
    -- Revenue Metrics (in currency)
    COALESCE(SUM(o.total_amount), 0) as total_revenue,           -- Total sales revenue
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,         -- Average order size
    COALESCE(MIN(o.total_amount), 0) as min_order_value,         -- Smallest order
    COALESCE(MAX(o.total_amount), 0) as max_order_value,         -- Largest order
    
    -- Item Metrics
    COALESCE(SUM(oi.quantity), 0) as total_items_sold,           -- Total units sold
    COALESCE(AVG(items_per_order.item_count), 0) as avg_items_per_order, -- Avg items per order
    
    -- Discount Metrics
    COALESCE(SUM(oi.quantity * oi.unit_price * oi.discount / 100), 0) as total_discount_amount, -- Total discounts given
    COALESCE(AVG(oi.discount), 0) as avg_discount_percentage      -- Average discount rate
FROM 
    core.dim_date d                                  -- Date dimension table
    LEFT JOIN sales.orders o 
        ON d.date_key = o.order_date 
        AND o.order_status = 'Delivered'             -- Only count delivered orders
    LEFT JOIN sales.order_items oi 
        ON o.order_id = oi.order_id                  -- Get order line items
    LEFT JOIN (
        SELECT order_id, COUNT(*) as item_count      -- Subquery: Items per order
        FROM sales.order_items
        GROUP BY order_id
    ) items_per_order ON o.order_id = items_per_order.order_id
GROUP BY 
    d.date_key, d.year, d.month, d.month_name, 
    d.day_name, d.quarter, is_weekend
ORDER BY d.date_key DESC;                            -- Most recent dates first

\echo '       ✓ View created: vw_daily_sales_summary'
\echo ''


-- ============================================================================
-- 2. MONTHLY SALES DASHBOARD - MATERIALIZED VIEW
-- ============================================================================
-- PURPOSE: Pre-aggregated monthly metrics with growth calculations
-- REFRESH: Manual (call REFRESH MATERIALIZED VIEW or use refresh function)
-- USAGE: SELECT * FROM analytics.mv_monthly_sales_dashboard ORDER BY year DESC, month DESC LIMIT 12;
-- ============================================================================

\echo '[2/10] Creating materialized view: mv_monthly_sales_dashboard...'
\echo '       - Aggregates sales by month with YoY and MoM growth'
\echo '       - Includes moving averages (3-month and 6-month)'
\echo '       - Calculates YTD revenue and performance status'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_monthly_sales_dashboard CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_monthly_sales_dashboard AS
WITH monthly_base AS (
    -- Step 1: Aggregate raw monthly metrics
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
    WHERE o.order_status = 'Delivered'                -- Only delivered orders
    GROUP BY d.year, d.month, d.month_name, d.quarter
),
growth_calculations AS (
    -- Step 2: Calculate growth metrics and moving averages
    SELECT 
        *,
        -- Previous month comparison
        LAG(total_revenue, 1) OVER (ORDER BY year, month) as prev_month_revenue,
        LAG(total_orders, 1) OVER (ORDER BY year, month) as prev_month_orders,
        
        -- Year-over-year comparison (12 months ago)
        LAG(total_revenue, 12) OVER (ORDER BY year, month) as same_month_last_year_revenue,
        
        -- Year-to-date cumulative revenue
        SUM(total_revenue) OVER (
            PARTITION BY year 
            ORDER BY month 
            ROWS UNBOUNDED PRECEDING
        ) as ytd_revenue,
        
        -- 3-month moving average
        AVG(total_revenue) OVER (
            ORDER BY year, month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) as moving_avg_3month,
        
        -- 6-month moving average
        AVG(total_revenue) OVER (
            ORDER BY year, month 
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
        ) as moving_avg_6month
    FROM monthly_base
)
SELECT 
    -- Time Dimensions
    year,
    month,
    month_name,
    quarter,
    
    -- Core Metrics
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
    ROUND((total_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100, 2) as mom_growth_pct, -- Month-over-month growth
    ROUND(same_month_last_year_revenue, 2) as same_month_last_year,
    ROUND((total_revenue - same_month_last_year_revenue) / NULLIF(same_month_last_year_revenue, 0) * 100, 2) as yoy_growth_pct, -- Year-over-year growth
    
    -- Cumulative and Moving Averages
    ROUND(ytd_revenue, 2) as ytd_revenue,
    ROUND(moving_avg_3month, 2) as moving_avg_3month,
    ROUND(moving_avg_6month, 2) as moving_avg_6month,
    
    -- Performance Classification
    CASE 
        WHEN (total_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100 > 10 THEN 'Excellent Growth'
        WHEN (total_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100 > 0 THEN 'Positive Growth'
        WHEN (total_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100 > -10 THEN 'Slight Decline'
        ELSE 'Significant Decline'
    END as performance_status
FROM growth_calculations
ORDER BY year DESC, month DESC;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_monthly_sales_year_month 
ON analytics.mv_monthly_sales_dashboard(year, month);

\echo '       ✓ Materialized view created: mv_monthly_sales_dashboard'
\echo '       ✓ Index created on (year, month)'
\echo ''


-- ============================================================================
-- 3. RECENT SALES TREND - LAST 30 DAYS
-- ============================================================================
-- PURPOSE: Daily sales for the last 30 days with 7-day moving average
-- USAGE: SELECT * FROM analytics.vw_recent_sales_trend;
-- ============================================================================

\echo '[3/10] Creating view: vw_recent_sales_trend...'
\echo '       - Shows last 30 days of daily sales'
\echo '       - Includes 7-day moving average for smoothing'

CREATE OR REPLACE VIEW analytics.vw_recent_sales_trend AS
SELECT 
    date_key,
    day_name,
    CASE WHEN day_name IN ('Sat', 'Sun') THEN 1 ELSE 0 END as is_weekend,
    total_orders,
    total_revenue,
    avg_order_value,
    unique_customers,
    
    -- 7-day moving average (smooths out daily fluctuations)
    ROUND(AVG(total_revenue) OVER (
        ORDER BY date_key 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) as moving_avg_7day
FROM analytics.vw_daily_sales_summary
WHERE date_key >= CURRENT_DATE - INTERVAL '156 days'  -- Last 30 days only
ORDER BY date_key DESC;

\echo '       ✓ View created: vw_recent_sales_trend'
\echo ''


-- ============================================================================
-- 4. SALES BY DAY OF WEEK
-- ============================================================================
-- PURPOSE: Identify which days of the week perform best
-- USAGE: SELECT * FROM analytics.vw_sales_by_dayofweek ORDER BY day_order;
-- ============================================================================

\echo '[4/10] Creating view: vw_sales_by_dayofweek...'
\echo '       - Aggregates all sales by day of week'
\echo '       - Shows variance from average day performance'

CREATE OR REPLACE VIEW analytics.vw_sales_by_dayofweek AS
SELECT 
    d.day_name,
    
    -- Day ordering for proper sorting (Mon=1, Sun=7)
    CASE d.day_name
        WHEN 'Mon' THEN 1
        WHEN 'Tue' THEN 2
        WHEN 'Wed' THEN 3
        WHEN 'Thu' THEN 4
        WHEN 'Fri' THEN 5
        WHEN 'Sat' THEN 6
        WHEN 'Sun' THEN 7
    END as day_order,
    
    CASE WHEN d.day_name IN ('Sat','Sun') THEN 1 ELSE 0 END as is_weekend,
    
    -- Performance Metrics
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(AVG(COUNT(DISTINCT o.order_id)) OVER (), 0) as avg_orders, -- Average across all days
    SUM(o.total_amount) as total_revenue,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    COUNT(DISTINCT o.cust_id) as unique_customers,
    
    -- Variance from average (positive = above average, negative = below average)
    ROUND(
        (COUNT(DISTINCT o.order_id) - AVG(COUNT(DISTINCT o.order_id)) OVER ()) / 
        NULLIF(AVG(COUNT(DISTINCT o.order_id)) OVER (), 0) * 100,
        2
    ) as variance_from_avg_pct
FROM sales.orders o
JOIN core.dim_date d ON o.order_date = d.date_key
WHERE o.order_status = 'Delivered'
GROUP BY d.day_name, is_weekend
ORDER BY day_order;

\echo '       ✓ View created: vw_sales_by_dayofweek'
\echo ''


-- ============================================================================
-- 5. SALES BY PAYMENT MODE
-- ============================================================================
-- PURPOSE: Analyze customer payment preferences and transaction sizes
-- USAGE: SELECT * FROM analytics.vw_sales_by_payment_mode ORDER BY total_amount DESC;
-- ============================================================================

\echo '[5/10] Creating view: vw_sales_by_payment_mode...'
\echo '       - Breaks down sales by payment method'
\echo '       - Shows market share of each payment type'

CREATE OR REPLACE VIEW analytics.vw_sales_by_payment_mode AS
SELECT 
    p.payment_mode,                                   -- Payment method (Credit Card, Cash, etc.)
    COUNT(DISTINCT p.payment_id) as transaction_count, -- Number of transactions
    COUNT(DISTINCT p.order_id) as order_count,        -- Number of orders
    SUM(p.amount) as total_amount,                    -- Total payment amount
    ROUND(AVG(p.amount), 2) as avg_transaction_amount, -- Average transaction size
    
    -- Market share calculations
    ROUND(100.0 * SUM(p.amount) / SUM(SUM(p.amount)) OVER (), 2) as pct_of_total_revenue,
    ROUND(100.0 * COUNT(DISTINCT p.payment_id) / SUM(COUNT(DISTINCT p.payment_id)) OVER (), 2) as pct_of_transactions
FROM sales.payments p
JOIN sales.orders o ON p.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.payment_mode
ORDER BY total_amount DESC;

\echo '       ✓ View created: vw_sales_by_payment_mode'
\echo ''


-- ============================================================================
-- 6. SALES VS RETURNS ANALYSIS
-- ============================================================================
-- PURPOSE: Track return rates and impact on net revenue
-- USAGE: SELECT * FROM analytics.vw_sales_returns_analysis ORDER BY year DESC, month DESC;
-- ============================================================================

\echo '[6/10] Creating view: vw_sales_returns_analysis...'
\echo '       - Compares gross sales to returns by month'
\echo '       - Calculates return rate and refund rate percentages'

CREATE OR REPLACE VIEW analytics.vw_sales_returns_analysis AS
WITH sales_data AS (
    -- Monthly sales aggregation
    SELECT 
        d.year,
        d.month,
        d.month_name,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as gross_sales
    FROM sales.orders o
    JOIN core.dim_date d ON o.order_date = d.date_key
    WHERE o.order_status = 'Delivered'
    GROUP BY d.year, d.month, d.month_name
),
returns_data AS (
    -- Monthly returns aggregation
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
    
    -- Return Rate Metrics
    ROUND(100.0 * COALESCE(r.orders_with_returns, 0) / NULLIF(s.total_orders, 0), 2) as return_rate_pct,    -- % of orders returned
    ROUND(100.0 * COALESCE(r.total_refunds, 0) / NULLIF(s.gross_sales, 0), 2) as refund_rate_pct            -- % of revenue refunded
FROM sales_data s
LEFT JOIN returns_data r ON s.year = r.year AND s.month = r.month
ORDER BY s.year DESC, s.month DESC;

\echo '       ✓ View created: vw_sales_returns_analysis'
\echo ''


-- ============================================================================
-- 7. QUARTERLY SALES PERFORMANCE
-- ============================================================================
-- PURPOSE: High-level quarterly business performance tracking
-- USAGE: SELECT * FROM analytics.vw_quarterly_sales ORDER BY year DESC, quarter DESC;
-- ============================================================================

\echo '[7/10] Creating view: vw_quarterly_sales...'
\echo '       - Aggregates sales by quarter'
\echo '       - Shows QoQ (Quarter-over-Quarter) and YoY growth'

CREATE OR REPLACE VIEW analytics.vw_quarterly_sales AS
SELECT 
    d.year,
    d.quarter,
    'Q' || d.quarter || ' ' || d.year as quarter_label,   -- e.g., "Q1 2024"
    
    -- Core Metrics
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.cust_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    SUM(oi.quantity) as total_units_sold,
    
    -- Quarter-over-Quarter Growth
    LAG(SUM(o.total_amount), 1) OVER (ORDER BY d.year, d.quarter) as prev_quarter_revenue,
    ROUND(
        (SUM(o.total_amount) - LAG(SUM(o.total_amount), 1) OVER (ORDER BY d.year, d.quarter)) / 
        NULLIF(LAG(SUM(o.total_amount), 1) OVER (ORDER BY d.year, d.quarter), 0) * 100,
        2
    ) as qoq_growth_pct,
    
    -- Year-over-Year Growth (4 quarters ago = same quarter last year)
    LAG(SUM(o.total_amount), 4) OVER (ORDER BY d.year, d.quarter) as same_quarter_last_year,
    ROUND(
        (SUM(o.total_amount) - LAG(SUM(o.total_amount), 4) OVER (ORDER BY d.year, d.quarter)) / 
        NULLIF(LAG(SUM(o.total_amount), 4) OVER (ORDER BY d.year, d.quarter), 0) * 100,
        2
    ) as yoy_growth_pct
FROM sales.orders o
JOIN core.dim_date d ON o.order_date = d.date_key
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY d.year, d.quarter
ORDER BY d.year DESC, d.quarter DESC;

\echo '       ✓ View created: vw_quarterly_sales'
\echo ''


-- ============================================================================
-- 8. WEEKEND VS WEEKDAY SALES COMPARISON
-- ============================================================================
-- PURPOSE: Compare weekend vs weekday shopping patterns
-- USAGE: SELECT * FROM analytics.vw_weekend_vs_weekday;
-- ============================================================================

\echo '[8/10] Creating view: vw_weekend_vs_weekday...'
\echo '       - Compares weekend vs weekday sales performance'
\echo '       - Useful for staffing and inventory planning'

CREATE OR REPLACE VIEW analytics.vw_weekend_vs_weekday AS
SELECT 
    CASE 
        WHEN d.day_name IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
    END as day_type,
    
    -- Performance Metrics
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(o.total_amount), 2) as total_revenue,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    COUNT(DISTINCT o.cust_id) as unique_customers,
    
    -- Distribution Percentages
    ROUND(100.0 * COUNT(DISTINCT o.order_id) / SUM(COUNT(DISTINCT o.order_id)) OVER (), 2) as pct_of_orders,
    ROUND(100.0 * SUM(o.total_amount) / SUM(SUM(o.total_amount)) OVER (), 2) as pct_of_revenue
FROM sales.orders o
JOIN core.dim_date d ON o.order_date = d.date_key
WHERE o.order_status = 'Delivered'
GROUP BY day_type
ORDER BY day_type;

\echo '       ✓ View created: vw_weekend_vs_weekday'
\echo ''


-- ============================================================================
-- 9. EXECUTIVE SUMMARY - MATERIALIZED VIEW
-- ============================================================================
-- PURPOSE: High-level KPIs for executive dashboard and reporting
-- REFRESH: Manual or scheduled
-- USAGE: SELECT * FROM analytics.mv_executive_summary;
-- ============================================================================

\echo '[9/10] Creating materialized view: mv_executive_summary...'
\echo '       - Top-level business metrics for executives'
\echo '       - Includes 30-day trends and growth rates'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_executive_summary CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_executive_summary AS
WITH overall_metrics AS (
    -- Lifetime business metrics
    SELECT 
        COUNT(DISTINCT order_id) as total_orders,
        COUNT(DISTINCT cust_id) as total_customers,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM sales.orders
    WHERE order_status = 'Delivered'
),
last_30_days AS (
    -- Recent 30-day performance
    SELECT 
        COUNT(DISTINCT order_id) as orders_last_30,
        SUM(total_amount) as revenue_last_30
    FROM sales.orders
    WHERE order_status = 'Delivered'
        AND order_date >= CURRENT_DATE - INTERVAL '30 days'
),
previous_30_days AS (
    -- Previous 30-day period for growth comparison
    SELECT 
        COUNT(DISTINCT order_id) as orders_prev_30,
        SUM(total_amount) as revenue_prev_30
    FROM sales.orders
    WHERE order_status = 'Delivered'
        AND order_date >= CURRENT_DATE - INTERVAL '60 days'
        AND order_date < CURRENT_DATE - INTERVAL '30 days'
),
product_metrics AS (
    -- Product catalog size
    SELECT 
        COUNT(DISTINCT prod_id) as total_products,
        COUNT(DISTINCT category) as total_categories,
        COUNT(DISTINCT brand) as total_brands
    FROM products.products
),
store_metrics AS (
    -- Store footprint
    SELECT 
        COUNT(DISTINCT store_id) as total_stores,
        COUNT(DISTINCT region) as total_regions
    FROM stores.stores
)
SELECT 
    -- Lifetime Metrics
    om.total_orders,
    om.total_customers,
    ROUND(om.total_revenue, 2) as total_revenue,
    ROUND(om.avg_order_value, 2) as avg_order_value,
    
    -- Last 30 Days Performance
    l30.orders_last_30,
    ROUND(l30.revenue_last_30, 2) as revenue_last_30,
    
    -- 30-Day Growth Rate
    ROUND(100.0 * (l30.revenue_last_30 - p30.revenue_prev_30) / NULLIF(p30.revenue_prev_30, 0), 2) as revenue_growth_pct_30d,
    
    -- Catalog & Infrastructure
    pm.total_products,
    pm.total_categories,
    pm.total_brands,
    sm.total_stores,
    sm.total_regions,
    
    -- Metadata
    CURRENT_TIMESTAMP as last_updated
FROM overall_metrics om
CROSS JOIN last_30_days l30
CROSS JOIN previous_30_days p30
CROSS JOIN product_metrics pm
CROSS JOIN store_metrics sm;

\echo '       ✓ Materialized view created: mv_executive_summary'
\echo ''


-- ============================================================================
-- 10. DASHBOARD EXPORT TABLE
-- ============================================================================
-- PURPOSE: Quick summary table for dashboard KPI cards
-- UPDATES: Refresh manually or via scheduled job
-- USAGE: SELECT * FROM analytics.dashboard_sales_summary;
-- ============================================================================

\echo '[10/10] Creating table: dashboard_sales_summary...'
\echo '        - Summary table for Today, Last 7 Days, Last 30 Days'
\echo '        - Used by dashboard for quick KPI display'

DROP TABLE IF EXISTS analytics.dashboard_sales_summary;

CREATE TABLE analytics.dashboard_sales_summary AS
-- Last 30 Days
SELECT 
    'Last 30 Days' as period,
    COUNT(DISTINCT order_id) as total_orders,
    COUNT(DISTINCT cust_id) as unique_customers,
    ROUND(SUM(total_amount), 2) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_order_value
FROM sales.orders
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
    AND order_status = 'Delivered'

UNION ALL

-- Last 7 Days
SELECT 
    'Last 7 Days',
    COUNT(DISTINCT order_id),
    COUNT(DISTINCT cust_id),
    ROUND(SUM(total_amount), 2),
    ROUND(AVG(total_amount), 2)
FROM sales.orders
WHERE order_date >= CURRENT_DATE - INTERVAL '7 days'
    AND order_status = 'Delivered'

UNION ALL

-- Today
SELECT 
    'Today',
    COUNT(DISTINCT order_id),
    COUNT(DISTINCT cust_id),
    ROUND(SUM(total_amount), 2),
    ROUND(AVG(total_amount), 2)
FROM sales.orders
WHERE order_date = CURRENT_DATE
    AND order_status = 'Delivered';

\echo '       ✓ Table created: dashboard_sales_summary'
\echo ''


-- ============================================================================
-- JSON EXPORT FUNCTIONS FOR DASHBOARD INTEGRATION
-- ============================================================================
-- PURPOSE: Provide JSON endpoints for dashboard to consume data
-- USAGE: SELECT analytics.get_executive_summary_json();
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                    CREATING JSON EXPORT FUNCTIONS                          '
\echo '============================================================================'
\echo ''
\echo 'These functions return JSON data for dashboard visualization:'
\echo '  - Executive summary KPIs'
\echo '  - Monthly trends (12 months)'
\echo '  - Recent daily trends (30 days)'
\echo '  - Day of week analysis'
\echo '  - Payment mode breakdown'
\echo '  - Quarterly performance'
\echo '  - Weekend vs Weekday comparison'
\echo ''

-- ----------------------------------------------------------------------------
-- JSON Function 1: Executive Summary
-- ----------------------------------------------------------------------------
\echo '[JSON 1/7] Creating function: get_executive_summary_json()'
\echo '           - Returns all executive KPIs in JSON format'

CREATE OR REPLACE FUNCTION analytics.get_executive_summary_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'totalRevenue', total_revenue,           -- Lifetime revenue
            'totalOrders', total_orders,             -- Lifetime orders
            'totalCustomers', total_customers,       -- Unique customers
            'avgOrderValue', avg_order_value,        -- Average order size
            'ordersLast30', orders_last_30,          -- Recent orders (30d)
            'revenueLast30', revenue_last_30,        -- Recent revenue (30d)
            'revenueGrowth30d', revenue_growth_pct_30d, -- 30-day growth rate
            'totalProducts', total_products,         -- Catalog size
            'totalCategories', total_categories,     -- Number of categories
            'totalBrands', total_brands,             -- Number of brands
            'totalStores', total_stores,             -- Store count
            'totalRegions', total_regions,           -- Geographic reach
            'lastUpdated', last_updated              -- Timestamp
        )
        FROM analytics.mv_executive_summary
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_executive_summary_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 2: Monthly Trend (Last 12 Months)
-- ----------------------------------------------------------------------------
\echo '[JSON 2/7] Creating function: get_monthly_trend_json()'
\echo '           - Returns 12-month sales trend with growth rates'

CREATE OR REPLACE FUNCTION analytics.get_monthly_trend_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'month', month_name,                 -- Month name
                'year', year,                        -- Year
                'revenue', total_revenue,            -- Monthly revenue
                'orders', total_orders,              -- Monthly orders
                'customers', unique_customers,       -- Unique customers
                'avgOrderValue', avg_order_value,    -- Average order value
                'momGrowth', mom_growth_pct,         -- Month-over-month %
                'yoyGrowth', yoy_growth_pct          -- Year-over-year %
            ) ORDER BY year DESC, month DESC
        )
        FROM analytics.mv_monthly_sales_dashboard
        WHERE (year * 100 + month) >= EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '12 months') * 100 
                                      + EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL '12 months')
        LIMIT 12
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_monthly_trend_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 3: Recent 30-Day Trend
-- ----------------------------------------------------------------------------
\echo '[JSON 3/7] Creating function: get_recent_trend_json()'
\echo '           - Returns daily sales for last 30 days with moving average'

CREATE OR REPLACE FUNCTION analytics.get_recent_trend_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'date', date_key,                    -- Date
                'dayName', day_name,                 -- Day of week
                'isWeekend', is_weekend,             -- Weekend flag
                'orders', total_orders,              -- Daily orders
                'revenue', total_revenue,            -- Daily revenue
                'avgOrderValue', avg_order_value,    -- Avg order value
                'movingAvg7Day', moving_avg_7day     -- 7-day moving average
            ) ORDER BY date_key DESC
        )
        FROM analytics.vw_recent_sales_trend
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_recent_trend_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 4: Day of Week Performance
-- ----------------------------------------------------------------------------
\echo '[JSON 4/7] Creating function: get_dayofweek_json()'
\echo '           - Returns sales breakdown by day of week'

CREATE OR REPLACE FUNCTION analytics.get_dayofweek_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'dayName', day_name,                 -- Day name (Mon, Tue, etc.)
                'dayOrder', day_order,               -- Sort order (1-7)
                'isWeekend', is_weekend,             -- Weekend flag
                'orders', total_orders,              -- Total orders
                'revenue', total_revenue,            -- Total revenue
                'avgOrderValue', avg_order_value,    -- Average order value
                'varianceFromAvg', variance_from_avg_pct -- % difference from avg
            ) ORDER BY day_order
        )
        FROM analytics.vw_sales_by_dayofweek
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_dayofweek_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 5: Payment Mode Analysis
-- ----------------------------------------------------------------------------
\echo '[JSON 5/7] Creating function: get_payment_mode_json()'
\echo '           - Returns sales breakdown by payment method'

CREATE OR REPLACE FUNCTION analytics.get_payment_mode_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'paymentMode', payment_mode,         -- Payment method name
                'transactionCount', transaction_count, -- Number of transactions
                'orderCount', order_count,           -- Number of orders
                'totalAmount', total_amount,         -- Total revenue
                'avgTransactionAmount', avg_transaction_amount, -- Avg transaction size
                'pctOfRevenue', pct_of_total_revenue, -- Revenue share %
                'pctOfTransactions', pct_of_transactions -- Transaction share %
            ) ORDER BY total_amount DESC
        )
        FROM analytics.vw_sales_by_payment_mode
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_payment_mode_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 6: Quarterly Sales
-- ----------------------------------------------------------------------------
\echo '[JSON 6/7] Creating function: get_quarterly_sales_json()'
\echo '           - Returns last 8 quarters of sales performance'

CREATE OR REPLACE FUNCTION analytics.get_quarterly_sales_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'year', year,                        -- Year
                'quarter', quarter,                  -- Quarter number (1-4)
                'quarterLabel', quarter_label,       -- Display label (e.g., "Q1 2024")
                'orders', total_orders,              -- Total orders
                'revenue', total_revenue,            -- Total revenue
                'customers', unique_customers,       -- Unique customers
                'qoqGrowth', qoq_growth_pct,        -- Quarter-over-quarter growth %
                'yoyGrowth', yoy_growth_pct         -- Year-over-year growth %
            ) ORDER BY year DESC, quarter DESC
        )
        FROM analytics.vw_quarterly_sales
        LIMIT 8
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_quarterly_sales_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 7: Weekend vs Weekday Comparison
-- ----------------------------------------------------------------------------
\echo '[JSON 7/7] Creating function: get_weekend_weekday_json()'
\echo '           - Returns comparison between weekend and weekday sales'

CREATE OR REPLACE FUNCTION analytics.get_weekend_weekday_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'dayType', day_type,                 -- "Weekend" or "Weekday"
                'orders', total_orders,              -- Total orders
                'revenue', total_revenue,            -- Total revenue
                'avgOrderValue', avg_order_value,    -- Average order value
                'pctOfOrders', pct_of_orders,       -- % of total orders
                'pctOfRevenue', pct_of_revenue      -- % of total revenue
            ) ORDER BY day_type
        )
        FROM analytics.vw_weekend_vs_weekday
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_weekend_weekday_json()'
\echo ''


-- ============================================================================
-- REFRESH MATERIALIZED VIEWS
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '                    REFRESHING MATERIALIZED VIEWS                           '
\echo '============================================================================'
\echo ''

\echo 'Refreshing mv_monthly_sales_dashboard...'
REFRESH MATERIALIZED VIEW analytics.mv_monthly_sales_dashboard;
\echo '✓ Refreshed: mv_monthly_sales_dashboard'

\echo 'Refreshing mv_executive_summary...'
REFRESH MATERIALIZED VIEW analytics.mv_executive_summary;
\echo '✓ Refreshed: mv_executive_summary'

\echo ''


-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '              SALES ANALYTICS MODULE - SUCCESSFULLY CREATED                 '
\echo '============================================================================'
\echo ''
\echo '✅ REGULAR VIEWS (8):'
\echo '   1. vw_daily_sales_summary          - Daily sales metrics'
\echo '   2. vw_recent_sales_trend           - Last 30 days with moving average'
\echo '   3. vw_sales_by_dayofweek          - Day of week performance'
\echo '   4. vw_sales_by_payment_mode       - Payment method analysis'
\echo '   5. vw_sales_returns_analysis      - Returns and refunds tracking'
\echo '   6. vw_quarterly_sales             - Quarterly business performance'
\echo '   7. vw_weekend_vs_weekday          - Weekend vs Weekday comparison'
\echo ''
\echo '✅ MATERIALIZED VIEWS (2):'
\echo '   1. mv_monthly_sales_dashboard     - Monthly trends with growth'
\echo '   2. mv_executive_summary           - Executive KPIs'
\echo ''
\echo '✅ EXPORT TABLES (1):'
\echo '   1. dashboard_sales_summary        - Quick summary (Today/7d/30d)'
\echo ''
\echo '✅ JSON EXPORT FUNCTIONS (7):'
\echo '   1. get_executive_summary_json()   - Executive KPIs'
\echo '   2. get_monthly_trend_json()       - 12-month trend'
\echo '   3. get_recent_trend_json()        - 30-day daily trend'
\echo '   4. get_dayofweek_json()          - Day of week breakdown'
\echo '   5. get_payment_mode_json()       - Payment methods'
\echo '   6. get_quarterly_sales_json()    - 8 quarters'
\echo '   7. get_weekend_weekday_json()    - Weekend vs Weekday'
\echo ''
\echo '📊 USAGE EXAMPLES:'
\echo '   -- View daily sales'
\echo '   SELECT * FROM analytics.vw_daily_sales_summary LIMIT 10;'
\echo ''
\echo '   -- Get executive summary as JSON'
\echo '   SELECT analytics.get_executive_summary_json();'
\echo ''
\echo '   -- Export to file'
\echo '   psql -d retailmart -t -A -c "SELECT analytics.get_monthly_trend_json();" > monthly_trend.json'
\echo ''
\echo '============================================================================'
\echo ''