-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 03_kpi_queries/05_operations_analytics.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Operations Analytics — Delivery, Returns, Payments + Support + Call Center
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- V2 CHANGES:
--   - total_amount → net_total
--   - full_name → first_name || ' ' || last_name
--   - c.city → from customers.addresses (default)
--   - p.category → via dim_brand → dim_category JOIN chain
--   - p.prod_id → p.product_id
--   - NEW: 5 views for support tickets and call center analytics
--
-- CREATES: 10 Views + 1 MV + 7 JSON Functions
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '       OPERATIONS ANALYTICS MODULE (V2) — STARTING                          '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- VIEW 1: DELIVERY PERFORMANCE (unchanged logic, just cleaner)
-- ============================================================================

\echo '[1/11] Creating view: vw_delivery_performance...'

CREATE OR REPLACE VIEW analytics.vw_delivery_performance AS
WITH delivery_metrics AS (
    SELECT 
        DATE_TRUNC('month', s.shipped_date)::DATE as ship_month,
        COUNT(*) as total_shipments,
        COUNT(*) FILTER (WHERE s.status = 'Delivered') as delivered_count,
        COUNT(*) FILTER (WHERE s.status = 'Shipped') as in_transit_count,
        AVG(s.delivered_date - s.shipped_date) as avg_delivery_days,
        COUNT(*) FILTER (WHERE (s.delivered_date - s.shipped_date) <= 3) as on_time_deliveries,
        COUNT(*) FILTER (WHERE (s.delivered_date - s.shipped_date) > 7) as delayed_deliveries
    FROM sales.shipments s
    WHERE s.shipped_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', s.shipped_date)
)
SELECT 
    ship_month,
    TO_CHAR(ship_month, 'Mon YYYY') as month_name,
    total_shipments, delivered_count, in_transit_count,
    ROUND(avg_delivery_days::NUMERIC, 1) as avg_delivery_days,
    on_time_deliveries, delayed_deliveries,
    ROUND((on_time_deliveries::NUMERIC / NULLIF(delivered_count, 0) * 100), 2) as on_time_pct,
    ROUND((delayed_deliveries::NUMERIC / NULLIF(delivered_count, 0) * 100), 2) as delayed_pct,
    CASE 
        WHEN (on_time_deliveries::NUMERIC / NULLIF(delivered_count, 0) * 100) >= 95 THEN 'Excellent'
        WHEN (on_time_deliveries::NUMERIC / NULLIF(delivered_count, 0) * 100) >= 85 THEN 'Good'
        WHEN (on_time_deliveries::NUMERIC / NULLIF(delivered_count, 0) * 100) >= 70 THEN 'Needs Improvement'
        ELSE 'Critical'
    END as sla_status
FROM delivery_metrics
ORDER BY ship_month DESC;

COMMENT ON VIEW analytics.vw_delivery_performance IS 'Monthly delivery SLA tracking';
\echo '      ✓ View created: vw_delivery_performance'


-- ============================================================================
-- VIEW 2: COURIER COMPARISON
-- ============================================================================

\echo '[2/11] Creating view: vw_courier_comparison...'

CREATE OR REPLACE VIEW analytics.vw_courier_comparison AS
SELECT 
    courier_name,
    COUNT(*) as total_shipments,
    COUNT(*) FILTER (WHERE status = 'Delivered') as delivered,
    COUNT(*) FILTER (WHERE status = 'Shipped') as in_transit,
    ROUND(AVG(delivered_date - shipped_date)::NUMERIC, 1) as avg_delivery_days,
    COUNT(*) FILTER (WHERE (delivered_date - shipped_date) <= 3) as on_time,
    ROUND((COUNT(*) FILTER (WHERE (delivered_date - shipped_date) <= 3)::NUMERIC / 
           NULLIF(COUNT(*) FILTER (WHERE status = 'Delivered'), 0) * 100), 2) as on_time_pct,
    RANK() OVER (ORDER BY AVG(delivered_date - shipped_date) NULLS LAST) as speed_rank,
    RANK() OVER (ORDER BY COUNT(*) FILTER (WHERE (delivered_date - shipped_date) <= 3)::NUMERIC / 
           NULLIF(COUNT(*) FILTER (WHERE status = 'Delivered'), 0) DESC NULLS LAST) as reliability_rank
FROM sales.shipments
WHERE shipped_date IS NOT NULL
GROUP BY courier_name
ORDER BY on_time_pct DESC NULLS LAST;

COMMENT ON VIEW analytics.vw_courier_comparison IS 'Courier partner benchmarking';
\echo '      ✓ View created: vw_courier_comparison'


-- ============================================================================
-- VIEW 3: RETURN ANALYSIS (V2: category via JOIN chain)
-- ============================================================================

\echo '[3/11] Creating view: vw_return_analysis...'

CREATE OR REPLACE VIEW analytics.vw_return_analysis AS
WITH return_stats AS (
    SELECT 
        cat.category_name as category,
        r.reason,
        COUNT(*) as return_count,
        SUM(r.refund_amount) as total_refunds
    FROM sales.returns r
    JOIN products.products p ON r.prod_id = p.product_id
    JOIN core.dim_brand b ON p.brand_id = b.brand_id
    JOIN core.dim_category cat ON b.category_id = cat.category_id
    GROUP BY cat.category_name, r.reason
),
category_orders AS (
    SELECT 
        cat.category_name as category,
        COUNT(DISTINCT oi.order_id) as total_orders,
        SUM(oi.net_amount) as total_revenue
    FROM sales.order_items oi
    JOIN products.products p ON oi.prod_id = p.product_id
    JOIN core.dim_brand b ON p.brand_id = b.brand_id
    JOIN core.dim_category cat ON b.category_id = cat.category_id
    JOIN sales.orders o ON oi.order_id = o.order_id AND o.order_status = 'Delivered'
    GROUP BY cat.category_name
)
SELECT 
    rs.category, rs.reason, rs.return_count,
    ROUND(rs.total_refunds::NUMERIC, 2) as total_refunds,
    co.total_orders,
    ROUND((rs.return_count::NUMERIC / NULLIF(co.total_orders, 0) * 100), 2) as return_rate_pct,
    ROUND((rs.total_refunds / NULLIF(co.total_revenue, 0) * 100), 2) as refund_rate_pct
FROM return_stats rs
JOIN category_orders co ON rs.category = co.category
ORDER BY return_count DESC;

COMMENT ON VIEW analytics.vw_return_analysis IS 'Return rates by category and reason — V2 with JOIN chain';
\echo '      ✓ View created: vw_return_analysis'


-- ============================================================================
-- VIEW 4: PAYMENT SUCCESS RATE (minimal changes)
-- ============================================================================

\echo '[4/11] Creating view: vw_payment_success_rate...'

CREATE OR REPLACE VIEW analytics.vw_payment_success_rate AS
WITH payment_stats AS (
    SELECT 
        payment_mode,
        DATE_TRUNC('month', payment_date)::DATE as payment_month,
        COUNT(*) as total_transactions,
        SUM(amount) as total_amount,
        AVG(amount) as avg_amount
    FROM sales.payments
    GROUP BY payment_mode, DATE_TRUNC('month', payment_date)
)
SELECT 
    payment_month, TO_CHAR(payment_month, 'Mon YYYY') as month_name,
    payment_mode, total_transactions,
    ROUND(total_amount::NUMERIC, 2) as total_amount,
    ROUND(avg_amount::NUMERIC, 2) as avg_amount,
    ROUND((total_amount / SUM(total_amount) OVER (PARTITION BY payment_month) * 100)::NUMERIC, 2) as pct_of_monthly_revenue,
    ROUND(((total_amount - LAG(total_amount) OVER (PARTITION BY payment_mode ORDER BY payment_month)) /
           NULLIF(LAG(total_amount) OVER (PARTITION BY payment_mode ORDER BY payment_month), 0) * 100)::NUMERIC, 2) as mom_growth_pct
FROM payment_stats
ORDER BY payment_month DESC, total_amount DESC;

COMMENT ON VIEW analytics.vw_payment_success_rate IS 'Payment mode trends over time';
\echo '      ✓ View created: vw_payment_success_rate'


-- ============================================================================
-- VIEW 5: PENDING SHIPMENTS (V2: computed full_name, address from addresses)
-- ============================================================================

\echo '[5/11] Creating view: vw_pending_shipments...'

CREATE OR REPLACE VIEW analytics.vw_pending_shipments AS
SELECT 
    o.order_id, o.order_date,
    (SELECT MAX(order_date) FROM sales.orders) - o.order_date as days_since_order,
    c.first_name || ' ' || c.last_name as customer_name,
    COALESCE(ca.city, 'Unknown') as customer_city,
    s.store_name,
    o.net_total as order_amount,
    sh.status as shipment_status,
    sh.courier_name, sh.shipped_date,
    CASE 
        WHEN (SELECT MAX(order_date) FROM sales.orders) - o.order_date > 7 THEN 'Critical'
        WHEN (SELECT MAX(order_date) FROM sales.orders) - o.order_date > 3 THEN 'Urgent'
        ELSE 'Normal'
    END as priority
FROM sales.orders o
LEFT JOIN sales.shipments sh ON o.order_id = sh.order_id
JOIN customers.customers c ON o.cust_id = c.customer_id
LEFT JOIN (
    SELECT DISTINCT ON (customer_id) customer_id, city 
    FROM customers.addresses ORDER BY customer_id, is_default DESC, address_id
) ca ON c.customer_id = ca.customer_id
JOIN stores.stores s ON o.store_id = s.store_id
WHERE o.order_status != 'Delivered'
AND (sh.status IS NULL OR sh.status != 'Delivered')
ORDER BY days_since_order DESC;

COMMENT ON VIEW analytics.vw_pending_shipments IS 'Pending orders with customer and store details';
\echo '      ✓ View created: vw_pending_shipments'


-- ============================================================================
-- 🆕 VIEW 6: SUPPORT TICKET SUMMARY (NEW in V2)
-- ============================================================================

\echo '[6/11] Creating view: vw_support_ticket_summary...'

CREATE OR REPLACE VIEW analytics.vw_support_ticket_summary AS
SELECT 
    category,
    priority,
    status,
    COUNT(*) as ticket_count,
    COUNT(*) FILTER (WHERE resolved_date IS NOT NULL) as resolved_count,
    ROUND(AVG(EXTRACT(EPOCH FROM (resolved_date - created_date)) / 3600)::NUMERIC, 1) as avg_resolution_hours,
    ROUND((COUNT(*) FILTER (WHERE resolved_date IS NOT NULL)::NUMERIC / NULLIF(COUNT(*), 0) * 100), 2) as resolution_rate_pct,
    ROUND((COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100), 2) as pct_of_total
FROM support.tickets
GROUP BY category, priority, status
ORDER BY ticket_count DESC;

COMMENT ON VIEW analytics.vw_support_ticket_summary IS 'Support tickets by category, priority, and status';
\echo '      ✓ View created: vw_support_ticket_summary'


-- ============================================================================
-- 🆕 VIEW 7: SUPPORT AGENT PERFORMANCE (NEW in V2)
-- ============================================================================

\echo '[7/11] Creating view: vw_support_agent_performance...'

CREATE OR REPLACE VIEW analytics.vw_support_agent_performance AS
SELECT 
    e.employee_id as agent_id,
    e.first_name || ' ' || e.last_name as agent_name,
    e.role,
    COUNT(t.ticket_id) as total_tickets,
    COUNT(t.ticket_id) FILTER (WHERE t.status = 'Resolved' OR t.status = 'Closed') as resolved_tickets,
    COUNT(t.ticket_id) FILTER (WHERE t.status = 'Open') as open_tickets,
    ROUND(AVG(EXTRACT(EPOCH FROM (t.resolved_date - t.created_date)) / 3600)::NUMERIC, 1) as avg_resolution_hours,
    ROUND((COUNT(t.ticket_id) FILTER (WHERE t.status IN ('Resolved','Closed'))::NUMERIC / NULLIF(COUNT(t.ticket_id), 0) * 100), 2) as resolution_rate_pct,
    RANK() OVER (ORDER BY COUNT(t.ticket_id) FILTER (WHERE t.status IN ('Resolved','Closed')) DESC) as performance_rank
FROM stores.employees e
JOIN support.tickets t ON e.employee_id = t.agent_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.role
ORDER BY resolved_tickets DESC;

COMMENT ON VIEW analytics.vw_support_agent_performance IS 'Support agent ticket handling metrics';
\echo '      ✓ View created: vw_support_agent_performance'


-- ============================================================================
-- 🆕 VIEW 8: CALL CENTER VOLUME (NEW in V2)
-- ============================================================================

\echo '[8/11] Creating view: vw_call_center_volume...'

CREATE OR REPLACE VIEW analytics.vw_call_center_volume AS
SELECT 
    DATE_TRUNC('month', call_start_time)::DATE as call_month,
    TO_CHAR(DATE_TRUNC('month', call_start_time), 'Mon YYYY') as month_name,
    COUNT(*) as total_calls,
    COUNT(DISTINCT customer_id) as unique_callers,
    ROUND(AVG(call_duration_seconds)::NUMERIC, 0) as avg_duration_seconds,
    ROUND(AVG(call_duration_seconds) / 60.0, 1) as avg_duration_minutes,
    COUNT(*) FILTER (WHERE status = 'Resolved') as resolved_calls,
    ROUND((COUNT(*) FILTER (WHERE status = 'Resolved')::NUMERIC / NULLIF(COUNT(*), 0) * 100), 2) as resolution_rate_pct,
    -- Reason breakdown
    MODE() WITHIN GROUP (ORDER BY call_reason) as most_common_reason
FROM call_center.calls
GROUP BY DATE_TRUNC('month', call_start_time)
ORDER BY call_month DESC;

COMMENT ON VIEW analytics.vw_call_center_volume IS 'Monthly call center volume and metrics';
\echo '      ✓ View created: vw_call_center_volume'


-- ============================================================================
-- 🆕 VIEW 9: CALL CENTER AGENT STATS (NEW in V2)
-- ============================================================================

\echo '[9/11] Creating view: vw_call_center_agent_stats...'

CREATE OR REPLACE VIEW analytics.vw_call_center_agent_stats AS
SELECT 
    e.employee_id as agent_id,
    e.first_name || ' ' || e.last_name as agent_name,
    COUNT(cc.call_id) as total_calls,
    ROUND(AVG(cc.call_duration_seconds)::NUMERIC, 0) as avg_call_duration,
    COUNT(cc.call_id) FILTER (WHERE cc.status = 'Resolved') as resolved_calls,
    ROUND((COUNT(cc.call_id) FILTER (WHERE cc.status = 'Resolved')::NUMERIC / NULLIF(COUNT(cc.call_id), 0) * 100), 2) as resolution_rate_pct,
    ROUND(AVG(ct.sentiment_score)::NUMERIC, 3) as avg_sentiment_score,
    COUNT(ct.transcript_id) FILTER (WHERE ct.sentiment_score < 0.3) as low_sentiment_calls,
    RANK() OVER (ORDER BY COUNT(cc.call_id) DESC) as volume_rank
FROM stores.employees e
JOIN call_center.calls cc ON e.employee_id = cc.agent_id
LEFT JOIN call_center.transcripts ct ON cc.call_id = ct.call_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_calls DESC;

COMMENT ON VIEW analytics.vw_call_center_agent_stats IS 'Call center agent performance with sentiment';
\echo '      ✓ View created: vw_call_center_agent_stats'


-- ============================================================================
-- 🆕 VIEW 10: CALL SENTIMENT ANALYSIS (NEW in V2)
-- ============================================================================

\echo '[10/11] Creating view: vw_call_sentiment_analysis...'

CREATE OR REPLACE VIEW analytics.vw_call_sentiment_analysis AS
WITH sentiment_buckets AS (
    SELECT 
        cc.call_reason,
        ct.sentiment_score,
        CASE 
            WHEN ct.sentiment_score >= 0.7 THEN 'Positive'
            WHEN ct.sentiment_score >= 0.4 THEN 'Neutral'
            ELSE 'Negative'
        END as sentiment_category
    FROM call_center.transcripts ct
    JOIN call_center.calls cc ON ct.call_id = cc.call_id
)
SELECT 
    call_reason,
    COUNT(*) as total_calls,
    ROUND(AVG(sentiment_score)::NUMERIC, 3) as avg_sentiment,
    COUNT(*) FILTER (WHERE sentiment_category = 'Positive') as positive_count,
    COUNT(*) FILTER (WHERE sentiment_category = 'Neutral') as neutral_count,
    COUNT(*) FILTER (WHERE sentiment_category = 'Negative') as negative_count,
    ROUND((COUNT(*) FILTER (WHERE sentiment_category = 'Negative')::NUMERIC / NULLIF(COUNT(*), 0) * 100), 2) as negative_pct,
    RANK() OVER (ORDER BY AVG(sentiment_score)) as sentiment_rank
FROM sentiment_buckets
GROUP BY call_reason
ORDER BY avg_sentiment;

COMMENT ON VIEW analytics.vw_call_sentiment_analysis IS 'Call sentiment by reason — identifies problem areas';
\echo '      ✓ View created: vw_call_sentiment_analysis'


-- ============================================================================
-- MATERIALIZED VIEW: OPERATIONS SUMMARY (V2 updated)
-- ============================================================================

\echo '[11/11] Creating materialized view: mv_operations_summary...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_operations_summary CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_operations_summary AS
WITH delivery_stats AS (
    SELECT 
        COUNT(*) as total_shipments,
        COUNT(*) FILTER (WHERE status = 'Delivered') as delivered,
        ROUND(AVG(delivered_date - shipped_date)::NUMERIC, 1) as avg_delivery_days,
        ROUND((COUNT(*) FILTER (WHERE (delivered_date - shipped_date) <= 3)::NUMERIC / 
               NULLIF(COUNT(*) FILTER (WHERE status = 'Delivered'), 0) * 100), 2) as on_time_pct
    FROM sales.shipments WHERE shipped_date IS NOT NULL
),
return_stats AS (
    SELECT COUNT(*) as total_returns, ROUND(SUM(refund_amount)::NUMERIC, 2) as total_refunds
    FROM sales.returns
),
order_stats AS (
    SELECT 
        COUNT(*) as total_orders,
        COUNT(*) FILTER (WHERE order_status = 'Delivered') as delivered_orders,
        COUNT(*) FILTER (WHERE order_status = 'Pending') as pending_orders
    FROM sales.orders
),
support_stats AS (
    SELECT COUNT(*) as total_tickets,
        COUNT(*) FILTER (WHERE status = 'Open') as open_tickets,
        ROUND(AVG(EXTRACT(EPOCH FROM (resolved_date - created_date)) / 3600)::NUMERIC, 1) as avg_resolution_hours
    FROM support.tickets
),
call_stats AS (
    SELECT COUNT(*) as total_calls,
        ROUND(AVG(call_duration_seconds)::NUMERIC, 0) as avg_call_duration,
        ROUND(AVG(ct.sentiment_score)::NUMERIC, 3) as avg_sentiment
    FROM call_center.calls cc
    LEFT JOIN call_center.transcripts ct ON cc.call_id = ct.call_id
)
SELECT 
    (SELECT MAX(order_date) FROM sales.orders) as reference_date,
    d.total_shipments, d.delivered, d.avg_delivery_days, d.on_time_pct as delivery_sla_pct,
    r.total_returns, r.total_refunds,
    ROUND((r.total_returns::NUMERIC / NULLIF(o.delivered_orders, 0) * 100), 2) as return_rate_pct,
    o.total_orders, o.delivered_orders, o.pending_orders,
    -- V2 additions
    sp.total_tickets, sp.open_tickets, sp.avg_resolution_hours,
    cs.total_calls, cs.avg_call_duration, cs.avg_sentiment
FROM delivery_stats d
CROSS JOIN return_stats r
CROSS JOIN order_stats o
CROSS JOIN support_stats sp
CROSS JOIN call_stats cs;

COMMENT ON MATERIALIZED VIEW analytics.mv_operations_summary IS 'Operations KPIs including support and call center — V2';
\echo '      ✓ Materialized view created: mv_operations_summary'


-- ============================================================================
-- JSON EXPORT FUNCTIONS
-- ============================================================================

\echo ''
\echo 'Creating JSON export functions...'

CREATE OR REPLACE FUNCTION analytics.get_operations_summary_json()
RETURNS JSON AS $$
BEGIN RETURN (SELECT row_to_json(t) FROM analytics.mv_operations_summary t); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_delivery_performance_json()
RETURNS JSON AS $$
BEGIN RETURN (
    SELECT json_agg(json_build_object(
        'month', month_name, 'shipments', total_shipments, 'delivered', delivered_count,
        'avgDeliveryDays', avg_delivery_days, 'onTimePct', on_time_pct, 'slaStatus', sla_status
    ) ORDER BY ship_month DESC)
    FROM analytics.vw_delivery_performance LIMIT 12
); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_courier_comparison_json()
RETURNS JSON AS $$
BEGIN RETURN (
    SELECT json_agg(json_build_object(
        'courier', courier_name, 'shipments', total_shipments, 'avgDays', avg_delivery_days,
        'onTimePct', on_time_pct, 'speedRank', speed_rank, 'reliabilityRank', reliability_rank
    ) ORDER BY on_time_pct DESC NULLS LAST)
    FROM analytics.vw_courier_comparison
); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_return_analysis_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'byCategory', (
        SELECT json_agg(json_build_object('category', category, 'returnCount', rc, 'returnRate', rr) ORDER BY rc DESC)
        FROM (SELECT category, SUM(return_count) as rc, ROUND(AVG(return_rate_pct)::NUMERIC, 2) as rr
              FROM analytics.vw_return_analysis GROUP BY category) s
    ),
    'byReason', (
        SELECT json_agg(json_build_object('reason', reason, 'count', rc) ORDER BY rc DESC)
        FROM (SELECT reason, SUM(return_count) as rc FROM analytics.vw_return_analysis GROUP BY reason) s
    )
); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_pending_shipments_json()
RETURNS JSON AS $$
BEGIN RETURN (
    SELECT json_agg(json_build_object(
        'orderId', order_id, 'orderDate', order_date, 'daysSince', days_since_order,
        'customer', customer_name, 'city', customer_city, 'amount', order_amount,
        'status', shipment_status, 'priority', priority
    ) ORDER BY days_since_order DESC)
    FROM analytics.vw_pending_shipments LIMIT 50
); END;
$$ LANGUAGE plpgsql STABLE;

-- 🆕 JSON 6: Support Overview
CREATE OR REPLACE FUNCTION analytics.get_support_overview_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'byCategory', (
        SELECT json_agg(json_build_object('category', category, 'tickets', tc, 'avgHours', ah) ORDER BY tc DESC)
        FROM (SELECT category, SUM(ticket_count) as tc, ROUND(AVG(avg_resolution_hours)::NUMERIC, 1) as ah
              FROM analytics.vw_support_ticket_summary GROUP BY category) s
    ),
    'agentPerformance', (
        SELECT json_agg(json_build_object('agent', agent_name, 'resolved', resolved_tickets,
            'avgHours', avg_resolution_hours, 'rate', resolution_rate_pct) ORDER BY performance_rank)
        FROM analytics.vw_support_agent_performance LIMIT 10
    )
); END;
$$ LANGUAGE plpgsql STABLE;

-- 🆕 JSON 7: Call Center
CREATE OR REPLACE FUNCTION analytics.get_call_center_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'volume', (
        SELECT json_agg(json_build_object('month', month_name, 'calls', total_calls,
            'avgMinutes', avg_duration_minutes, 'resolutionRate', resolution_rate_pct) ORDER BY call_month DESC)
        FROM analytics.vw_call_center_volume LIMIT 12
    ),
    'sentiment', (
        SELECT json_agg(json_build_object('reason', call_reason, 'avgSentiment', avg_sentiment,
            'negativePct', negative_pct, 'totalCalls', total_calls) ORDER BY avg_sentiment)
        FROM analytics.vw_call_sentiment_analysis
    )
); END;
$$ LANGUAGE plpgsql STABLE;

\echo '      ✓ JSON functions created (7 functions)'

REFRESH MATERIALIZED VIEW analytics.mv_operations_summary;

\echo ''
\echo '============================================================================'
\echo '       OPERATIONS ANALYTICS MODULE (V2) — COMPLETE                          '
\echo '============================================================================'
\echo ''
\echo '✅ Views (10): delivery, courier, returns, payments, pending,'
\echo '   support tickets, support agents, call volume, call agents, sentiment'
\echo '✅ MVs (1): mv_operations_summary (with support + call center stats)'
\echo '✅ JSON (7): 5 existing + support_overview + call_center'
\echo ''
\echo '➡️  Next: Run 06_marketing_analytics.sql'
\echo '============================================================================'
\echo ''