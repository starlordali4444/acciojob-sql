-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 03_kpi_queries/01_sales_analytics.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Sales Analytics Module — Complete sales performance tracking
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- DESCRIPTION:
--   This is the heart of retail analytics. Every Monday morning at Flipkart,
--   Amazon, or BigBasket, leadership asks: "How did we do last week?"
--   
--   This module answers:
--   - How much revenue did we generate? (Daily, Weekly, Monthly, Quarterly)
--   - Are we growing or declining? (MoM, QoQ, YoY comparisons)
--   - What payment methods do customers prefer?
--   - Weekend vs Weekday performance?
--   - What are the trends? (Moving averages)
--
-- V2 CHANGES:
--   - orders.total_amount → orders.net_total / orders.gross_total
--   - order_items.discount (%) → order_items.discount_amount (absolute ₹)
--   - vw_hourly_sales_pattern → replaced with vw_sales_by_order_status
--     (order_date is DATE in V2, no hourly data)
--
-- CREATES:
--   • 8 Regular Views  
--   • 2 Materialized Views  
--   • 8 JSON Export Functions
--
-- EXECUTION ORDER: Run AFTER 02_data_quality scripts
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '          SALES ANALYTICS MODULE (V2) — STARTING                            '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- VIEW 1: DAILY SALES SUMMARY
-- ============================================================================
-- Purpose: Granular daily metrics for trend analysis
-- V2: net_total instead of total_amount, discount_amount instead of discount %
-- ============================================================================

\echo '[1/10] Creating view: vw_daily_sales_summary...'

CREATE OR REPLACE VIEW analytics.vw_daily_sales_summary AS
WITH daily_metrics AS (
    SELECT 
        d.date_key,
        d.year,
        d.month,
        d.month_name,
        d.quarter,
        d.day_name,
        d.day,
        
        -- Order Metrics
        COUNT(DISTINCT o.order_id) as total_orders,
        COUNT(DISTINCT o.cust_id) as unique_customers,
        COUNT(DISTINCT o.store_id) as active_stores,
        
        -- Revenue Metrics (V2: gross_total, discount_amount, net_total)
        COALESCE(SUM(o.gross_total), 0) as gross_revenue,
        COALESCE(SUM(o.discount_amount), 0) as total_discounts,
        COALESCE(SUM(o.net_total), 0) as net_revenue,
        
        -- Item Metrics
        COALESCE(SUM(oi.quantity), 0) as total_items_sold,
        
        -- Averages
        COALESCE(AVG(o.net_total), 0) as avg_order_value,
        CASE 
            WHEN COALESCE(SUM(o.gross_total), 0) > 0 
            THEN ROUND((COALESCE(SUM(o.discount_amount), 0) / SUM(o.gross_total) * 100)::NUMERIC, 2)
            ELSE 0 
        END as avg_discount_pct
        
    FROM core.dim_date d
    LEFT JOIN sales.orders o ON d.date_key = o.order_date 
        AND o.order_status = 'Delivered'
    LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY d.date_key, d.year, d.month, d.month_name, d.quarter, d.day_name, d.day
)
SELECT 
    *,
    -- Day classification
    CASE WHEN day_name IN ('Sat', 'Sun') THEN 'Weekend' ELSE 'Weekday' END as day_type,
    CASE WHEN day_name IN ('Sat', 'Sun') THEN 1 ELSE 0 END as is_weekend,
    
    -- Day-over-Day comparison
    LAG(net_revenue) OVER (ORDER BY date_key) as prev_day_revenue,
    ROUND(
        (net_revenue - LAG(net_revenue) OVER (ORDER BY date_key)) /
        NULLIF(LAG(net_revenue) OVER (ORDER BY date_key), 0) * 100, 
        2
    ) as dod_growth_pct,
    
    -- 7-day moving average
    ROUND(
        AVG(net_revenue) OVER (
            ORDER BY date_key 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) as moving_avg_7day
    
FROM daily_metrics
ORDER BY date_key DESC;

COMMENT ON VIEW analytics.vw_daily_sales_summary IS 'Daily sales metrics with DoD growth and 7-day moving average';

\echo '      ✓ View created: vw_daily_sales_summary'


-- ============================================================================
-- VIEW 2: RECENT SALES TREND (Last 30 Days)
-- ============================================================================

\echo '[2/10] Creating view: vw_recent_sales_trend...'

CREATE OR REPLACE VIEW analytics.vw_recent_sales_trend AS
SELECT 
    date_key,
    day_name,
    day_type,
    total_orders,
    unique_customers,
    ROUND(net_revenue::NUMERIC, 2) as revenue,
    ROUND(avg_order_value::NUMERIC, 2) as avg_order_value,
    total_items_sold,
    ROUND(dod_growth_pct::NUMERIC, 2) as dod_growth_pct,
    ROUND(moving_avg_7day::NUMERIC, 2) as moving_avg_7day
FROM analytics.vw_daily_sales_summary
WHERE date_key >= (SELECT MAX(order_date) - INTERVAL '30 days' FROM sales.orders)
ORDER BY date_key DESC;

COMMENT ON VIEW analytics.vw_recent_sales_trend IS 'Last 30 days sales for dashboard trend chart';

\echo '      ✓ View created: vw_recent_sales_trend'


-- ============================================================================
-- MATERIALIZED VIEW 1: MONTHLY SALES DASHBOARD
-- ============================================================================
-- V2: Uses gross_total, discount_amount, net_total from orders
-- ============================================================================

\echo '[3/10] Creating materialized view: mv_monthly_sales_dashboard...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_monthly_sales_dashboard CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_monthly_sales_dashboard AS
WITH monthly_base AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        d.quarter,
        
        -- Core Metrics (V2 columns)
        COUNT(DISTINCT o.order_id) as total_orders,
        COUNT(DISTINCT o.cust_id) as unique_customers,
        SUM(o.gross_total) as gross_revenue,
        SUM(o.discount_amount) as total_discounts,
        SUM(o.net_total) as net_revenue,
        SUM(oi.quantity) as total_units_sold,
        AVG(o.net_total) as avg_order_value,
        
        -- New vs Returning (simplified)
        COUNT(DISTINCT o.cust_id) FILTER (
            WHERE o.order_date = (SELECT MIN(o2.order_date) FROM sales.orders o2 WHERE o2.cust_id = o.cust_id)
        ) as new_customers
        
    FROM sales.orders o
    JOIN core.dim_date d ON o.order_date = d.date_key
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY d.year, d.month, d.month_name, d.quarter
),
with_growth AS (
    SELECT 
        *,
        
        -- Previous Period Values
        LAG(net_revenue, 1) OVER (ORDER BY year, month) as prev_month_revenue,
        LAG(net_revenue, 12) OVER (ORDER BY year, month) as prev_year_revenue,
        LAG(total_orders, 1) OVER (ORDER BY year, month) as prev_month_orders,
        
        -- Year-to-Date
        SUM(net_revenue) OVER (
            PARTITION BY year 
            ORDER BY month 
            ROWS UNBOUNDED PRECEDING
        ) as ytd_revenue,
        
        -- Moving Averages
        AVG(net_revenue) OVER (
            ORDER BY year, month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) as moving_avg_3month,
        
        AVG(net_revenue) OVER (
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
    'Q' || quarter || ' ' || year as quarter_label,
    year || '-' || LPAD(month::TEXT, 2, '0') as month_key,
    
    -- Core Metrics (Rounded)
    total_orders,
    unique_customers,
    new_customers,
    unique_customers - new_customers as returning_customers,
    ROUND(gross_revenue::NUMERIC, 2) as gross_revenue,
    ROUND(total_discounts::NUMERIC, 2) as total_discounts,
    ROUND(net_revenue::NUMERIC, 2) as net_revenue,
    total_units_sold,
    ROUND(avg_order_value::NUMERIC, 2) as avg_order_value,
    ROUND((net_revenue / NULLIF(unique_customers, 0))::NUMERIC, 2) as revenue_per_customer,
    
    -- Growth Metrics
    ROUND(prev_month_revenue::NUMERIC, 2) as prev_month_revenue,
    ROUND(
        ((net_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) * 100)::NUMERIC, 
        2
    ) as mom_growth_pct,
    
    ROUND(prev_year_revenue::NUMERIC, 2) as prev_year_revenue,
    ROUND(
        ((net_revenue - prev_year_revenue) / NULLIF(prev_year_revenue, 0) * 100)::NUMERIC, 
        2
    ) as yoy_growth_pct,
    
    -- Cumulative & Averages
    ROUND(ytd_revenue::NUMERIC, 2) as ytd_revenue,
    ROUND(moving_avg_3month::NUMERIC, 2) as moving_avg_3month,
    ROUND(moving_avg_6month::NUMERIC, 2) as moving_avg_6month,
    
    -- Performance Status
    CASE 
        WHEN net_revenue > prev_month_revenue * 1.1 THEN 'Strong Growth'
        WHEN net_revenue > prev_month_revenue THEN 'Growing'
        WHEN net_revenue > prev_month_revenue * 0.9 THEN 'Stable'
        ELSE 'Declining'
    END as performance_status
    
FROM with_growth
ORDER BY year DESC, month DESC;

CREATE INDEX IF NOT EXISTS idx_mv_monthly_year_month 
    ON analytics.mv_monthly_sales_dashboard(year, month);

COMMENT ON MATERIALIZED VIEW analytics.mv_monthly_sales_dashboard IS 
    'Monthly sales metrics with MoM/YoY growth — Refresh daily';

\echo '      ✓ Materialized view created: mv_monthly_sales_dashboard'


-- ============================================================================
-- MATERIALIZED VIEW 2: EXECUTIVE SUMMARY
-- ============================================================================
-- V2: net_total instead of total_amount
-- ============================================================================

\echo '[4/10] Creating materialized view: mv_executive_summary...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_executive_summary CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_executive_summary AS
WITH 
reference_date AS (
    SELECT MAX(order_date) as ref_date FROM sales.orders
),
current_period AS (
    SELECT 
        COUNT(DISTINCT order_id) as orders_30d,
        COUNT(DISTINCT cust_id) as customers_30d,
        SUM(net_total) as revenue_30d,
        AVG(net_total) as aov_30d
    FROM sales.orders, reference_date
    WHERE order_status = 'Delivered'
    AND order_date > ref_date - INTERVAL '30 days'
),
previous_period AS (
    SELECT 
        COUNT(DISTINCT order_id) as orders_prev,
        SUM(net_total) as revenue_prev
    FROM sales.orders, reference_date
    WHERE order_status = 'Delivered'
    AND order_date BETWEEN ref_date - INTERVAL '60 days' AND ref_date - INTERVAL '30 days'
),
all_time AS (
    SELECT 
        COUNT(DISTINCT order_id) as total_orders,
        COUNT(DISTINCT cust_id) as total_customers,
        SUM(net_total) as total_revenue,
        AVG(net_total) as overall_aov
    FROM sales.orders
    WHERE order_status = 'Delivered'
),
today_stats AS (
    SELECT 
        COUNT(DISTINCT order_id) as orders_today,
        SUM(net_total) as revenue_today
    FROM sales.orders, reference_date
    WHERE order_status = 'Delivered'
    AND order_date = ref_date
)
SELECT 
    (SELECT ref_date FROM reference_date) as reference_date,
    
    -- All Time
    a.total_orders,
    a.total_customers,
    ROUND(a.total_revenue::NUMERIC, 2) as total_revenue,
    ROUND(a.overall_aov::NUMERIC, 2) as overall_aov,
    
    -- Today
    COALESCE(t.orders_today, 0) as orders_today,
    ROUND(COALESCE(t.revenue_today, 0)::NUMERIC, 2) as revenue_today,
    
    -- Last 30 Days
    c.orders_30d,
    c.customers_30d,
    ROUND(c.revenue_30d::NUMERIC, 2) as revenue_30d,
    ROUND(c.aov_30d::NUMERIC, 2) as aov_30d,
    
    -- Growth
    ROUND(
        ((c.revenue_30d - p.revenue_prev) / NULLIF(p.revenue_prev, 0) * 100)::NUMERIC, 2
    ) as revenue_growth_pct,
    ROUND(
        ((c.orders_30d - p.orders_prev) / NULLIF(p.orders_prev, 0) * 100)::NUMERIC, 2
    ) as orders_growth_pct,
    
    -- Averages
    ROUND((c.revenue_30d / 30)::NUMERIC, 2) as avg_daily_revenue,
    ROUND((c.orders_30d::NUMERIC / 30), 1) as avg_daily_orders
    
FROM all_time a
CROSS JOIN current_period c
CROSS JOIN previous_period p
CROSS JOIN today_stats t;

COMMENT ON MATERIALIZED VIEW analytics.mv_executive_summary IS 'Executive KPI cards — Refresh hourly';

\echo '      ✓ Materialized view created: mv_executive_summary'


-- ============================================================================
-- VIEW 3: SALES BY DAY OF WEEK
-- ============================================================================

\echo '[5/10] Creating view: vw_sales_by_dayofweek...'

CREATE OR REPLACE VIEW analytics.vw_sales_by_dayofweek AS
WITH dow_stats AS (
    SELECT 
        d.day_name,
        CASE d.day_name
            WHEN 'Mon' THEN 1 WHEN 'Tue' THEN 2 WHEN 'Wed' THEN 3
            WHEN 'Thu' THEN 4 WHEN 'Fri' THEN 5 WHEN 'Sat' THEN 6
            WHEN 'Sun' THEN 7
        END as day_order,
        CASE WHEN d.day_name IN ('Sat', 'Sun') THEN 1 ELSE 0 END as is_weekend,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.net_total) as total_revenue,
        AVG(o.net_total) as avg_order_value,
        COUNT(DISTINCT d.date_key) as days_count
    FROM core.dim_date d
    LEFT JOIN sales.orders o ON d.date_key = o.order_date AND o.order_status = 'Delivered'
    WHERE d.date_key <= (SELECT MAX(order_date) FROM sales.orders)
    GROUP BY d.day_name
),
with_avg AS (
    SELECT *, AVG(total_revenue) OVER () as overall_avg_revenue
    FROM dow_stats
)
SELECT 
    day_name,
    day_order,
    is_weekend,
    total_orders,
    ROUND(total_revenue::NUMERIC, 2) as total_revenue,
    ROUND(avg_order_value::NUMERIC, 2) as avg_order_value,
    ROUND((total_revenue / days_count)::NUMERIC, 2) as avg_daily_revenue,
    ROUND(
        ((total_revenue - overall_avg_revenue) / NULLIF(overall_avg_revenue, 0) * 100)::NUMERIC, 2
    ) as variance_from_avg_pct,
    RANK() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM with_avg
ORDER BY day_order;

COMMENT ON VIEW analytics.vw_sales_by_dayofweek IS 'Sales performance by day of week';

\echo '      ✓ View created: vw_sales_by_dayofweek'


-- ============================================================================
-- VIEW 4: SALES BY PAYMENT MODE
-- ============================================================================

\echo '[6/10] Creating view: vw_sales_by_payment_mode...'

CREATE OR REPLACE VIEW analytics.vw_sales_by_payment_mode AS
WITH payment_stats AS (
    SELECT 
        p.payment_mode,
        COUNT(*) as transaction_count,
        COUNT(DISTINCT p.order_id) as order_count,
        SUM(p.amount) as total_amount,
        AVG(p.amount) as avg_transaction_amount
    FROM sales.payments p
    JOIN sales.orders o ON p.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.payment_mode
)
SELECT 
    payment_mode,
    transaction_count,
    order_count,
    ROUND(total_amount::NUMERIC, 2) as total_amount,
    ROUND(avg_transaction_amount::NUMERIC, 2) as avg_transaction_amount,
    ROUND(
        (total_amount / SUM(total_amount) OVER () * 100)::NUMERIC, 2
    ) as pct_of_revenue,
    ROUND(
        (transaction_count::NUMERIC / SUM(transaction_count) OVER () * 100)::NUMERIC, 2
    ) as pct_of_transactions,
    RANK() OVER (ORDER BY total_amount DESC) as revenue_rank
FROM payment_stats
ORDER BY total_amount DESC;

COMMENT ON VIEW analytics.vw_sales_by_payment_mode IS 'Revenue breakdown by payment method';

\echo '      ✓ View created: vw_sales_by_payment_mode'


-- ============================================================================
-- VIEW 5: QUARTERLY SALES
-- ============================================================================

\echo '[7/10] Creating view: vw_quarterly_sales...'

CREATE OR REPLACE VIEW analytics.vw_quarterly_sales AS
WITH quarterly_base AS (
    SELECT 
        d.year,
        d.quarter,
        COUNT(DISTINCT o.order_id) as total_orders,
        COUNT(DISTINCT o.cust_id) as unique_customers,
        SUM(o.net_total) as total_revenue,
        AVG(o.net_total) as avg_order_value
    FROM sales.orders o
    JOIN core.dim_date d ON o.order_date = d.date_key
    WHERE o.order_status = 'Delivered'
    GROUP BY d.year, d.quarter
)
SELECT 
    year,
    quarter,
    'Q' || quarter || ' ' || year as quarter_label,
    total_orders,
    unique_customers,
    ROUND(total_revenue::NUMERIC, 2) as total_revenue,
    ROUND(avg_order_value::NUMERIC, 2) as avg_order_value,
    ROUND(
        ((total_revenue - LAG(total_revenue) OVER (ORDER BY year, quarter)) /
        NULLIF(LAG(total_revenue) OVER (ORDER BY year, quarter), 0) * 100)::NUMERIC, 2
    ) as qoq_growth_pct,
    ROUND(
        ((total_revenue - LAG(total_revenue, 4) OVER (ORDER BY year, quarter)) /
        NULLIF(LAG(total_revenue, 4) OVER (ORDER BY year, quarter), 0) * 100)::NUMERIC, 2
    ) as yoy_growth_pct
FROM quarterly_base
ORDER BY year DESC, quarter DESC;

COMMENT ON VIEW analytics.vw_quarterly_sales IS 'Quarterly sales with QoQ and YoY growth';

\echo '      ✓ View created: vw_quarterly_sales'


-- ============================================================================
-- VIEW 6: WEEKEND VS WEEKDAY COMPARISON
-- ============================================================================

\echo '[8/10] Creating view: vw_weekend_vs_weekday...'

CREATE OR REPLACE VIEW analytics.vw_weekend_vs_weekday AS
WITH classified AS (
    SELECT 
        CASE WHEN d.day_name IN ('Sat', 'Sun') THEN 'Weekend' ELSE 'Weekday' END as day_type,
        o.order_id,
        o.net_total,
        o.cust_id
    FROM sales.orders o
    JOIN core.dim_date d ON o.order_date = d.date_key
    WHERE o.order_status = 'Delivered'
)
SELECT 
    day_type,
    COUNT(DISTINCT order_id) as total_orders,
    COUNT(DISTINCT cust_id) as unique_customers,
    ROUND(SUM(net_total)::NUMERIC, 2) as total_revenue,
    ROUND(AVG(net_total)::NUMERIC, 2) as avg_order_value,
    ROUND(
        (COUNT(DISTINCT order_id)::NUMERIC / SUM(COUNT(DISTINCT order_id)) OVER () * 100)::NUMERIC, 2
    ) as pct_of_orders,
    ROUND(
        (SUM(net_total) / SUM(SUM(net_total)) OVER () * 100)::NUMERIC, 2
    ) as pct_of_revenue
FROM classified
GROUP BY day_type
ORDER BY day_type;

COMMENT ON VIEW analytics.vw_weekend_vs_weekday IS 'Weekend vs Weekday sales comparison';

\echo '      ✓ View created: vw_weekend_vs_weekday'


-- ============================================================================
-- VIEW 7: SALES BY ORDER STATUS (V2 — replaces vw_hourly_sales_pattern)
-- ============================================================================
-- V2: order_date is DATE type, no hourly data available.
-- This view replaces the hourly pattern with order status breakdown,
-- which is more useful for operations monitoring.
-- ============================================================================

\echo '[9/10] Creating view: vw_sales_by_order_status...'

CREATE OR REPLACE VIEW analytics.vw_sales_by_order_status AS
WITH status_stats AS (
    SELECT 
        order_status,
        COUNT(*) as order_count,
        SUM(gross_total) as gross_revenue,
        SUM(net_total) as net_revenue,
        AVG(net_total) as avg_order_value,
        MIN(order_date) as earliest_order,
        MAX(order_date) as latest_order
    FROM sales.orders
    GROUP BY order_status
)
SELECT 
    order_status,
    order_count,
    ROUND(gross_revenue::NUMERIC, 2) as gross_revenue,
    ROUND(net_revenue::NUMERIC, 2) as net_revenue,
    ROUND(avg_order_value::NUMERIC, 2) as avg_order_value,
    earliest_order,
    latest_order,
    ROUND(
        (order_count::NUMERIC / SUM(order_count) OVER () * 100)::NUMERIC, 2
    ) as pct_of_orders,
    ROUND(
        (gross_revenue / SUM(gross_revenue) OVER () * 100)::NUMERIC, 2
    ) as pct_of_revenue
FROM status_stats
ORDER BY order_count DESC;

COMMENT ON VIEW analytics.vw_sales_by_order_status IS 'Order distribution by status — V2 replacement for hourly pattern';

\echo '      ✓ View created: vw_sales_by_order_status'


-- ============================================================================
-- VIEW 8: SALES RETURNS ANALYSIS
-- ============================================================================

\echo '[10/10] Creating view: vw_sales_returns_analysis...'

CREATE OR REPLACE VIEW analytics.vw_sales_returns_analysis AS
WITH return_stats AS (
    SELECT 
        DATE_TRUNC('month', r.return_date)::DATE as return_month,
        COUNT(*) as return_count,
        SUM(r.refund_amount) as total_refunds,
        COUNT(DISTINCT r.order_id) as orders_with_returns
    FROM sales.returns r
    GROUP BY DATE_TRUNC('month', r.return_date)
),
order_stats AS (
    SELECT 
        DATE_TRUNC('month', order_date)::DATE as order_month,
        COUNT(DISTINCT order_id) as total_orders,
        SUM(net_total) as total_revenue
    FROM sales.orders
    WHERE order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    o.order_month,
    TO_CHAR(o.order_month, 'Mon YYYY') as month_name,
    o.total_orders,
    ROUND(o.total_revenue::NUMERIC, 2) as total_revenue,
    COALESCE(r.return_count, 0) as return_count,
    COALESCE(r.orders_with_returns, 0) as orders_with_returns,
    ROUND(COALESCE(r.total_refunds, 0)::NUMERIC, 2) as total_refunds,
    ROUND(
        (COALESCE(r.orders_with_returns, 0)::NUMERIC / NULLIF(o.total_orders, 0) * 100)::NUMERIC, 2
    ) as return_rate_pct,
    ROUND(
        (COALESCE(r.total_refunds, 0) / NULLIF(o.total_revenue, 0) * 100)::NUMERIC, 2
    ) as refund_rate_pct
FROM order_stats o
LEFT JOIN return_stats r ON o.order_month = r.return_month
ORDER BY o.order_month DESC;

COMMENT ON VIEW analytics.vw_sales_returns_analysis IS 'Monthly return rates and refund analysis';

\echo '      ✓ View created: vw_sales_returns_analysis'


-- ============================================================================
-- JSON EXPORT FUNCTIONS
-- ============================================================================

\echo ''
\echo 'Creating JSON export functions...'

-- JSON 1: Executive Summary
CREATE OR REPLACE FUNCTION analytics.get_executive_summary_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT row_to_json(t)
        FROM analytics.mv_executive_summary t
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 2: Monthly Trend (Last 12 months)
CREATE OR REPLACE FUNCTION analytics.get_monthly_trend_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'monthKey', month_key,
                'monthName', month_name,
                'year', year,
                'month', month,
                'quarter', quarter_label,
                'orders', total_orders,
                'customers', unique_customers,
                'grossRevenue', gross_revenue,
                'netRevenue', net_revenue,
                'aov', avg_order_value,
                'momGrowth', mom_growth_pct,
                'yoyGrowth', yoy_growth_pct,
                'ytdRevenue', ytd_revenue,
                'movingAvg3M', moving_avg_3month,
                'status', performance_status
            ) ORDER BY year DESC, month DESC
        )
        FROM analytics.mv_monthly_sales_dashboard
        LIMIT 12
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 3: Recent Trend (Last 30 days)
CREATE OR REPLACE FUNCTION analytics.get_recent_trend_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'date', date_key,
                'dayName', day_name,
                'dayType', day_type,
                'orders', total_orders,
                'revenue', revenue,
                'aov', avg_order_value,
                'items', total_items_sold,
                'dodGrowth', dod_growth_pct,
                'movingAvg7D', moving_avg_7day
            ) ORDER BY date_key
        )
        FROM analytics.vw_recent_sales_trend
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 4: Day of Week
CREATE OR REPLACE FUNCTION analytics.get_dayofweek_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'dayName', day_name,
                'dayOrder', day_order,
                'isWeekend', is_weekend,
                'orders', total_orders,
                'revenue', total_revenue,
                'avgOrderValue', avg_order_value,
                'varianceFromAvg', variance_from_avg_pct,
                'rank', revenue_rank
            ) ORDER BY day_order
        )
        FROM analytics.vw_sales_by_dayofweek
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 5: Payment Mode
CREATE OR REPLACE FUNCTION analytics.get_payment_mode_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'paymentMode', payment_mode,
                'transactions', transaction_count,
                'orders', order_count,
                'amount', total_amount,
                'avgAmount', avg_transaction_amount,
                'pctRevenue', pct_of_revenue,
                'pctTransactions', pct_of_transactions,
                'rank', revenue_rank
            ) ORDER BY revenue_rank
        )
        FROM analytics.vw_sales_by_payment_mode
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 6: Quarterly Sales
CREATE OR REPLACE FUNCTION analytics.get_quarterly_sales_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'year', year,
                'quarter', quarter,
                'quarterLabel', quarter_label,
                'orders', total_orders,
                'customers', unique_customers,
                'revenue', total_revenue,
                'aov', avg_order_value,
                'qoqGrowth', qoq_growth_pct,
                'yoyGrowth', yoy_growth_pct
            ) ORDER BY year DESC, quarter DESC
        )
        FROM analytics.vw_quarterly_sales
        LIMIT 8
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 7: Weekend vs Weekday
CREATE OR REPLACE FUNCTION analytics.get_weekend_weekday_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'dayType', day_type,
                'orders', total_orders,
                'customers', unique_customers,
                'revenue', total_revenue,
                'aov', avg_order_value,
                'pctOrders', pct_of_orders,
                'pctRevenue', pct_of_revenue
            ) ORDER BY day_type
        )
        FROM analytics.vw_weekend_vs_weekday
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 8: Order Status (V2 — replaces hourly pattern)
CREATE OR REPLACE FUNCTION analytics.get_order_status_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'status', order_status,
                'orders', order_count,
                'grossRevenue', gross_revenue,
                'netRevenue', net_revenue,
                'avgOrderValue', avg_order_value,
                'pctOrders', pct_of_orders,
                'pctRevenue', pct_of_revenue
            ) ORDER BY order_count DESC
        )
        FROM analytics.vw_sales_by_order_status
    );
END;
$$ LANGUAGE plpgsql STABLE;

\echo '      ✓ JSON functions created (8 functions)'


-- ============================================================================
-- REFRESH MATERIALIZED VIEWS
-- ============================================================================

\echo ''
\echo 'Refreshing materialized views...'

REFRESH MATERIALIZED VIEW analytics.mv_monthly_sales_dashboard;
REFRESH MATERIALIZED VIEW analytics.mv_executive_summary;

\echo '✓ Materialized views refreshed'


-- ============================================================================
-- VERIFICATION
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '            SALES ANALYTICS MODULE (V2) — COMPLETE                          '
\echo '============================================================================'
\echo ''
\echo '✅ Regular Views (8):'
\echo '   • vw_daily_sales_summary      — Daily metrics with DoD growth'
\echo '   • vw_recent_sales_trend       — Last 30 days'
\echo '   • vw_sales_by_dayofweek       — Day of week performance'
\echo '   • vw_sales_by_payment_mode    — Payment method breakdown'
\echo '   • vw_quarterly_sales          — Quarterly with QoQ/YoY'
\echo '   • vw_weekend_vs_weekday       — Weekend comparison'
\echo '   • vw_sales_by_order_status    — Order status breakdown (V2 new)'
\echo '   • vw_sales_returns_analysis   — Return rates'
\echo ''
\echo '✅ Materialized Views (2):'
\echo '   • mv_monthly_sales_dashboard  — Monthly trends'
\echo '   • mv_executive_summary        — Executive KPIs'
\echo ''
\echo '✅ JSON Functions (8):'
\echo '   • get_executive_summary_json()'
\echo '   • get_monthly_trend_json()'
\echo '   • get_recent_trend_json()'
\echo '   • get_dayofweek_json()'
\echo '   • get_payment_mode_json()'
\echo '   • get_quarterly_sales_json()'
\echo '   • get_weekend_weekday_json()'
\echo '   • get_order_status_json()     (V2 — replaces hourly pattern)'
\echo ''
\echo '📊 Quick Test:'
\echo '   SELECT * FROM analytics.mv_executive_summary;'
\echo '   SELECT analytics.get_executive_summary_json();'
\echo ''
\echo '➡️  Next: Run 02_customer_analytics.sql'
\echo '============================================================================'
\echo ''

SELECT * FROM analytics.mv_executive_summary;