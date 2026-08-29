-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 01_setup/02_create_metadata_tables.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Create metadata tables for tracking KPIs and audit logging
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3 — 16 Schemas, 55 Tables)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- DESCRIPTION:
--   Enterprise analytics requires tracking:
--   1. What KPIs exist and when they were last refreshed
--   2. Audit trail of all operations (who ran what, when, how long)
--   3. Execution history for performance monitoring
--
--   Real-world example: At Flipkart, every dashboard refresh is logged.
--   If a report shows wrong numbers, they can trace back exactly when
--   data was refreshed and by whom.
--
-- WHAT'S NEW IN V2:
--   - KPI entries for 3 new modules: Finance & HR, Audit, Supply Chain
--   - KPI entries for merged modules: Loyalty, Support, Web Events, Manufacturing
--   - Total KPIs: 55+ (up from 25 in V1)
--
-- EXECUTION ORDER: Run AFTER 01_create_analytics_schema.sql
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '     RETAILMART V2 ENTERPRISE ANALYTICS — METADATA TABLES                  '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- TABLE 1: KPI METADATA
-- ============================================================================
-- This table is like a "data catalog" — it documents all KPIs in the system.
-- 
-- Real-world example: Swiggy has a data catalog (like Apache Atlas or AWS Glue)
-- that tracks every metric, who owns it, how it's calculated, and when it refreshes.
-- ============================================================================

\echo '[1/5] Creating KPI metadata table...'

DROP TABLE IF EXISTS analytics.kpi_metadata CASCADE;

CREATE TABLE analytics.kpi_metadata (
    kpi_id              SERIAL PRIMARY KEY,
    kpi_name            VARCHAR(100) UNIQUE NOT NULL,
    kpi_category        VARCHAR(50) NOT NULL,           -- Sales, Customer, Product, Store, Operations, Marketing, Finance, Audit, SupplyChain
    kpi_type            VARCHAR(30) NOT NULL,           -- VIEW, MATERIALIZED_VIEW, FUNCTION, TABLE
    object_name         VARCHAR(100) NOT NULL,          -- Actual DB object name
    description         TEXT,
    business_question   TEXT,                           -- What question does this KPI answer?
    formula             TEXT,                           -- How is it calculated?
    source_tables       TEXT,                           -- Which tables feed this KPI?
    refresh_frequency   VARCHAR(30) DEFAULT 'DAILY',    -- HOURLY, DAILY, WEEKLY, REALTIME
    owner               VARCHAR(100) DEFAULT CURRENT_USER,
    last_refreshed      TIMESTAMP,
    last_row_count      BIGINT,
    avg_refresh_time_ms INTEGER,
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_kpi_category ON analytics.kpi_metadata(kpi_category);
CREATE INDEX idx_kpi_type ON analytics.kpi_metadata(kpi_type);
CREATE INDEX idx_kpi_active ON analytics.kpi_metadata(is_active);

COMMENT ON TABLE analytics.kpi_metadata IS 'Data catalog for all KPIs — tracks definitions, ownership, and refresh status';

\echo '      ✓ Table created: kpi_metadata'


-- ============================================================================
-- TABLE 2: EXECUTION LOG
-- ============================================================================

\echo '[2/5] Creating execution log table...'

DROP TABLE IF EXISTS analytics.execution_log CASCADE;

CREATE TABLE analytics.execution_log (
    log_id              SERIAL PRIMARY KEY,
    operation_type      VARCHAR(50) NOT NULL,           -- REFRESH, EXPORT, VALIDATE, ALERT_CHECK
    module_name         VARCHAR(50),                    -- Sales, Customer, Product, Store, etc.
    object_name         VARCHAR(100),                   -- Specific view/function name
    status              VARCHAR(20) NOT NULL,           -- SUCCESS, FAILED, PARTIAL, RUNNING
    rows_affected       BIGINT,
    execution_time_ms   INTEGER,
    started_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at        TIMESTAMP,
    executed_by         VARCHAR(50) DEFAULT CURRENT_USER,
    error_message       TEXT,
    error_detail        TEXT,
    server_info         JSONB                           -- Additional context
);

CREATE INDEX idx_exec_log_operation ON analytics.execution_log(operation_type);
CREATE INDEX idx_exec_log_status ON analytics.execution_log(status);
CREATE INDEX idx_exec_log_started ON analytics.execution_log(started_at DESC);
CREATE INDEX idx_exec_log_module ON analytics.execution_log(module_name);

COMMENT ON TABLE analytics.execution_log IS 'Audit trail of all analytics operations for troubleshooting and monitoring';

\echo '      ✓ Table created: execution_log'


-- ============================================================================
-- TABLE 3: REFRESH HISTORY
-- ============================================================================

\echo '[3/5] Creating refresh history table...'

DROP TABLE IF EXISTS analytics.refresh_history CASCADE;

CREATE TABLE analytics.refresh_history (
    refresh_id          SERIAL PRIMARY KEY,
    refresh_batch_id    UUID DEFAULT gen_random_uuid(),
    view_name           VARCHAR(100) NOT NULL,
    refresh_type        VARCHAR(20) DEFAULT 'FULL',     -- FULL, INCREMENTAL, CONCURRENT
    started_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at        TIMESTAMP,
    duration_ms         INTEGER,
    rows_before         BIGINT,
    rows_after          BIGINT,
    status              VARCHAR(20) DEFAULT 'RUNNING',
    triggered_by        VARCHAR(50) DEFAULT CURRENT_USER,
    trigger_source      VARCHAR(50) DEFAULT 'MANUAL'    -- MANUAL, SCHEDULED, API
);

CREATE INDEX idx_refresh_view ON analytics.refresh_history(view_name);
CREATE INDEX idx_refresh_status ON analytics.refresh_history(status);
CREATE INDEX idx_refresh_started ON analytics.refresh_history(started_at DESC);

COMMENT ON TABLE analytics.refresh_history IS 'History of materialized view refreshes for data freshness tracking';

\echo '      ✓ Table created: refresh_history'


-- ============================================================================
-- TABLE 4: DATA QUALITY ISSUES
-- ============================================================================

\echo '[4/5] Creating data quality issues table...'

DROP TABLE IF EXISTS analytics.data_quality_issues CASCADE;

CREATE TABLE analytics.data_quality_issues (
    issue_id            SERIAL PRIMARY KEY,
    check_name          VARCHAR(100) NOT NULL,
    check_category      VARCHAR(50) NOT NULL,           -- COMPLETENESS, ACCURACY, CONSISTENCY, TIMELINESS
    severity            VARCHAR(20) NOT NULL,           -- CRITICAL, HIGH, MEDIUM, LOW
    source_table        VARCHAR(100),
    affected_records    BIGINT,
    sample_ids          TEXT,
    issue_description   TEXT,
    suggested_action    TEXT,
    detected_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at         TIMESTAMP,
    resolved_by         VARCHAR(50),
    status              VARCHAR(20) DEFAULT 'OPEN'      -- OPEN, IN_PROGRESS, RESOLVED, IGNORED
);

CREATE INDEX idx_dq_status ON analytics.data_quality_issues(status);
CREATE INDEX idx_dq_severity ON analytics.data_quality_issues(severity);
CREATE INDEX idx_dq_detected ON analytics.data_quality_issues(detected_at DESC);

COMMENT ON TABLE analytics.data_quality_issues IS 'Tracks data quality issues detected by validation checks';

\echo '      ✓ Table created: data_quality_issues'


-- ============================================================================
-- HELPER FUNCTIONS FOR LOGGING
-- ============================================================================

\echo '[5/5] Creating logging helper functions...'

-- Function to log operation start
CREATE OR REPLACE FUNCTION analytics.log_operation_start(
    p_operation_type VARCHAR,
    p_module_name VARCHAR,
    p_object_name VARCHAR DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    v_log_id INTEGER;
BEGIN
    INSERT INTO analytics.execution_log (
        operation_type, module_name, object_name, status, started_at
    ) VALUES (
        p_operation_type, p_module_name, p_object_name, 'RUNNING', CURRENT_TIMESTAMP
    ) RETURNING log_id INTO v_log_id;
    
    RETURN v_log_id;
END;
$$ LANGUAGE plpgsql;

-- Function to log operation completion
CREATE OR REPLACE FUNCTION analytics.log_operation_complete(
    p_log_id INTEGER,
    p_status VARCHAR,
    p_rows_affected BIGINT DEFAULT NULL,
    p_error_message TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_started_at TIMESTAMP;
    v_duration_ms INTEGER;
BEGIN
    SELECT started_at INTO v_started_at
    FROM analytics.execution_log
    WHERE log_id = p_log_id;
    
    v_duration_ms := EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_started_at)) * 1000;
    
    UPDATE analytics.execution_log
    SET 
        status = p_status,
        rows_affected = p_rows_affected,
        execution_time_ms = v_duration_ms,
        completed_at = CURRENT_TIMESTAMP,
        error_message = p_error_message
    WHERE log_id = p_log_id;
END;
$$ LANGUAGE plpgsql;

-- Function to log refresh start
CREATE OR REPLACE FUNCTION analytics.log_refresh_start(
    p_view_name VARCHAR,
    p_refresh_type VARCHAR DEFAULT 'FULL',
    p_trigger_source VARCHAR DEFAULT 'MANUAL'
)
RETURNS INTEGER AS $$
DECLARE
    v_refresh_id INTEGER;
    v_row_count BIGINT;
BEGIN
    BEGIN
        EXECUTE format('SELECT COUNT(*) FROM analytics.%I', p_view_name) INTO v_row_count;
    EXCEPTION WHEN OTHERS THEN
        v_row_count := NULL;
    END;
    
    INSERT INTO analytics.refresh_history (
        view_name, refresh_type, trigger_source, rows_before, status
    ) VALUES (
        p_view_name, p_refresh_type, p_trigger_source, v_row_count, 'RUNNING'
    ) RETURNING refresh_id INTO v_refresh_id;
    
    RETURN v_refresh_id;
END;
$$ LANGUAGE plpgsql;

-- Function to log refresh completion
CREATE OR REPLACE FUNCTION analytics.log_refresh_complete(
    p_refresh_id INTEGER,
    p_status VARCHAR
)
RETURNS VOID AS $$
DECLARE
    v_view_name VARCHAR;
    v_started_at TIMESTAMP;
    v_duration_ms INTEGER;
    v_row_count BIGINT;
BEGIN
    SELECT view_name, started_at INTO v_view_name, v_started_at
    FROM analytics.refresh_history
    WHERE refresh_id = p_refresh_id;
    
    v_duration_ms := EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_started_at)) * 1000;
    
    BEGIN
        EXECUTE format('SELECT COUNT(*) FROM analytics.%I', v_view_name) INTO v_row_count;
    EXCEPTION WHEN OTHERS THEN
        v_row_count := NULL;
    END;
    
    UPDATE analytics.refresh_history
    SET 
        status = p_status,
        completed_at = CURRENT_TIMESTAMP,
        duration_ms = v_duration_ms,
        rows_after = v_row_count
    WHERE refresh_id = p_refresh_id;
    
    UPDATE analytics.kpi_metadata
    SET 
        last_refreshed = CURRENT_TIMESTAMP,
        last_row_count = v_row_count,
        updated_at = CURRENT_TIMESTAMP
    WHERE object_name = v_view_name;
END;
$$ LANGUAGE plpgsql;

-- Function to log data quality issue
CREATE OR REPLACE FUNCTION analytics.log_dq_issue(
    p_check_name VARCHAR,
    p_check_category VARCHAR,
    p_severity VARCHAR,
    p_source_table VARCHAR,
    p_affected_records BIGINT,
    p_description TEXT,
    p_suggested_action TEXT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    v_issue_id INTEGER;
BEGIN
    INSERT INTO analytics.data_quality_issues (
        check_name, check_category, severity, source_table,
        affected_records, issue_description, suggested_action
    ) VALUES (
        p_check_name, p_check_category, p_severity, p_source_table,
        p_affected_records, p_description, p_suggested_action
    ) RETURNING issue_id INTO v_issue_id;
    
    RETURN v_issue_id;
END;
$$ LANGUAGE plpgsql;

\echo '      ✓ Logging functions created'


-- ============================================================================
-- INSERT KPI METADATA — COMPLETE CATALOG
-- ============================================================================
-- Pre-populate with ALL KPIs across all 10 dashboard tabs
-- This serves as documentation and enables tracking
-- ============================================================================

\echo ''
\echo 'Populating KPI metadata catalog...'

INSERT INTO analytics.kpi_metadata (kpi_name, kpi_category, kpi_type, object_name, description, business_question, source_tables, refresh_frequency) VALUES

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB 1: EXECUTIVE (feeds from all modules)
-- ══════════════════════════════════════════════════════════════════════════════
('Executive Summary', 'Sales', 'MATERIALIZED_VIEW', 'mv_executive_summary', 
    'Top-level KPIs for executive view', 'What are our key numbers right now?', 
    'sales.orders, customers.customers, products.products, stores.stores', 'HOURLY'),

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB 2: SALES (8 Views + 2 MVs)
-- ══════════════════════════════════════════════════════════════════════════════
('Daily Sales Summary', 'Sales', 'VIEW', 'vw_daily_sales_summary', 
    'Daily aggregated sales metrics', 'How much did we sell each day?', 
    'sales.orders, sales.order_items, core.dim_date', 'REALTIME'),
('Recent Sales Trend', 'Sales', 'VIEW', 'vw_recent_sales_trend', 
    'Last 30 days daily trend', 'What is the recent daily trend?', 
    'sales.orders', 'REALTIME'),
('Monthly Sales Dashboard', 'Sales', 'MATERIALIZED_VIEW', 'mv_monthly_sales_dashboard', 
    'Monthly trends with MoM/YoY growth', 'How are monthly sales trending?', 
    'sales.orders, sales.order_items', 'DAILY'),
('Sales by Day of Week', 'Sales', 'VIEW', 'vw_sales_by_dayofweek', 
    'Performance breakdown by weekday', 'Which days perform best?', 
    'sales.orders, core.dim_date', 'REALTIME'),
('Payment Mode Analysis', 'Sales', 'VIEW', 'vw_sales_by_payment_mode', 
    'Revenue by payment method', 'How do customers prefer to pay?', 
    'sales.payments', 'REALTIME'),
('Quarterly Sales', 'Sales', 'VIEW', 'vw_quarterly_sales', 
    'Quarterly performance with QoQ growth', 'How did each quarter perform?', 
    'sales.orders', 'REALTIME'),
('Weekend vs Weekday', 'Sales', 'VIEW', 'vw_weekend_vs_weekday', 
    'Weekend versus weekday comparison', 'Do weekends outperform weekdays?', 
    'sales.orders, core.dim_date', 'REALTIME'),
('Sales Returns Analysis', 'Sales', 'VIEW', 'vw_sales_returns_analysis', 
    'Return impact on net revenue', 'How much are returns costing us?', 
    'sales.orders, sales.returns', 'REALTIME'),

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB 3: CUSTOMERS (4 Views + 3 MVs + Loyalty)
-- ══════════════════════════════════════════════════════════════════════════════
('Customer Lifetime Value', 'Customer', 'MATERIALIZED_VIEW', 'mv_customer_lifetime_value', 
    'CLV with tier classification', 'How valuable is each customer?', 
    'customers.customers, sales.orders, customers.loyalty_points, customers.addresses', 'DAILY'),
('RFM Analysis', 'Customer', 'MATERIALIZED_VIEW', 'mv_rfm_analysis', 
    'RFM segmentation for targeting', 'How should we segment customers?', 
    'customers.customers, sales.orders', 'WEEKLY'),
('Cohort Retention', 'Customer', 'MATERIALIZED_VIEW', 'mv_cohort_retention', 
    'Monthly cohort retention rates', 'Are we retaining customers over time?', 
    'customers.customers, sales.orders', 'WEEKLY'),
('Churn Risk', 'Customer', 'VIEW', 'vw_churn_risk_customers', 
    'Customers at risk of churning', 'Which valuable customers might leave?', 
    'customers.customers, sales.orders', 'REALTIME'),
('Customer Geography', 'Customer', 'VIEW', 'vw_customer_geography', 
    'Geographic distribution of customers', 'Where are our customers located?', 
    'customers.customers, customers.addresses', 'REALTIME'),
('New vs Returning', 'Customer', 'VIEW', 'vw_new_vs_returning', 
    'New customer acquisition vs repeat buyers', 'Are we acquiring enough new customers?', 
    'customers.customers, sales.orders', 'REALTIME'),
('Customer Registration Trends', 'Customer', 'VIEW', 'vw_customer_registration_trends', 
    'Monthly signup trends and growth', 'How fast is our customer base growing?', 
    'customers.customers', 'REALTIME'),
-- Loyalty (merged into Customers)
('Loyalty Tier Distribution', 'Customer', 'VIEW', 'vw_loyalty_tier_distribution', 
    'Members per loyalty tier with avg balance', 'How are members distributed across tiers?', 
    'loyalty.members, loyalty.tiers', 'REALTIME'),
('Loyalty Redemption Patterns', 'Customer', 'VIEW', 'vw_loyalty_redemption_patterns', 
    'Redemption frequency and popular rewards', 'What rewards do members prefer?', 
    'loyalty.redemptions, loyalty.tiers, loyalty.members', 'REALTIME'),
('Loyalty Program ROI', 'Customer', 'VIEW', 'vw_loyalty_program_roi', 
    'Points earned vs redeemed, member retention comparison', 'Is the loyalty program profitable?', 
    'loyalty.members, loyalty.redemptions, customers.loyalty_points, sales.orders', 'REALTIME'),

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB 4: PRODUCTS (3 Views + 2 MVs)
-- ══════════════════════════════════════════════════════════════════════════════
('Top Products', 'Product', 'MATERIALIZED_VIEW', 'mv_top_products', 
    'Products ranked by revenue/units', 'What are our best sellers?', 
    'products.products, sales.order_items, core.dim_brand, core.dim_category', 'DAILY'),
('ABC Analysis', 'Product', 'MATERIALIZED_VIEW', 'mv_abc_analysis', 
    'Pareto classification of products', 'Which products drive 80% of revenue?', 
    'products.products, sales.order_items, core.dim_brand, core.dim_category', 'WEEKLY'),
('Category Performance', 'Product', 'VIEW', 'vw_category_performance', 
    'Category-level metrics', 'Which categories perform best?', 
    'products.products, sales.order_items, core.dim_brand, core.dim_category, customers.reviews', 'REALTIME'),
('Brand Performance', 'Product', 'VIEW', 'vw_brand_performance', 
    'Brand-level metrics', 'Which brands are strongest?', 
    'products.products, sales.order_items, core.dim_brand', 'REALTIME'),
('Inventory Turnover', 'Product', 'VIEW', 'vw_inventory_turnover', 
    'Stock velocity and days of inventory', 'How fast is inventory moving?', 
    'products.products, products.inventory, sales.order_items', 'REALTIME'),

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB 5: STORES (3 Views + 1 MV)
-- ══════════════════════════════════════════════════════════════════════════════
('Store Performance', 'Store', 'MATERIALIZED_VIEW', 'mv_store_performance', 
    'Store-level revenue, expenses, and profit', 'Which stores are most profitable?', 
    'stores.stores, sales.orders, stores.expenses, stores.employees, core.dim_region', 'DAILY'),
('Regional Performance', 'Store', 'VIEW', 'vw_regional_performance', 
    'Regional aggregation of metrics', 'How do regions compare?', 
    'stores.stores, sales.orders, core.dim_region', 'REALTIME'),
('Store Inventory Status', 'Store', 'VIEW', 'vw_store_inventory_status', 
    'Inventory health by store', 'Which stores have stock issues?', 
    'stores.stores, products.inventory, products.products', 'REALTIME'),
('Employee by Store', 'Store', 'VIEW', 'vw_employee_by_store', 
    'Employee distribution and payroll by store', 'How is workforce distributed?', 
    'stores.stores, stores.employees, core.dim_department', 'REALTIME'),

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB 6: OPERATIONS (5 Views + 1 MV + Support & Call Center)
-- ══════════════════════════════════════════════════════════════════════════════
('Delivery Performance', 'Operations', 'VIEW', 'vw_delivery_performance', 
    'Delivery SLA and timing metrics', 'Are we delivering on time?', 
    'sales.shipments', 'REALTIME'),
('Courier Comparison', 'Operations', 'VIEW', 'vw_courier_comparison', 
    'Performance by courier partner', 'Which courier is most reliable?', 
    'sales.shipments', 'REALTIME'),
('Return Analysis', 'Operations', 'VIEW', 'vw_return_analysis', 
    'Return rates and reasons by category', 'Why are customers returning products?', 
    'sales.returns, products.products, core.dim_brand, core.dim_category', 'REALTIME'),
('Payment Success Rate', 'Operations', 'VIEW', 'vw_payment_success_rate', 
    'Payment mode performance', 'Are payments succeeding?', 
    'sales.payments', 'REALTIME'),
('Pending Shipments', 'Operations', 'VIEW', 'vw_pending_shipments', 
    'Orders awaiting shipment', 'What is stuck in the pipeline?', 
    'sales.orders, sales.shipments, customers.customers', 'REALTIME'),
('Operations Summary', 'Operations', 'MATERIALIZED_VIEW', 'mv_operations_summary', 
    'Aggregated operational KPIs', 'What is our operational health?', 
    'sales.shipments, sales.returns, sales.payments', 'DAILY'),
-- Support (merged into Operations)
('Support Ticket Summary', 'Operations', 'VIEW', 'vw_support_ticket_summary', 
    'Tickets by category, priority, status, avg resolution time', 'What are customers complaining about?', 
    'support.tickets', 'REALTIME'),
('Support Agent Performance', 'Operations', 'VIEW', 'vw_support_agent_performance', 
    'Tickets per agent, avg resolution time', 'Which agents are most effective?', 
    'support.tickets, stores.employees', 'REALTIME'),
-- Call Center (merged into Operations)
('Call Center Volume', 'Operations', 'VIEW', 'vw_call_center_volume', 
    'Call volume, avg duration, reason breakdown', 'How busy is the call center?', 
    'call_center.calls', 'REALTIME'),
('Call Center Agent Stats', 'Operations', 'VIEW', 'vw_call_center_agent_stats', 
    'Agent performance: calls handled, avg duration, sentiment', 'How are agents performing?', 
    'call_center.calls, call_center.transcripts, stores.employees', 'REALTIME'),
('Call Sentiment Analysis', 'Operations', 'VIEW', 'vw_call_sentiment_analysis', 
    'Sentiment distribution and low-sentiment patterns', 'Are customers satisfied on calls?', 
    'call_center.transcripts, call_center.calls', 'REALTIME'),

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB 7: MARKETING (4 Views + 1 MV + Web Events)
-- ══════════════════════════════════════════════════════════════════════════════
('Campaign Performance', 'Marketing', 'VIEW', 'vw_campaign_performance', 
    'Campaign ROI and effectiveness', 'Which campaigns work best?', 
    'marketing.campaigns, marketing.ads_spend, sales.orders', 'REALTIME'),
('Channel Performance', 'Marketing', 'VIEW', 'vw_channel_performance', 
    'Ad spend by platform', 'Where should we spend ad budget?', 
    'marketing.ads_spend', 'REALTIME'),
('Promotion Effectiveness', 'Marketing', 'VIEW', 'vw_promotion_effectiveness', 
    'Impact of promotions on sales', 'Are promotions driving sales?', 
    'products.promotions, sales.orders', 'REALTIME'),
('Email Engagement', 'Marketing', 'VIEW', 'vw_email_engagement', 
    'Email open rates and click-through rates', 'How effective is email marketing?', 
    'marketing.email_clicks, marketing.campaigns', 'REALTIME'),
('Marketing ROI', 'Marketing', 'MATERIALIZED_VIEW', 'mv_marketing_roi', 
    'Overall marketing spend vs revenue impact', 'What is our marketing ROI?', 
    'marketing.campaigns, marketing.ads_spend, sales.orders', 'DAILY'),
-- Web Events (merged into Marketing)
('Web Traffic Summary', 'Marketing', 'VIEW', 'vw_web_traffic_summary', 
    'Page views per day, unique sessions, device breakdown', 'How much traffic are we getting?', 
    'web_events.page_views', 'REALTIME'),
('Web Device & OS Breakdown', 'Marketing', 'VIEW', 'vw_web_device_os_breakdown', 
    'Traffic by device type and operating system', 'What devices do visitors use?', 
    'web_events.page_views', 'REALTIME'),
('Web Top Pages', 'Marketing', 'VIEW', 'vw_web_top_pages', 
    'Most visited pages and session depth', 'Which pages are most popular?', 
    'web_events.page_views', 'REALTIME'),
('Web Event Funnel', 'Marketing', 'VIEW', 'vw_web_event_funnel', 
    'Event type distribution and interaction patterns', 'How do users interact with our site?', 
    'web_events.events, web_events.page_views', 'REALTIME'),

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB 8: FINANCE & HR (🆕 NEW)
-- ══════════════════════════════════════════════════════════════════════════════
('Finance Expense Summary', 'Finance', 'VIEW', 'vw_finance_expense_summary', 
    'Expenses by category, monthly trends', 'Where is money being spent?', 
    'finance.expenses, core.dim_expense_category', 'REALTIME'),
('Revenue vs Expense', 'Finance', 'VIEW', 'vw_finance_revenue_vs_expense', 
    'Monthly P&L: revenue minus expenses', 'Are we profitable?', 
    'finance.revenue_summary, finance.expenses', 'REALTIME'),
('Finance Budget Tracking', 'Finance', 'VIEW', 'vw_finance_budget_tracking', 
    'Budget utilization and overspend detection', 'Are we within budget?', 
    'finance.expenses, stores.expenses', 'REALTIME'),
('Monthly P&L', 'Finance', 'MATERIALIZED_VIEW', 'mv_finance_monthly_pnl', 
    'Monthly profit and loss materialized', 'What is the monthly financial picture?', 
    'finance.revenue_summary, finance.expenses', 'DAILY'),
('HR Attendance Summary', 'Finance', 'VIEW', 'vw_hr_attendance_summary', 
    'Attendance % by employee, department, month', 'Who is showing up to work?', 
    'hr.attendance, stores.employees, core.dim_department', 'REALTIME'),
('HR Salary Analysis', 'Finance', 'VIEW', 'vw_hr_salary_analysis', 
    'Salary distribution by dept/role', 'How is compensation distributed?', 
    'hr.salary_history, stores.employees, core.dim_department', 'REALTIME'),
('Payroll Department Cost', 'Finance', 'VIEW', 'vw_payroll_department_cost', 
    'Department-wise payroll cost and tax breakdown', 'What does each department cost?', 
    'payroll.pay_slips, stores.employees, core.dim_department', 'REALTIME'),
('Payroll Tax Summary', 'Finance', 'VIEW', 'vw_payroll_tax_summary', 
    'Tax bracket distribution, avg deductions', 'What is the tax impact on payroll?', 
    'payroll.pay_slips, payroll.tax_brackets', 'REALTIME'),

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB 9: AUDIT & COMPLIANCE (🆕 NEW)
-- ══════════════════════════════════════════════════════════════════════════════
('Audit Error Tracking', 'Audit', 'VIEW', 'vw_audit_error_tracking', 
    'Application errors by service, level, trends', 'How stable are our systems?', 
    'audit.application_logs', 'REALTIME'),
('API Performance', 'Audit', 'VIEW', 'vw_audit_api_performance', 
    'Avg response time, failure rate by endpoint', 'Are APIs performing well?', 
    'audit.api_requests', 'REALTIME'),
('Unauthorized Changes', 'Audit', 'VIEW', 'vw_audit_unauthorized_changes', 
    'Record changes patterns, suspicious activity', 'Who is modifying data?', 
    'audit.record_changes, stores.employees', 'REALTIME'),
('Fraud Detection', 'Audit', 'VIEW', 'vw_audit_fraud_detection', 
    'Suspicious order and change patterns', 'Is there potential fraud?', 
    'audit.record_changes, sales.orders', 'REALTIME'),
('Audit Daily Health', 'Audit', 'MATERIALIZED_VIEW', 'mv_audit_daily_health', 
    'Daily system health: errors, API perf, changes', 'What is the daily system status?', 
    'audit.application_logs, audit.api_requests, audit.record_changes', 'DAILY'),

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB 10: SUPPLY CHAIN & MANUFACTURING (🆕 NEW)
-- ══════════════════════════════════════════════════════════════════════════════
('Warehouse Utilization', 'SupplyChain', 'VIEW', 'vw_warehouse_utilization', 
    'Inventory by warehouse, capacity usage', 'How full are our warehouses?', 
    'supply_chain.warehouses, supply_chain.inventory_snapshots', 'REALTIME'),
('Supplier SLA Performance', 'SupplyChain', 'VIEW', 'vw_supplier_sla_performance', 
    'Supplier delivery time, on-time rate', 'Are suppliers delivering on time?', 
    'supply_chain.shipments, products.suppliers', 'REALTIME'),
('Inbound Shipment Tracking', 'SupplyChain', 'VIEW', 'vw_inbound_shipment_tracking', 
    'Inbound shipment status and delay tracking', 'What is arriving and when?', 
    'supply_chain.shipments', 'REALTIME'),
('Warehouse Inventory Trend', 'SupplyChain', 'VIEW', 'vw_warehouse_inventory_trend', 
    'Inventory snapshots over time', 'How is warehouse stock changing?', 
    'supply_chain.inventory_snapshots, supply_chain.warehouses', 'REALTIME'),
('Supply Chain Summary', 'SupplyChain', 'MATERIALIZED_VIEW', 'mv_supply_chain_summary', 
    'Aggregated supply chain KPIs', 'What is the supply chain health?', 
    'supply_chain.shipments, supply_chain.warehouses, supply_chain.inventory_snapshots', 'DAILY'),
-- Manufacturing (merged into Supply Chain)
('Production Line Efficiency', 'SupplyChain', 'VIEW', 'vw_production_line_efficiency', 
    'Capacity utilization, output rate', 'How efficient are production lines?', 
    'manufacture.production_lines, manufacture.work_orders', 'REALTIME'),
('Production Quality', 'SupplyChain', 'VIEW', 'vw_production_quality', 
    'Reject rates by line/product, quality trends', 'What is our defect rate?', 
    'manufacture.work_orders, products.products', 'REALTIME'),
('Production Schedule', 'SupplyChain', 'VIEW', 'vw_production_schedule', 
    'Work order status, completion rate, backlog', 'Are we meeting production targets?', 
    'manufacture.work_orders', 'REALTIME');

\echo '      ✓ KPI metadata populated'


-- ============================================================================
-- VERIFICATION
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                 METADATA TABLES SETUP COMPLETE                             '
\echo '============================================================================'
\echo ''
\echo '✅ Tables Created:'
\echo '   • analytics.kpi_metadata        — KPI catalog'
\echo '   • analytics.execution_log       — Operation audit trail'
\echo '   • analytics.refresh_history     — MV refresh tracking'
\echo '   • analytics.data_quality_issues — DQ issue tracking'
\echo ''
\echo '✅ Functions Created:'
\echo '   • log_operation_start()     — Start logging an operation'
\echo '   • log_operation_complete()  — Complete logging an operation'
\echo '   • log_refresh_start()       — Start logging a refresh'
\echo '   • log_refresh_complete()    — Complete logging a refresh'
\echo '   • log_dq_issue()           — Log a data quality issue'
\echo ''
\echo '➡️  Next: Run 03_create_indexes.sql'
\echo '============================================================================'
\echo ''

-- Show summary by category
SELECT 
    kpi_category,
    COUNT(*) as total_kpis,
    COUNT(*) FILTER (WHERE kpi_type = 'VIEW') as views,
    COUNT(*) FILTER (WHERE kpi_type = 'MATERIALIZED_VIEW') as mvs
FROM analytics.kpi_metadata
GROUP BY kpi_category
ORDER BY kpi_category;