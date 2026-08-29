-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: run_all.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Master runner -- builds the ENTIRE analytics layer in one command.
--
-- USAGE (from the retailmart_analytics folder):
--   psql -d accio_retailmart_NN -f run_all.sql
--
--   Replace NN with YOUR batch number.
--   Run it from INSIDE this folder, otherwise the \i paths below will not
--   resolve. Check where you are with \! pwd (Mac/Linux) or \! cd (Windows).
--
-- WHAT IT DOES (in order):
--   01_setup        -> analytics schema, config table, metadata tables, indexes
--   02_data_quality -> data quality check views
--   03_kpi_queries  -> all 9 KPI/analytics modules (views + materialized views)
--   04_alerts       -> business alert views
--   05_refresh      -> the refresh procedure/script objects
--
-- STOPS ON THE FIRST ERROR so you can see exactly what failed instead of
-- scrolling back through hundreds of lines.
-- ============================================================================

\set ON_ERROR_STOP on
\timing off

\echo ''
\echo '============================================================'
\echo ' RetailMart V3 Analytics Platform -- FULL BUILD'
\echo '============================================================'
\echo ''

\echo '>>> [1/5] SETUP -- schema, config, metadata, indexes'
\i 01_setup/01_create_analytics_schema.sql
\i 01_setup/02_create_metadata_tables.sql
\i 01_setup/03_create_indexes.sql

\echo ''
\echo '>>> [2/5] DATA QUALITY -- checks'
\i 02_data_quality/data_quality_checks.sql

\echo ''
\echo '>>> [3/5] KPI QUERIES -- 9 analytics modules'
\i 03_kpi_queries/01_sales_analytics.sql
\i 03_kpi_queries/02_customer_analytics.sql
\i 03_kpi_queries/03_product_analytics.sql
\i 03_kpi_queries/04_store_analytics.sql
\i 03_kpi_queries/05_operations_analytics.sql
\i 03_kpi_queries/06_marketing_analytics.sql
\i 03_kpi_queries/07_finance_hr_analytics.sql
\i 03_kpi_queries/08_audit_compliance_analytics.sql
\i 03_kpi_queries/09_supply_chain_analytics.sql

\echo ''
\echo '>>> [4/5] ALERTS -- business alert views'
\i 04_alerts/business_alerts.sql

\echo ''
\echo '>>> [5/5] REFRESH -- refresh objects'
\i 05_refresh/refresh_all_analytics.sql

\echo ''
\echo '============================================================'
\echo ' BUILD COMPLETE'
\echo '============================================================'

-- Verify what was created:
SELECT
  (SELECT COUNT(*) FROM pg_views          WHERE schemaname = 'analytics') AS views,
  (SELECT COUNT(*) FROM pg_matviews       WHERE schemaname = 'analytics') AS materialized_views,
  (SELECT COUNT(*) FROM pg_indexes        WHERE schemaname = 'analytics') AS indexes;

\echo ''
\echo 'NEXT STEP: export the dashboard data'
\echo '  cd 05_refresh && ./export_all_json.sh'
\echo ''
