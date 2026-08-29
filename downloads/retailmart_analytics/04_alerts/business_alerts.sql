-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 04_alerts/business_alerts.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Business Alerts — Automated monitoring and anomaly detection
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- V2 CHANGES:
--   - stock_qty → quantity_on_hand, product_name, product_id
--   - full_name → first_name || ' ' || last_name
--   - total_amount → net_total
--   - category via JOIN chain
--   - NEW: API degradation, error spike, suspicious changes, low attendance, production quality
--
-- DEPENDENCY: Must run AFTER all 03_kpi_queries/ scripts
--   (references mv_customer_lifetime_value, vw_audit_*, vw_production_*)
--
-- CREATES: 12 Alert Views + 1 Consolidated View + 1 JSON Function
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '         BUSINESS ALERTS MODULE (V2) — STARTING                             '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- EXISTING ALERTS (updated for V2 schema)
-- ============================================================================

\echo '[1/12] Creating alert: vw_alert_critical_stock...'

CREATE OR REPLACE VIEW analytics.vw_alert_critical_stock AS
SELECT 
    'CRITICAL_STOCK' as alert_type, 'HIGH' as severity,
    p.product_id, p.product_name, 
    cat.category_name as category,
    s.store_name, 
    i.quantity_on_hand as current_stock,
    i.reorder_level,
    'Product ' || p.product_name || ' has only ' || i.quantity_on_hand || ' units at ' || s.store_name as alert_message,
    'Urgent: Reorder immediately' as recommended_action
FROM products.inventory i
JOIN products.products p ON i.product_id = p.product_id
JOIN core.dim_brand b ON p.brand_id = b.brand_id
JOIN core.dim_category cat ON b.category_id = cat.category_id
JOIN stores.stores s ON i.store_id = s.store_id
WHERE i.quantity_on_hand < (SELECT analytics.get_config_number('alert_stock_critical'))
ORDER BY i.quantity_on_hand;

\echo '      ✓ Alert view created: vw_alert_critical_stock'


\echo '[2/12] Creating alert: vw_alert_high_value_churn...'

CREATE OR REPLACE VIEW analytics.vw_alert_high_value_churn AS
SELECT 
    'HIGH_VALUE_CHURN' as alert_type, 'CRITICAL' as severity,
    customer_id, full_name,
    clv_tier, total_revenue,
    days_since_last_order,
    full_name || ' (' || clv_tier || ', ₹' || ROUND(total_revenue::NUMERIC, 0) || ') inactive for ' || days_since_last_order || ' days' as alert_message,
    CASE 
        WHEN clv_tier = 'Platinum' THEN 'Immediate personal outreach by account manager'
        WHEN clv_tier = 'Gold' THEN 'Send exclusive offer + loyalty bonus within 24 hours'
        ELSE 'Send re-engagement email with personalized recommendations'
    END as recommended_action
FROM analytics.mv_customer_lifetime_value
WHERE clv_tier IN ('Platinum', 'Gold')
AND days_since_last_order > (SELECT analytics.get_config_number('alert_churn_days_platinum'))
ORDER BY total_revenue DESC;

\echo '      ✓ Alert view created: vw_alert_high_value_churn'


\echo '[3/12] Creating alert: vw_alert_revenue_anomaly...'

CREATE OR REPLACE VIEW analytics.vw_alert_revenue_anomaly AS
WITH daily_revenue AS (
    SELECT order_date, SUM(net_total) as daily_revenue
    FROM sales.orders WHERE order_status = 'Delivered'
    GROUP BY order_date
),
with_avg AS (
    SELECT *, 
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) as avg_7day
    FROM daily_revenue
)
SELECT 
    'REVENUE_ANOMALY' as alert_type, 'HIGH' as severity,
    order_date,
    ROUND(daily_revenue::NUMERIC, 2) as daily_revenue,
    ROUND(avg_7day::NUMERIC, 2) as avg_7day_revenue,
    ROUND(((daily_revenue - avg_7day) / NULLIF(avg_7day, 0) * 100)::NUMERIC, 2) as variance_pct,
    'Revenue on ' || order_date || ' was ₹' || ROUND(daily_revenue::NUMERIC, 0) || ' vs 7-day avg ₹' || ROUND(avg_7day::NUMERIC, 0) as alert_message,
    'Investigate: Check for system issues, stock-outs, or external factors' as recommended_action
FROM with_avg
WHERE avg_7day > 0
AND daily_revenue < avg_7day * (1 - (SELECT analytics.get_config_number('alert_revenue_drop_pct')) / 100)
ORDER BY order_date DESC;

\echo '      ✓ Alert view created: vw_alert_revenue_anomaly'


\echo '[4/12] Creating alert: vw_alert_delayed_shipments...'

CREATE OR REPLACE VIEW analytics.vw_alert_delayed_shipments AS
SELECT 
    'DELAYED_SHIPMENT' as alert_type,
    CASE WHEN (SELECT MAX(order_date) FROM sales.orders) - o.order_date > 7 THEN 'CRITICAL' ELSE 'HIGH' END as severity,
    o.order_id, o.order_date,
    (SELECT MAX(order_date) FROM sales.orders) - o.order_date as days_since_order,
    c.first_name || ' ' || c.last_name as customer_name,
    o.net_total as order_amount,
    COALESCE(sh.status, 'Not Shipped') as shipment_status,
    'Order #' || o.order_id || ' placed ' || ((SELECT MAX(order_date) FROM sales.orders) - o.order_date) || ' days ago, status: ' || COALESCE(sh.status, 'Not Shipped') as alert_message,
    'Escalate to logistics team immediately' as recommended_action
FROM sales.orders o
LEFT JOIN sales.shipments sh ON o.order_id = sh.order_id
JOIN customers.customers c ON o.cust_id = c.customer_id
WHERE o.order_status != 'Delivered'
AND (sh.status IS NULL OR sh.status != 'Delivered')
AND o.order_date < (SELECT MAX(order_date) - INTERVAL '3 days' FROM sales.orders)
ORDER BY days_since_order DESC;

\echo '      ✓ Alert view created: vw_alert_delayed_shipments'


\echo '[5/12] Creating alert: vw_alert_high_return_rate...'

CREATE OR REPLACE VIEW analytics.vw_alert_high_return_rate AS
WITH category_returns AS (
    SELECT 
        cat.category_name as category,
        COUNT(DISTINCT r.return_id) as return_count,
        COUNT(DISTINCT oi.order_id) as total_orders,
        ROUND((COUNT(DISTINCT r.return_id)::NUMERIC / NULLIF(COUNT(DISTINCT oi.order_id), 0) * 100), 2) as return_rate_pct
    FROM sales.returns r
    JOIN products.products p ON r.prod_id = p.product_id
    JOIN core.dim_brand b ON p.brand_id = b.brand_id
    JOIN core.dim_category cat ON b.category_id = cat.category_id
    JOIN sales.order_items oi ON p.product_id = oi.prod_id
    JOIN sales.orders o ON oi.order_id = o.order_id AND o.order_status = 'Delivered'
    GROUP BY cat.category_name
)
SELECT 
    'HIGH_RETURN_RATE' as alert_type, 'HIGH' as severity,
    category,
    return_count, total_orders, return_rate_pct,
    category || ' has ' || return_rate_pct || '% return rate (' || return_count || ' returns / ' || total_orders || ' orders)' as alert_message,
    'Review product quality, descriptions, and customer feedback for ' || category as recommended_action
FROM category_returns
WHERE return_rate_pct > (SELECT analytics.get_config_number('alert_return_rate_threshold'))
ORDER BY return_rate_pct DESC;

\echo '      ✓ Alert view created: vw_alert_high_return_rate'


\echo '[6/12] Creating alert: vw_alert_low_stock...'

CREATE OR REPLACE VIEW analytics.vw_alert_low_stock AS
SELECT 
    'LOW_STOCK' as alert_type, 'MEDIUM' as severity,
    p.product_id, p.product_name,
    cat.category_name as category,
    SUM(i.quantity_on_hand) as total_stock,
    COUNT(DISTINCT i.store_id) as stores_with_stock,
    'Product ' || p.product_name || ' has only ' || SUM(i.quantity_on_hand) || ' units across ' || COUNT(DISTINCT i.store_id) || ' stores' as alert_message,
    'Plan reorder within this week' as recommended_action
FROM products.inventory i
JOIN products.products p ON i.product_id = p.product_id
JOIN core.dim_brand b ON p.brand_id = b.brand_id
JOIN core.dim_category cat ON b.category_id = cat.category_id
GROUP BY p.product_id, p.product_name, cat.category_name
HAVING SUM(i.quantity_on_hand) < (SELECT analytics.get_config_number('alert_stock_low'))
AND SUM(i.quantity_on_hand) >= (SELECT analytics.get_config_number('alert_stock_critical'))
ORDER BY total_stock;

\echo '      ✓ Alert view created: vw_alert_low_stock'


-- ============================================================================
-- 🆕 NEW ALERTS (V2)
-- ============================================================================

\echo '[7/12] Creating alert: vw_alert_api_degradation...'

CREATE OR REPLACE VIEW analytics.vw_alert_api_degradation AS
SELECT 
    'API_DEGRADATION' as alert_type, 'HIGH' as severity,
    endpoint, method,
    total_requests,
    avg_response_ms, p95_response_ms,
    failure_rate_pct,
    health_status,
    method || ' ' || endpoint || ' — avg ' || avg_response_ms || 'ms, p95 ' || p95_response_ms || 'ms, ' || failure_rate_pct || '% failures' as alert_message,
    'Investigate endpoint performance, check database queries and external dependencies' as recommended_action
FROM analytics.vw_audit_api_performance
WHERE health_status IN ('Critical', 'Degraded', 'Slow')
ORDER BY avg_response_ms DESC;

\echo '      ✓ Alert view created: vw_alert_api_degradation'


\echo '[8/12] Creating alert: vw_alert_error_spike...'

CREATE OR REPLACE VIEW analytics.vw_alert_error_spike AS
WITH service_errors AS (
    SELECT 
        service_name,
        SUM(CASE WHEN level IN ('ERROR', 'FATAL') THEN log_count ELSE 0 END) as error_count,
        SUM(log_count) as total_count,
        ROUND((SUM(CASE WHEN level IN ('ERROR', 'FATAL') THEN log_count ELSE 0 END)::NUMERIC / 
               NULLIF(SUM(log_count), 0) * 100), 2) as error_rate_pct
    FROM analytics.vw_audit_error_tracking
    WHERE log_date >= CURRENT_DATE - INTERVAL '1 day'
    GROUP BY service_name
)
SELECT 
    'ERROR_SPIKE' as alert_type, 
    CASE WHEN error_rate_pct > 10 THEN 'CRITICAL' ELSE 'HIGH' END as severity,
    service_name,
    error_count, total_count, error_rate_pct,
    service_name || ' has ' || error_rate_pct || '% error rate (' || error_count || ' errors in last 24h)' as alert_message,
    'Check application logs, recent deployments, and infrastructure health' as recommended_action
FROM service_errors
WHERE error_rate_pct > (SELECT analytics.get_config_number('alert_error_rate_pct'))
ORDER BY error_rate_pct DESC;

\echo '      ✓ Alert view created: vw_alert_error_spike'


\echo '[9/12] Creating alert: vw_alert_suspicious_changes...'

CREATE OR REPLACE VIEW analytics.vw_alert_suspicious_changes AS
SELECT 
    'SUSPICIOUS_CHANGE' as alert_type, 'CRITICAL' as severity,
    employee_id, employee_name, role,
    table_name, action,
    change_count, changes_per_hour,
    risk_flag,
    COALESCE(employee_name, 'Unknown (ID: ' || employee_id || ')') || ' made ' || change_count || ' ' || action || ' changes on ' || table_name || ' (' || COALESCE(changes_per_hour::TEXT, 'N/A') || '/hr)' as alert_message,
    'Review changes immediately, verify authorization' as recommended_action
FROM analytics.vw_audit_unauthorized_changes
WHERE risk_flag IN ('Suspicious', 'Review Needed')
ORDER BY change_count DESC;

\echo '      ✓ Alert view created: vw_alert_suspicious_changes'


\echo '[10/12] Creating alert: vw_alert_low_attendance...'

CREATE OR REPLACE VIEW analytics.vw_alert_low_attendance AS
SELECT 
    'LOW_ATTENDANCE' as alert_type, 'MEDIUM' as severity,
    department,
    attend_month,
    month_name,
    employee_count,
    avg_days_present,
    attendance_pct,
    department || ' had ' || attendance_pct || '% attendance in ' || month_name || ' (' || ROUND(avg_days_present, 0) || ' avg days)' as alert_message,
    'Review department workload, check for patterns, discuss with HR' as recommended_action
FROM analytics.vw_hr_attendance_summary
WHERE attendance_pct < (SELECT analytics.get_config_number('alert_low_attendance_pct'))
ORDER BY attendance_pct;

\echo '      ✓ Alert view created: vw_alert_low_attendance'


\echo '[11/12] Creating alert: vw_alert_production_quality...'

CREATE OR REPLACE VIEW analytics.vw_alert_production_quality AS
SELECT 
    'PRODUCTION_QUALITY' as alert_type, 'HIGH' as severity,
    line_name,
    supervisor_name,
    total_produced, total_rejected,
    reject_rate_pct,
    line_name || ' has ' || reject_rate_pct || '% reject rate (' || total_rejected || '/' || total_produced || ' units)' as alert_message,
    'Inspect production line, review recent maintenance, check raw material quality' as recommended_action
FROM analytics.vw_production_line_efficiency
WHERE reject_rate_pct > (SELECT analytics.get_config_number('alert_production_reject_pct'))
ORDER BY reject_rate_pct DESC;

\echo '      ✓ Alert view created: vw_alert_production_quality'


-- ============================================================================
-- CONSOLIDATED ALERT VIEW
-- ============================================================================

\echo '[12/12] Creating consolidated alert view...'

CREATE OR REPLACE VIEW analytics.vw_all_active_alerts AS
SELECT alert_type, severity, alert_message, recommended_action, product_name as entity_name, current_stock::TEXT as metric FROM analytics.vw_alert_critical_stock
UNION ALL SELECT alert_type, severity, alert_message, recommended_action, full_name, days_since_last_order::TEXT FROM analytics.vw_alert_high_value_churn
UNION ALL SELECT alert_type, severity, alert_message, recommended_action, order_date::TEXT, variance_pct::TEXT FROM analytics.vw_alert_revenue_anomaly
UNION ALL SELECT alert_type, severity, alert_message, recommended_action, 'Order #' || order_id, days_since_order::TEXT FROM analytics.vw_alert_delayed_shipments
UNION ALL SELECT alert_type, severity, alert_message, recommended_action, category, return_rate_pct::TEXT FROM analytics.vw_alert_high_return_rate
UNION ALL SELECT alert_type, severity, alert_message, recommended_action, product_name, total_stock::TEXT FROM analytics.vw_alert_low_stock
UNION ALL SELECT alert_type, severity, alert_message, recommended_action, endpoint, avg_response_ms::TEXT FROM analytics.vw_alert_api_degradation
UNION ALL SELECT alert_type, severity, alert_message, recommended_action, service_name, error_rate_pct::TEXT FROM analytics.vw_alert_error_spike
UNION ALL SELECT alert_type, severity, alert_message, recommended_action, COALESCE(employee_name, 'Unknown'), change_count::TEXT FROM analytics.vw_alert_suspicious_changes
UNION ALL SELECT alert_type, severity, alert_message, recommended_action, department, attendance_pct::TEXT FROM analytics.vw_alert_low_attendance
UNION ALL SELECT alert_type, severity, alert_message, recommended_action, line_name, reject_rate_pct::TEXT FROM analytics.vw_alert_production_quality;

COMMENT ON VIEW analytics.vw_all_active_alerts IS 'Consolidated view of all active business alerts — 11 alert types';

\echo '      ✓ Consolidated alert view created: vw_all_active_alerts'


-- ============================================================================
-- JSON EXPORT
-- ============================================================================

\echo ''
\echo 'Creating alert JSON export function...'

CREATE OR REPLACE FUNCTION analytics.get_all_alerts_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'summary', (
        SELECT json_agg(json_build_object('severity', severity, 'count', cnt))
        FROM (SELECT severity, COUNT(*) as cnt FROM analytics.vw_all_active_alerts GROUP BY severity) s
    ),
    'bySeverity', json_build_object(
        'critical', (SELECT COUNT(*) FROM analytics.vw_all_active_alerts WHERE severity = 'CRITICAL'),
        'high', (SELECT COUNT(*) FROM analytics.vw_all_active_alerts WHERE severity = 'HIGH'),
        'medium', (SELECT COUNT(*) FROM analytics.vw_all_active_alerts WHERE severity = 'MEDIUM')
    ),
    'alerts', (
        SELECT json_agg(json_build_object(
            'type', alert_type, 'severity', severity, 'message', alert_message,
            'action', recommended_action, 'entity', entity_name, 'metric', metric
        ) ORDER BY 
            CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 ELSE 3 END,
            alert_type
        )
        FROM analytics.vw_all_active_alerts
        LIMIT 100
    )
); END;
$$ LANGUAGE plpgsql STABLE;

\echo '      ✓ JSON function created: get_all_alerts_json()'


-- ============================================================================
-- VERIFICATION
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '         BUSINESS ALERTS MODULE (V2) — COMPLETE                             '
\echo '============================================================================'
\echo ''
\echo '✅ Existing Alerts (updated):'
\echo '   • vw_alert_critical_stock      — Products below critical threshold'
\echo '   • vw_alert_high_value_churn    — Platinum/Gold customers going inactive'
\echo '   • vw_alert_revenue_anomaly     — Daily revenue drops vs 7-day avg'
\echo '   • vw_alert_delayed_shipments   — Orders stuck without delivery'
\echo '   • vw_alert_high_return_rate    — Categories with excessive returns'
\echo '   • vw_alert_low_stock           — Products approaching reorder point'
\echo ''
\echo '✅ New Alerts (V2):'
\echo '   • vw_alert_api_degradation     — Slow/failing API endpoints 🆕'
\echo '   • vw_alert_error_spike         — Service error rate spikes 🆕'
\echo '   • vw_alert_suspicious_changes  — Unauthorized record modifications 🆕'
\echo '   • vw_alert_low_attendance      — Below-threshold department attendance 🆕'
\echo '   • vw_alert_production_quality  — High production reject rates 🆕'
\echo ''
\echo '✅ Consolidated: vw_all_active_alerts (11 alert types combined)'
\echo '✅ JSON: get_all_alerts_json()'
\echo ''
\echo '➡️  Next: Run 05_refresh/refresh_all_analytics.sql'
\echo '============================================================================'
\echo ''

SELECT severity, COUNT(*) as alert_count
FROM analytics.vw_all_active_alerts
GROUP BY severity
ORDER BY CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 ELSE 3 END;