-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 03_kpi_queries/08_audit_compliance_analytics.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Audit & Compliance — Error Tracking, API Performance, Change Audit, Fraud
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3) — 🆕 NEW MODULE
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- DESCRIPTION:
--   At any enterprise, the CTO and compliance team ask:
--   - "Are our systems stable?" (Error tracking)
--   - "Are APIs performing?" (Response time, failure rate)
--   - "Who changed what data?" (Audit trail)
--   - "Is there suspicious activity?" (Fraud patterns)
--
-- SOURCE TABLES:
--   audit.application_logs, audit.api_requests, audit.record_changes,
--   stores.employees, sales.orders
--
-- CREATES: 4 Views + 1 MV + 2 JSON Functions
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '     AUDIT & COMPLIANCE ANALYTICS MODULE (V2) — STARTING                    '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- VIEW 1: ERROR TRACKING
-- ============================================================================

\echo '[1/5] Creating view: vw_audit_error_tracking...'

CREATE OR REPLACE VIEW analytics.vw_audit_error_tracking AS
WITH error_summary AS (
    SELECT 
        DATE_TRUNC('day', timestamp)::DATE as log_date,
        service_name,
        level,
        COUNT(*) as log_count
    FROM audit.application_logs
    GROUP BY DATE_TRUNC('day', timestamp), service_name, level
)
SELECT 
    log_date,
    service_name,
    level,
    log_count,
    -- Daily totals per service
    SUM(log_count) OVER (PARTITION BY log_date, service_name) as service_daily_total,
    -- Error rate: errors / total logs for that service on that day
    ROUND((CASE WHEN level IN ('ERROR', 'FATAL') THEN log_count ELSE 0 END::NUMERIC /
           NULLIF(SUM(log_count) OVER (PARTITION BY log_date, service_name), 0) * 100), 2) as error_rate_pct,
    -- 7-day moving average of errors
    CASE WHEN level IN ('ERROR', 'FATAL') THEN
        ROUND(AVG(log_count) OVER (
            PARTITION BY service_name, level
            ORDER BY log_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::NUMERIC, 1)
    ELSE NULL END as error_moving_avg_7d
FROM error_summary
ORDER BY log_date DESC, service_name, level;

COMMENT ON VIEW analytics.vw_audit_error_tracking IS 'Application error tracking by service and severity level';
\echo '      ✓ View created: vw_audit_error_tracking'


-- ============================================================================
-- VIEW 2: API PERFORMANCE
-- ============================================================================

\echo '[2/5] Creating view: vw_audit_api_performance...'

CREATE OR REPLACE VIEW analytics.vw_audit_api_performance AS
WITH api_stats AS (
    SELECT 
        endpoint,
        method,
        COUNT(*) as total_requests,
        COUNT(*) FILTER (WHERE status_code >= 400) as failed_requests,
        COUNT(*) FILTER (WHERE status_code >= 500) as server_errors,
        ROUND(AVG(response_time_ms)::NUMERIC, 0) as avg_response_ms,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY response_time_ms)::NUMERIC, 0) as median_response_ms,
        ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY response_time_ms)::NUMERIC, 0) as p95_response_ms,
        ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY response_time_ms)::NUMERIC, 0) as p99_response_ms,
        MIN(response_time_ms) as min_response_ms,
        MAX(response_time_ms) as max_response_ms
    FROM audit.api_requests
    GROUP BY endpoint, method
)
SELECT 
    endpoint, method,
    total_requests,
    failed_requests,
    server_errors,
    ROUND((failed_requests::NUMERIC / NULLIF(total_requests, 0) * 100), 2) as failure_rate_pct,
    ROUND((server_errors::NUMERIC / NULLIF(total_requests, 0) * 100), 2) as server_error_rate_pct,
    avg_response_ms, median_response_ms, p95_response_ms, p99_response_ms,
    min_response_ms, max_response_ms,
    -- Health status
    CASE 
        WHEN (failed_requests::NUMERIC / NULLIF(total_requests, 0) * 100) > 10 THEN 'Critical'
        WHEN (failed_requests::NUMERIC / NULLIF(total_requests, 0) * 100) > 5 THEN 'Degraded'
        WHEN avg_response_ms > (SELECT analytics.get_config_number('alert_api_response_time_ms')) THEN 'Slow'
        ELSE 'Healthy'
    END as health_status,
    RANK() OVER (ORDER BY total_requests DESC) as traffic_rank,
    RANK() OVER (ORDER BY avg_response_ms DESC) as slowest_rank
FROM api_stats
ORDER BY total_requests DESC;

COMMENT ON VIEW analytics.vw_audit_api_performance IS 'API endpoint performance with percentile latencies';
\echo '      ✓ View created: vw_audit_api_performance'


-- ============================================================================
-- VIEW 3: UNAUTHORIZED / SUSPICIOUS CHANGES
-- ============================================================================

\echo '[3/5] Creating view: vw_audit_unauthorized_changes...'

CREATE OR REPLACE VIEW analytics.vw_audit_unauthorized_changes AS
WITH change_stats AS (
    SELECT 
        rc.changed_by as employee_id,
        e.first_name || ' ' || e.last_name as employee_name,
        e.role,
        rc.table_name,
        rc.action,
        COUNT(*) as change_count,
        COUNT(DISTINCT rc.record_id) as records_affected,
        MIN(rc.changed_at) as first_change,
        MAX(rc.changed_at) as last_change,
        -- Changes per hour (suspicious if too many)
        ROUND(COUNT(*)::NUMERIC / NULLIF(EXTRACT(EPOCH FROM (MAX(rc.changed_at) - MIN(rc.changed_at))) / 3600, 0), 2) as changes_per_hour
    FROM audit.record_changes rc
    LEFT JOIN stores.employees e ON rc.changed_by = e.employee_id
    GROUP BY rc.changed_by, e.first_name, e.last_name, e.role, rc.table_name, rc.action
)
SELECT 
    employee_id, employee_name, role,
    table_name, action,
    change_count, records_affected,
    first_change, last_change,
    changes_per_hour,
    -- Flag suspicious activity
    CASE 
        WHEN changes_per_hour > (SELECT analytics.get_config_number('alert_suspicious_change_freq')) THEN 'Suspicious'
        WHEN action = 'DELETE' AND change_count > 5 THEN 'Review Needed'
        WHEN table_name LIKE '%price%' OR table_name LIKE '%salary%' THEN 'Sensitive'
        ELSE 'Normal'
    END as risk_flag
FROM change_stats
ORDER BY change_count DESC;

COMMENT ON VIEW analytics.vw_audit_unauthorized_changes IS 'Record change audit with suspicious activity flagging';
\echo '      ✓ View created: vw_audit_unauthorized_changes'


-- ============================================================================
-- VIEW 4: FRAUD DETECTION PATTERNS
-- ============================================================================

\echo '[4/5] Creating view: vw_audit_fraud_detection...'

CREATE OR REPLACE VIEW analytics.vw_audit_fraud_detection AS
WITH -- Price changes in record_changes
price_changes AS (
    SELECT 
        rc.changed_by,
        e.first_name || ' ' || e.last_name as employee_name,
        rc.record_id,
        rc.column_name,
        rc.old_value,
        rc.new_value,
        rc.changed_at,
        -- Flag large price changes
        CASE 
            WHEN rc.column_name IN ('price', 'cost_price', 'salary', 'amount') 
                 AND rc.old_value ~ '^\d+\.?\d*$' AND rc.new_value ~ '^\d+\.?\d*$'
                 AND ABS(rc.new_value::NUMERIC - rc.old_value::NUMERIC) / NULLIF(rc.old_value::NUMERIC, 0) > 0.5
            THEN 'Large Value Change (>50%)'
            ELSE NULL
        END as fraud_flag
    FROM audit.record_changes rc
    LEFT JOIN stores.employees e ON rc.changed_by = e.employee_id
    WHERE rc.column_name IN ('price', 'cost_price', 'salary', 'amount', 'net_total', 'discount_amount')
),
-- Off-hours changes (before 6 AM or after 10 PM)
off_hours_changes AS (
    SELECT 
        rc.changed_by,
        e.first_name || ' ' || e.last_name as employee_name,
        rc.table_name,
        rc.action,
        rc.changed_at,
        EXTRACT(HOUR FROM rc.changed_at) as change_hour,
        'Off-Hours Activity' as fraud_flag
    FROM audit.record_changes rc
    LEFT JOIN stores.employees e ON rc.changed_by = e.employee_id
    WHERE EXTRACT(HOUR FROM rc.changed_at) < 6 OR EXTRACT(HOUR FROM rc.changed_at) > 22
)
SELECT 
    'Price/Value Change' as detection_type,
    employee_name,
    record_id::TEXT as detail_id,
    column_name || ': ' || old_value || ' → ' || new_value as detail,
    changed_at as event_time,
    fraud_flag
FROM price_changes
WHERE fraud_flag IS NOT NULL

UNION ALL

SELECT 
    'Off-Hours Change' as detection_type,
    employee_name,
    table_name as detail_id,
    action || ' at hour ' || change_hour::TEXT as detail,
    changed_at as event_time,
    fraud_flag
FROM off_hours_changes

ORDER BY event_time DESC;

COMMENT ON VIEW analytics.vw_audit_fraud_detection IS 'Suspicious patterns: large value changes and off-hours activity';
\echo '      ✓ View created: vw_audit_fraud_detection'


-- ============================================================================
-- MATERIALIZED VIEW: DAILY SYSTEM HEALTH
-- ============================================================================

\echo '[5/5] Creating materialized view: mv_audit_daily_health...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_audit_daily_health CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_audit_daily_health AS
WITH daily_errors AS (
    SELECT 
        DATE_TRUNC('day', timestamp)::DATE as log_date,
        COUNT(*) as total_logs,
        COUNT(*) FILTER (WHERE level IN ('ERROR', 'FATAL')) as error_count,
        COUNT(DISTINCT service_name) as active_services
    FROM audit.application_logs
    GROUP BY DATE_TRUNC('day', timestamp)
),
daily_api AS (
    SELECT 
        DATE_TRUNC('day', timestamp)::DATE as api_date,
        COUNT(*) as total_requests,
        COUNT(*) FILTER (WHERE status_code >= 400) as failed_requests,
        ROUND(AVG(response_time_ms)::NUMERIC, 0) as avg_response_ms,
        ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY response_time_ms)::NUMERIC, 0) as p95_response_ms
    FROM audit.api_requests
    GROUP BY DATE_TRUNC('day', timestamp)
),
daily_changes AS (
    SELECT 
        DATE_TRUNC('day', changed_at)::DATE as change_date,
        COUNT(*) as total_changes,
        COUNT(DISTINCT changed_by) as unique_changers
    FROM audit.record_changes
    GROUP BY DATE_TRUNC('day', changed_at)
)
SELECT 
    COALESCE(e.log_date, a.api_date, c.change_date) as health_date,
    COALESCE(e.total_logs, 0) as total_logs,
    COALESCE(e.error_count, 0) as error_count,
    ROUND((COALESCE(e.error_count, 0)::NUMERIC / NULLIF(COALESCE(e.total_logs, 0), 0) * 100), 2) as error_rate_pct,
    COALESCE(e.active_services, 0) as active_services,
    COALESCE(a.total_requests, 0) as api_requests,
    COALESCE(a.failed_requests, 0) as api_failures,
    ROUND((COALESCE(a.failed_requests, 0)::NUMERIC / NULLIF(COALESCE(a.total_requests, 0), 0) * 100), 2) as api_failure_rate_pct,
    COALESCE(a.avg_response_ms, 0) as avg_api_response_ms,
    COALESCE(a.p95_response_ms, 0) as p95_api_response_ms,
    COALESCE(c.total_changes, 0) as record_changes,
    COALESCE(c.unique_changers, 0) as unique_changers,
    -- Overall health
    CASE 
        WHEN COALESCE(e.error_count, 0)::NUMERIC / NULLIF(COALESCE(e.total_logs, 0), 0) > 0.1 THEN 'Critical'
        WHEN COALESCE(a.failed_requests, 0)::NUMERIC / NULLIF(COALESCE(a.total_requests, 0), 0) > 0.05 THEN 'Degraded'
        WHEN COALESCE(a.avg_response_ms, 0) > 2000 THEN 'Slow'
        ELSE 'Healthy'
    END as system_health
FROM daily_errors e
FULL OUTER JOIN daily_api a ON e.log_date = a.api_date
FULL OUTER JOIN daily_changes c ON COALESCE(e.log_date, a.api_date) = c.change_date
ORDER BY health_date DESC;

CREATE INDEX IF NOT EXISTS idx_audit_health_date ON analytics.mv_audit_daily_health(health_date);

COMMENT ON MATERIALIZED VIEW analytics.mv_audit_daily_health IS 'Daily system health aggregation';
\echo '      ✓ Materialized view created: mv_audit_daily_health'


-- ============================================================================
-- JSON EXPORT FUNCTIONS
-- ============================================================================

\echo ''
\echo 'Creating JSON export functions...'

CREATE OR REPLACE FUNCTION analytics.get_audit_overview_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'dailyHealth', (
        SELECT json_agg(json_build_object(
            'date', health_date, 'errors', error_count, 'errorRate', error_rate_pct,
            'apiRequests', api_requests, 'apiFailRate', api_failure_rate_pct,
            'avgResponseMs', avg_api_response_ms, 'p95ResponseMs', p95_api_response_ms,
            'changes', record_changes, 'health', system_health
        ) ORDER BY health_date DESC)
        FROM analytics.mv_audit_daily_health LIMIT 30
    ),
    'errorsByService', (
        SELECT json_agg(json_build_object(
            'service', service_name, 'errors', error_count, 'errorRate', error_rate_pct
        ) ORDER BY error_count DESC)
        FROM (
            SELECT service_name, SUM(log_count) FILTER (WHERE level IN ('ERROR','FATAL')) as error_count,
                ROUND((SUM(log_count) FILTER (WHERE level IN ('ERROR','FATAL'))::NUMERIC / NULLIF(SUM(log_count), 0) * 100), 2) as error_rate_pct
            FROM analytics.vw_audit_error_tracking GROUP BY service_name
        ) s WHERE error_count > 0
    ),
    'suspiciousActivity', (
        SELECT json_agg(json_build_object(
            'type', detection_type, 'employee', employee_name, 'detail', detail,
            'time', event_time, 'flag', fraud_flag
        ) ORDER BY event_time DESC)
        FROM analytics.vw_audit_fraud_detection LIMIT 20
    )
); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_api_performance_json()
RETURNS JSON AS $$
BEGIN RETURN (
    SELECT json_agg(json_build_object(
        'endpoint', endpoint, 'method', method, 'requests', total_requests,
        'failures', failed_requests, 'failureRate', failure_rate_pct,
        'avgMs', avg_response_ms, 'p95Ms', p95_response_ms, 'p99Ms', p99_response_ms,
        'health', health_status
    ) ORDER BY total_requests DESC)
    FROM analytics.vw_audit_api_performance
); END;
$$ LANGUAGE plpgsql STABLE;

\echo '      ✓ JSON functions created (2 functions)'

REFRESH MATERIALIZED VIEW analytics.mv_audit_daily_health;

\echo ''
\echo '============================================================================'
\echo '     AUDIT & COMPLIANCE ANALYTICS MODULE (V2) — COMPLETE                    '
\echo '============================================================================'
\echo ''
\echo '✅ Views (4): error tracking, API performance, unauthorized changes, fraud detection'
\echo '✅ MVs (1): mv_audit_daily_health'
\echo '✅ JSON (2): audit_overview, api_performance'
\echo ''
\echo '➡️  Next: Run 09_supply_chain_analytics.sql'
\echo '============================================================================'
\echo ''
