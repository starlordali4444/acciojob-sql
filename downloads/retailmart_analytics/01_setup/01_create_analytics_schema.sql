-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 01_setup/01_create_analytics_schema.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Create dedicated analytics schema and configuration
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3 — 16 Schemas, 55 Tables)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- DESCRIPTION:
--   This is the foundation of our analytics platform. We create a separate
--   schema to isolate analytics objects from transactional tables.
--   
--   Think of it like Flipkart having separate databases:
--   - Production DB: Where live orders happen (sales, customers, etc.)
--   - Analytics DB: Where reports and dashboards pull from (analytics schema)
--
-- WHAT'S NEW IN V2:
--   - Config keys for Finance, HR, Audit, Supply Chain, Call Center modules
--   - Thresholds for API performance, error rates, production quality
--   - Support for 10-tab dashboard (vs 7 in V1)
--
-- EXECUTION ORDER: Run this FIRST before any other scripts
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '     RETAILMART V2 ENTERPRISE ANALYTICS — SCHEMA SETUP                     '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- STEP 1: CREATE ANALYTICS SCHEMA
-- ============================================================================
-- Why separate schema?
-- 1. Security: Analysts get READ on analytics, not on production tables
-- 2. Performance: Materialized views don't slow down transactions
-- 3. Organization: Easy to find all analytics objects
-- 4. Maintenance: Can refresh analytics without touching production
-- ============================================================================

\echo '[1/4] Creating analytics schema...'

DROP SCHEMA IF EXISTS analytics CASCADE;
CREATE SCHEMA analytics;

COMMENT ON SCHEMA analytics IS 'RetailMart V3 Enterprise Analytics Platform — 10-Tab Dashboard, 50+ Views, 13 MVs, 42 JSON Exports';

\echo '      ✓ Schema created: analytics'


-- ============================================================================
-- STEP 2: CREATE CONFIGURATION TABLE
-- ============================================================================
-- Enterprise systems need configuration management.
-- Instead of hardcoding dates like '2025-10-31', we use a config table.
--
-- Real-world example: At Amazon, they have config tables that control:
-- - Fiscal year start month (April in India)
-- - Report reference dates
-- - Threshold values for alerts
-- ============================================================================

\echo '[2/4] Creating configuration table...'

CREATE TABLE analytics.config (
    config_key      VARCHAR(50) PRIMARY KEY,
    config_value    VARCHAR(255) NOT NULL,
    data_type       VARCHAR(20) DEFAULT 'STRING',  -- STRING, DATE, NUMBER, BOOLEAN
    description     TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by      VARCHAR(50) DEFAULT CURRENT_USER
);

-- Insert default configuration values
INSERT INTO analytics.config (config_key, config_value, data_type, description) VALUES
    -- ── Date Configuration ──
    ('fiscal_year_start_month', '04', 'NUMBER', 'Fiscal year starts in April (Indian standard)'),
    ('data_retention_days', '730', 'NUMBER', 'Keep 2 years of historical data'),
    
    -- ── Stock Alert Thresholds ──
    ('alert_stock_critical', '10', 'NUMBER', 'Stock below this triggers critical alert'),
    ('alert_stock_low', '50', 'NUMBER', 'Stock below this triggers low stock alert'),
    
    -- ── Customer Churn Thresholds ──
    ('alert_churn_days_platinum', '60', 'NUMBER', 'Days inactive for Platinum churn risk'),
    ('alert_churn_days_gold', '90', 'NUMBER', 'Days inactive for Gold churn risk'),
    
    -- ── Revenue & Sales Thresholds ──
    ('alert_revenue_drop_pct', '25', 'NUMBER', 'Revenue drop % to trigger anomaly alert'),
    ('alert_delivery_sla_days', '3', 'NUMBER', 'Days after which shipment is considered delayed'),
    ('alert_return_rate_threshold', '15', 'NUMBER', 'Return rate % above this triggers alert'),
    ('alert_payment_failure_threshold', '5', 'NUMBER', 'Payment failure % above this triggers alert'),
    
    -- ── CLV Tier Thresholds ──
    ('clv_tier_platinum', '15000', 'NUMBER', 'Minimum spend for Platinum tier'),
    ('clv_tier_gold', '8000', 'NUMBER', 'Minimum spend for Gold tier'),
    ('clv_tier_silver', '3000', 'NUMBER', 'Minimum spend for Silver tier'),
    ('clv_tier_bronze', '1000', 'NUMBER', 'Minimum spend for Bronze tier'),
    
    -- ── RFM Configuration ──
    ('rfm_recency_active_days', '30', 'NUMBER', 'Days for Active customer status'),
    ('rfm_recency_at_risk_days', '90', 'NUMBER', 'Days for At Risk customer status'),
    ('rfm_recency_churning_days', '180', 'NUMBER', 'Days for Churning customer status'),
    
    -- ── Dashboard Configuration ──
    ('dashboard_refresh_interval', '3600', 'NUMBER', 'Dashboard auto-refresh in seconds'),
    ('dashboard_top_n_products', '20', 'NUMBER', 'Number of top products to show'),
    ('dashboard_top_n_customers', '50', 'NUMBER', 'Number of top customers to show'),
    ('dashboard_trend_days', '30', 'NUMBER', 'Days for recent trend analysis'),

    -- ══════════════════════════════════════════════════════════════════════════
    -- NEW V2 CONFIG KEYS
    -- ══════════════════════════════════════════════════════════════════════════

    -- ── Finance & HR Thresholds (Tab 8) ──
    ('alert_expense_overbudget_pct', '20', 'NUMBER', 'Expense over budget % to trigger alert'),
    ('alert_low_attendance_pct', '75', 'NUMBER', 'Attendance % below this triggers alert'),
    ('hr_min_working_hours', '8', 'NUMBER', 'Minimum expected working hours per day'),
    
    -- ── Audit & Compliance Thresholds (Tab 9) ──
    ('alert_api_response_time_ms', '2000', 'NUMBER', 'API response time above this is degraded (ms)'),
    ('alert_error_rate_pct', '5', 'NUMBER', 'Service error rate % above this triggers alert'),
    ('alert_suspicious_change_freq', '10', 'NUMBER', 'Record changes per hour above this is suspicious'),
    ('audit_api_failure_threshold', '400', 'NUMBER', 'HTTP status code >= this is a failure'),
    
    -- ── Supply Chain & Manufacturing Thresholds (Tab 10) ──
    ('alert_supplier_sla_days', '5', 'NUMBER', 'Supplier delivery SLA in days'),
    ('alert_production_reject_pct', '5', 'NUMBER', 'Production reject rate % above this triggers alert'),
    ('alert_warehouse_capacity_pct', '90', 'NUMBER', 'Warehouse capacity usage % above this triggers alert'),
    
    -- ── Support & Call Center Thresholds (merged into Operations) ──
    ('alert_ticket_resolution_days', '3', 'NUMBER', 'Support ticket SLA resolution in days'),
    ('alert_low_sentiment_score', '0.3', 'NUMBER', 'Call sentiment score below this is flagged'),
    ('support_priority_sla_high', '24', 'NUMBER', 'High priority ticket SLA in hours'),
    ('support_priority_sla_medium', '48', 'NUMBER', 'Medium priority ticket SLA in hours'),
    
    -- ── Loyalty Configuration (merged into Customers) ──
    ('loyalty_points_to_rupee', '4', 'NUMBER', 'Points needed to equal 1 rupee in value');

COMMENT ON TABLE analytics.config IS 'Central configuration for all analytics thresholds and settings — V2 with 36 parameters';

\echo '      ✓ Configuration table created with 36 parameters'


-- ============================================================================
-- STEP 3: CREATE HELPER FUNCTIONS TO GET CONFIG VALUES
-- ============================================================================
-- These functions make it easy to get config values in queries:
-- SELECT analytics.get_config('alert_stock_critical')::INT
-- SELECT analytics.get_config_number('clv_tier_platinum')
-- SELECT analytics.get_reference_date()
-- ============================================================================

\echo '[3/4] Creating configuration helper functions...'

-- Function to get string config value
CREATE OR REPLACE FUNCTION analytics.get_config(p_key VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    v_value VARCHAR;
BEGIN
    SELECT config_value INTO v_value
    FROM analytics.config
    WHERE config_key = p_key;
    
    IF v_value IS NULL THEN
        RAISE WARNING 'Config key not found: %', p_key;
    END IF;
    
    RETURN v_value;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to get numeric config value
CREATE OR REPLACE FUNCTION analytics.get_config_number(p_key VARCHAR)
RETURNS NUMERIC AS $$
BEGIN
    RETURN analytics.get_config(p_key)::NUMERIC;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to get reference date (max date from orders)
CREATE OR REPLACE FUNCTION analytics.get_reference_date()
RETURNS DATE AS $$
BEGIN
    RETURN (SELECT MAX(order_date) FROM sales.orders);
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION analytics.get_config IS 'Get configuration value by key';
COMMENT ON FUNCTION analytics.get_config_number IS 'Get numeric configuration value by key';
COMMENT ON FUNCTION analytics.get_reference_date IS 'Get reference date (max order date) for analytics';

\echo '      ✓ Helper functions created'


-- ============================================================================
-- STEP 4: GRANT PERMISSIONS
-- ============================================================================
-- In production, you'd have specific roles:
-- - analyst_read: Can SELECT from analytics schema
-- - analyst_write: Can also refresh materialized views
-- - admin: Full control
--
-- For this project, we grant PUBLIC access for simplicity
-- ============================================================================

\echo '[4/4] Setting up permissions...'

GRANT USAGE ON SCHEMA analytics TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO PUBLIC;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA analytics TO PUBLIC;

-- Make future tables also accessible
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics 
GRANT SELECT ON TABLES TO PUBLIC;

\echo '      ✓ Permissions configured'


-- ============================================================================
-- VERIFICATION
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                    SCHEMA SETUP COMPLETE                                   '
\echo '============================================================================'
\echo ''
\echo '✅ Created:'
\echo '   • Schema: analytics'
\echo '   • Table: analytics.config (36 configuration parameters)'
\echo '   • Function: analytics.get_config(key)'
\echo '   • Function: analytics.get_config_number(key)'
\echo '   • Function: analytics.get_reference_date()'
\echo ''
\echo '📊 Quick Test:'
\echo '   SELECT analytics.get_reference_date();'
\echo '   SELECT analytics.get_config_number(''clv_tier_platinum'');'
\echo '   SELECT analytics.get_config(''alert_api_response_time_ms'');'
\echo ''
\echo '➡️  Next: Run 02_create_metadata_tables.sql'
\echo '============================================================================'
\echo ''

-- Quick verification query
SELECT 
    'Reference Date' as metric,
    analytics.get_reference_date()::TEXT as value
UNION ALL
SELECT 
    'Platinum CLV Threshold',
    analytics.get_config('clv_tier_platinum')
UNION ALL
SELECT 
    'Critical Stock Alert',
    analytics.get_config('alert_stock_critical')
UNION ALL
SELECT 
    'API Response Threshold (V2)',
    analytics.get_config('alert_api_response_time_ms')
UNION ALL
SELECT 
    'Total Config Keys',
    (SELECT COUNT(*)::TEXT FROM analytics.config);