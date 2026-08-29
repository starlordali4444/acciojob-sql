-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 05_refresh/refresh_all_analytics.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Refresh all materialized views with logging
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- DESCRIPTION:
--   Enterprise systems need scheduled refreshes. At Flipkart, data pipelines
--   run at 2 AM every night to refresh all dashboards before morning stand-ups.
--
--   This script:
--   1. Refreshes all 13 materialized views in correct dependency order
--   2. Logs execution time for each view
--   3. Updates metadata tables
--   4. Returns status report
--
-- V2 CHANGES:
--   - 13 MVs (up from 10): added finance_monthly_pnl, audit_daily_health, supply_chain_summary
--   - Module-level refresh functions for selective refresh
--
-- DEPENDENCY: Must run AFTER all 03_kpi_queries/ and 04_alerts/ scripts
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '         REFRESH ALL ANALYTICS (V2) — STARTING                              '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- MAIN REFRESH FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION analytics.fn_refresh_all_analytics(
    p_concurrent BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    view_name VARCHAR,
    status VARCHAR,
    duration_ms INTEGER,
    rows_after BIGINT
) AS $$
DECLARE
    v_log_id INTEGER;
    v_refresh_id INTEGER;
    v_start TIMESTAMP;
    v_duration INTEGER;
    v_count BIGINT;
    v_views TEXT[] := ARRAY[
        -- Order matters! Independent MVs first, then dependent ones
        -- Sales (no dependencies)
        'mv_monthly_sales_dashboard',
        'mv_executive_summary',
        -- Customers (no cross-MV dependencies)
        'mv_customer_lifetime_value',
        'mv_rfm_analysis',
        'mv_cohort_retention',
        -- Products (no dependencies)
        'mv_top_products',
        'mv_abc_analysis',
        -- Stores (no dependencies)
        'mv_store_performance',
        -- Operations (no dependencies)
        'mv_operations_summary',
        -- Marketing (no dependencies)
        'mv_marketing_roi',
        -- Finance (no dependencies)
        'mv_finance_monthly_pnl',
        -- Audit (no dependencies)
        'mv_audit_daily_health',
        -- Supply Chain (no dependencies)
        'mv_supply_chain_summary'
    ];
    v_view TEXT;
BEGIN
    -- Log overall operation start
    v_log_id := analytics.log_operation_start('REFRESH', 'ALL', 'fn_refresh_all_analytics');
    
    FOREACH v_view IN ARRAY v_views LOOP
        v_start := clock_timestamp();
        v_refresh_id := analytics.log_refresh_start(v_view, 'FULL', 'FUNCTION');
        
        BEGIN
            IF p_concurrent THEN
                EXECUTE format('REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.%I', v_view);
            ELSE
                EXECUTE format('REFRESH MATERIALIZED VIEW analytics.%I', v_view);
            END IF;
            
            -- Get row count
            EXECUTE format('SELECT COUNT(*) FROM analytics.%I', v_view) INTO v_count;
            v_duration := EXTRACT(EPOCH FROM (clock_timestamp() - v_start)) * 1000;
            
            PERFORM analytics.log_refresh_complete(v_refresh_id, 'SUCCESS');
            
            view_name := v_view;
            status := 'SUCCESS';
            duration_ms := v_duration;
            rows_after := v_count;
            RETURN NEXT;
            
        EXCEPTION WHEN OTHERS THEN
            v_duration := EXTRACT(EPOCH FROM (clock_timestamp() - v_start)) * 1000;
            PERFORM analytics.log_refresh_complete(v_refresh_id, 'FAILED');
            
            view_name := v_view;
            status := 'FAILED: ' || SQLERRM;
            duration_ms := v_duration;
            rows_after := NULL;
            RETURN NEXT;
        END;
    END LOOP;
    
    PERFORM analytics.log_operation_complete(v_log_id, 'SUCCESS');
    RETURN;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION analytics.fn_refresh_all_analytics IS 'Refresh all 13 materialized views with logging';


-- ============================================================================
-- MODULE-LEVEL REFRESH FUNCTIONS
-- ============================================================================

-- Sales module refresh
CREATE OR REPLACE FUNCTION analytics.fn_refresh_sales()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_monthly_sales_dashboard;
    REFRESH MATERIALIZED VIEW analytics.mv_executive_summary;
    RAISE NOTICE 'Sales MVs refreshed: mv_monthly_sales_dashboard, mv_executive_summary';
END;
$$ LANGUAGE plpgsql;

-- Customer module refresh
CREATE OR REPLACE FUNCTION analytics.fn_refresh_customers()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_customer_lifetime_value;
    REFRESH MATERIALIZED VIEW analytics.mv_rfm_analysis;
    REFRESH MATERIALIZED VIEW analytics.mv_cohort_retention;
    RAISE NOTICE 'Customer MVs refreshed: mv_customer_lifetime_value, mv_rfm_analysis, mv_cohort_retention';
END;
$$ LANGUAGE plpgsql;

-- Products module refresh
CREATE OR REPLACE FUNCTION analytics.fn_refresh_products()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_top_products;
    REFRESH MATERIALIZED VIEW analytics.mv_abc_analysis;
    RAISE NOTICE 'Product MVs refreshed: mv_top_products, mv_abc_analysis';
END;
$$ LANGUAGE plpgsql;

-- Stores module refresh
CREATE OR REPLACE FUNCTION analytics.fn_refresh_stores()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_store_performance;
    RAISE NOTICE 'Store MVs refreshed: mv_store_performance';
END;
$$ LANGUAGE plpgsql;

-- Operations module refresh
CREATE OR REPLACE FUNCTION analytics.fn_refresh_operations()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_operations_summary;
    RAISE NOTICE 'Operations MVs refreshed: mv_operations_summary';
END;
$$ LANGUAGE plpgsql;

-- Marketing module refresh
CREATE OR REPLACE FUNCTION analytics.fn_refresh_marketing()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_marketing_roi;
    RAISE NOTICE 'Marketing MVs refreshed: mv_marketing_roi';
END;
$$ LANGUAGE plpgsql;

-- Finance module refresh
CREATE OR REPLACE FUNCTION analytics.fn_refresh_finance()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_finance_monthly_pnl;
    RAISE NOTICE 'Finance MVs refreshed: mv_finance_monthly_pnl';
END;
$$ LANGUAGE plpgsql;

-- Audit module refresh
CREATE OR REPLACE FUNCTION analytics.fn_refresh_audit()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_audit_daily_health;
    RAISE NOTICE 'Audit MVs refreshed: mv_audit_daily_health';
END;
$$ LANGUAGE plpgsql;

-- Supply Chain module refresh
CREATE OR REPLACE FUNCTION analytics.fn_refresh_supply_chain()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_supply_chain_summary;
    RAISE NOTICE 'Supply Chain MVs refreshed: mv_supply_chain_summary';
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- REFRESH STATUS CHECK
-- ============================================================================

CREATE OR REPLACE FUNCTION analytics.fn_get_refresh_status()
RETURNS TABLE (
    view_name VARCHAR,
    last_refreshed TIMESTAMP,
    row_count BIGINT,
    age_hours NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        km.object_name::VARCHAR,
        km.last_refreshed,
        km.last_row_count,
        ROUND(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - km.last_refreshed)) / 3600, 1)
    FROM analytics.kpi_metadata km
    WHERE km.kpi_type = 'MATERIALIZED_VIEW'
    AND km.is_active = TRUE
    ORDER BY km.last_refreshed NULLS FIRST;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION analytics.fn_get_refresh_status IS 'Check freshness of all materialized views';


-- ============================================================================
-- VERIFICATION
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '         REFRESH ALL ANALYTICS (V2) — COMPLETE                              '
\echo '============================================================================'
\echo ''
\echo '✅ Main Function:'
\echo '   • fn_refresh_all_analytics(concurrent?)  — Refresh all 13 MVs with logging'
\echo ''
\echo '✅ Module Refresh Functions (9):'
\echo '   • fn_refresh_sales()          — 2 MVs'
\echo '   • fn_refresh_customers()      — 3 MVs'
\echo '   • fn_refresh_products()       — 2 MVs'
\echo '   • fn_refresh_stores()         — 1 MV'
\echo '   • fn_refresh_operations()     — 1 MV'
\echo '   • fn_refresh_marketing()      — 1 MV'
\echo '   • fn_refresh_finance()        — 1 MV   🆕'
\echo '   • fn_refresh_audit()          — 1 MV   🆕'
\echo '   • fn_refresh_supply_chain()   — 1 MV   🆕'
\echo ''
\echo '✅ Status Check:'
\echo '   • fn_get_refresh_status()     — View freshness report'
\echo ''
\echo '📊 Quick Test:'
\echo '   SELECT * FROM analytics.fn_refresh_all_analytics();'
\echo '   SELECT * FROM analytics.fn_get_refresh_status();'
\echo ''
\echo '============================================================================'
\echo ''