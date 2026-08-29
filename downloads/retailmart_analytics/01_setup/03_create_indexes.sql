-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 01_setup/03_create_indexes.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Create performance indexes on source tables for analytics queries
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3 — 16 Schemas, 55 Tables)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- DESCRIPTION:
--   Analytics queries scan large amounts of data. Without proper indexes,
--   a simple dashboard refresh could take minutes instead of seconds.
--
--   Real-world example: Zomato's analytics queries scan millions of orders.
--   Proper indexes reduce query time from 30 seconds to under 1 second.
--
-- INDEX STRATEGY:
--   1. Date columns — Most analytics filter by date range
--   2. Foreign keys — JOINs use these extensively
--   3. Status columns — Filter by order_status, payment_status
--   4. Composite indexes — For common WHERE + ORDER BY combinations
--
-- WHAT'S NEW IN V2:
--   - Fixed column names (quantity_on_hand, product_name, registration_date, etc.)
--   - Added indexes for: finance, hr, payroll, audit, supply_chain, manufacture,
--     call_center, support, web_events, loyalty schemas
--
-- EXECUTION ORDER: Run AFTER 02_create_metadata_tables.sql
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '     RETAILMART V2 ENTERPRISE ANALYTICS — PERFORMANCE INDEXES              '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- SALES SCHEMA INDEXES
-- ============================================================================

\echo '[1/12] Creating indexes on sales schema...'

-- Orders table — Most queried table in analytics
CREATE INDEX IF NOT EXISTS idx_orders_date 
    ON sales.orders(order_date DESC);
CREATE INDEX IF NOT EXISTS idx_orders_status 
    ON sales.orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_cust 
    ON sales.orders(cust_id);
CREATE INDEX IF NOT EXISTS idx_orders_store 
    ON sales.orders(store_id);
-- Composite indexes for common analytics patterns
CREATE INDEX IF NOT EXISTS idx_orders_date_status 
    ON sales.orders(order_date DESC, order_status);
CREATE INDEX IF NOT EXISTS idx_orders_store_date 
    ON sales.orders(store_id, order_date DESC);

-- Order items
CREATE INDEX IF NOT EXISTS idx_order_items_order 
    ON sales.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product 
    ON sales.order_items(prod_id);

-- Payments
CREATE INDEX IF NOT EXISTS idx_payments_order 
    ON sales.payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_date 
    ON sales.payments(payment_date DESC);
CREATE INDEX IF NOT EXISTS idx_payments_mode 
    ON sales.payments(payment_mode);

-- Shipments
CREATE INDEX IF NOT EXISTS idx_shipments_order 
    ON sales.shipments(order_id);
CREATE INDEX IF NOT EXISTS idx_shipments_status 
    ON sales.shipments(status);
CREATE INDEX IF NOT EXISTS idx_shipments_shipped 
    ON sales.shipments(shipped_date DESC);
CREATE INDEX IF NOT EXISTS idx_shipments_delivered 
    ON sales.shipments(delivered_date DESC);

-- Returns
CREATE INDEX IF NOT EXISTS idx_returns_order 
    ON sales.returns(order_id);
CREATE INDEX IF NOT EXISTS idx_returns_product 
    ON sales.returns(prod_id);
CREATE INDEX IF NOT EXISTS idx_returns_date 
    ON sales.returns(return_date DESC);

\echo '      ✓ Sales indexes created (17 indexes)'


-- ============================================================================
-- CUSTOMERS SCHEMA INDEXES
-- ============================================================================

\echo '[2/12] Creating indexes on customers schema...'

-- Customers table (V2: registration_date, no city/state/join_date on this table)
CREATE INDEX IF NOT EXISTS idx_customers_reg_date 
    ON customers.customers(registration_date DESC);
CREATE INDEX IF NOT EXISTS idx_customers_email 
    ON customers.customers(email);

-- Addresses (V2: location data is here, not on customers)
CREATE INDEX IF NOT EXISTS idx_addresses_customer 
    ON customers.addresses(customer_id);
CREATE INDEX IF NOT EXISTS idx_addresses_city 
    ON customers.addresses(city);
CREATE INDEX IF NOT EXISTS idx_addresses_state 
    ON customers.addresses(state);
CREATE INDEX IF NOT EXISTS idx_addresses_default 
    ON customers.addresses(customer_id, is_default);

-- Reviews (V2: customer_id and product_id, not cust_id/prod_id)
CREATE INDEX IF NOT EXISTS idx_reviews_customer 
    ON customers.reviews(customer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product 
    ON customers.reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_date 
    ON customers.reviews(review_date DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_rating 
    ON customers.reviews(rating);

-- Loyalty points
CREATE INDEX IF NOT EXISTS idx_loyalty_points_customer 
    ON customers.loyalty_points(customer_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_points_date 
    ON customers.loyalty_points(date_earned DESC);

\echo '      ✓ Customers indexes created (12 indexes)'


-- ============================================================================
-- PRODUCTS SCHEMA INDEXES
-- ============================================================================

\echo '[3/12] Creating indexes on products schema...'

-- Products (V2: brand_id FK, no direct category/brand columns)
CREATE INDEX IF NOT EXISTS idx_products_brand 
    ON products.products(brand_id);
CREATE INDEX IF NOT EXISTS idx_products_supplier 
    ON products.products(supplier_id);
CREATE INDEX IF NOT EXISTS idx_products_price 
    ON products.products(price);

-- Inventory (V2: quantity_on_hand, not stock_qty)
CREATE INDEX IF NOT EXISTS idx_inventory_store 
    ON products.inventory(store_id);
CREATE INDEX IF NOT EXISTS idx_inventory_product 
    ON products.inventory(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_qty 
    ON products.inventory(quantity_on_hand);

-- Promotions
CREATE INDEX IF NOT EXISTS idx_promotions_dates 
    ON products.promotions(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_promotions_active 
    ON products.promotions(active);

\echo '      ✓ Products indexes created (8 indexes)'


-- ============================================================================
-- STORES SCHEMA INDEXES
-- ============================================================================

\echo '[4/12] Creating indexes on stores schema...'

-- Stores (V2: region_id FK to core.dim_region)
CREATE INDEX IF NOT EXISTS idx_stores_region 
    ON stores.stores(region_id);
CREATE INDEX IF NOT EXISTS idx_stores_city 
    ON stores.stores(city);

-- Employees
CREATE INDEX IF NOT EXISTS idx_employees_store 
    ON stores.employees(store_id);
CREATE INDEX IF NOT EXISTS idx_employees_dept 
    ON stores.employees(dept_id);
CREATE INDEX IF NOT EXISTS idx_employees_role 
    ON stores.employees(role);
CREATE INDEX IF NOT EXISTS idx_employees_joining 
    ON stores.employees(joining_date DESC);

-- Store Expenses
CREATE INDEX IF NOT EXISTS idx_store_expenses_store 
    ON stores.expenses(store_id);
CREATE INDEX IF NOT EXISTS idx_store_expenses_date 
    ON stores.expenses(expense_date DESC);
CREATE INDEX IF NOT EXISTS idx_store_expenses_type 
    ON stores.expenses(expense_type);

\echo '      ✓ Stores indexes created (9 indexes)'


-- ============================================================================
-- MARKETING SCHEMA INDEXES
-- ============================================================================

\echo '[5/12] Creating indexes on marketing schema...'

-- Campaigns
CREATE INDEX IF NOT EXISTS idx_campaigns_dates 
    ON marketing.campaigns(start_date, end_date);

-- Ad Spend (V2: platform, not channel; no clicks/conversions)
CREATE INDEX IF NOT EXISTS idx_ads_campaign 
    ON marketing.ads_spend(campaign_id);
CREATE INDEX IF NOT EXISTS idx_ads_platform 
    ON marketing.ads_spend(platform);
CREATE INDEX IF NOT EXISTS idx_ads_date 
    ON marketing.ads_spend(spend_date DESC);

-- Email Clicks
CREATE INDEX IF NOT EXISTS idx_email_campaign 
    ON marketing.email_clicks(campaign_id);
CREATE INDEX IF NOT EXISTS idx_email_date 
    ON marketing.email_clicks(sent_date DESC);

\echo '      ✓ Marketing indexes created (6 indexes)'


-- ============================================================================
-- CORE/DIMENSION SCHEMA INDEXES
-- ============================================================================

\echo '[6/12] Creating indexes on core dimensions...'

CREATE INDEX IF NOT EXISTS idx_dimdate_year 
    ON core.dim_date(year);
CREATE INDEX IF NOT EXISTS idx_dimdate_month 
    ON core.dim_date(year, month);
CREATE INDEX IF NOT EXISTS idx_dimdate_quarter 
    ON core.dim_date(year, quarter);
CREATE INDEX IF NOT EXISTS idx_dimbrand_category 
    ON core.dim_brand(category_id);

\echo '      ✓ Core indexes created (4 indexes)'


-- ============================================================================
-- 🆕 FINANCE SCHEMA INDEXES
-- ============================================================================

\echo '[7/12] Creating indexes on finance schema...'

CREATE INDEX IF NOT EXISTS idx_finance_exp_date 
    ON finance.expenses(expense_date DESC);
CREATE INDEX IF NOT EXISTS idx_finance_exp_category 
    ON finance.expenses(exp_cat_id);
CREATE INDEX IF NOT EXISTS idx_revenue_summary_date 
    ON finance.revenue_summary(summary_date DESC);

\echo '      ✓ Finance indexes created (3 indexes)'


-- ============================================================================
-- 🆕 HR & PAYROLL SCHEMA INDEXES
-- ============================================================================

\echo '[8/12] Creating indexes on hr & payroll schemas...'

-- HR Attendance (V2: attendance_date, check_in, check_out — no status column)
CREATE INDEX IF NOT EXISTS idx_attendance_employee 
    ON hr.attendance(employee_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date 
    ON hr.attendance(attendance_date DESC);

-- HR Salary History
CREATE INDEX IF NOT EXISTS idx_salary_hist_employee 
    ON hr.salary_history(employee_id);
CREATE INDEX IF NOT EXISTS idx_salary_hist_date 
    ON hr.salary_history(payment_date DESC);
CREATE INDEX IF NOT EXISTS idx_salary_hist_status 
    ON hr.salary_history(status);

-- Payroll Pay Slips
CREATE INDEX IF NOT EXISTS idx_payslips_employee 
    ON payroll.pay_slips(employee_id);
CREATE INDEX IF NOT EXISTS idx_payslips_month_year 
    ON payroll.pay_slips(salary_year, salary_month);
CREATE INDEX IF NOT EXISTS idx_payslips_payment_date 
    ON payroll.pay_slips(payment_date DESC);

\echo '      ✓ HR & Payroll indexes created (8 indexes)'


-- ============================================================================
-- 🆕 AUDIT SCHEMA INDEXES
-- ============================================================================

\echo '[9/12] Creating indexes on audit schema...'

-- Application Logs
CREATE INDEX IF NOT EXISTS idx_app_logs_timestamp 
    ON audit.application_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_app_logs_service 
    ON audit.application_logs(service_name);
CREATE INDEX IF NOT EXISTS idx_app_logs_level 
    ON audit.application_logs(level);
CREATE INDEX IF NOT EXISTS idx_app_logs_service_level 
    ON audit.application_logs(service_name, level);

-- API Requests
CREATE INDEX IF NOT EXISTS idx_api_req_timestamp 
    ON audit.api_requests(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_api_req_endpoint 
    ON audit.api_requests(endpoint);
CREATE INDEX IF NOT EXISTS idx_api_req_status 
    ON audit.api_requests(status_code);
CREATE INDEX IF NOT EXISTS idx_api_req_method 
    ON audit.api_requests(method);

-- Record Changes
CREATE INDEX IF NOT EXISTS idx_record_changes_table 
    ON audit.record_changes(table_name);
CREATE INDEX IF NOT EXISTS idx_record_changes_changed_at 
    ON audit.record_changes(changed_at DESC);
CREATE INDEX IF NOT EXISTS idx_record_changes_changed_by 
    ON audit.record_changes(changed_by);
CREATE INDEX IF NOT EXISTS idx_record_changes_action 
    ON audit.record_changes(action);

\echo '      ✓ Audit indexes created (12 indexes)'


-- ============================================================================
-- 🆕 SUPPLY CHAIN & MANUFACTURE SCHEMA INDEXES
-- ============================================================================

\echo '[10/12] Creating indexes on supply_chain & manufacture schemas...'

-- Supply Chain Shipments
CREATE INDEX IF NOT EXISTS idx_sc_shipments_supplier 
    ON supply_chain.shipments(supplier_id);
CREATE INDEX IF NOT EXISTS idx_sc_shipments_warehouse 
    ON supply_chain.shipments(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_sc_shipments_product 
    ON supply_chain.shipments(product_id);
CREATE INDEX IF NOT EXISTS idx_sc_shipments_status 
    ON supply_chain.shipments(status);
CREATE INDEX IF NOT EXISTS idx_sc_shipments_shipped 
    ON supply_chain.shipments(shipped_date DESC);

-- Supply Chain Inventory Snapshots
CREATE INDEX IF NOT EXISTS idx_sc_snapshots_date 
    ON supply_chain.inventory_snapshots(snapshot_date DESC);
CREATE INDEX IF NOT EXISTS idx_sc_snapshots_warehouse 
    ON supply_chain.inventory_snapshots(warehouse_id);

-- Manufacture Work Orders
CREATE INDEX IF NOT EXISTS idx_work_orders_product 
    ON manufacture.work_orders(product_id);
CREATE INDEX IF NOT EXISTS idx_work_orders_line 
    ON manufacture.work_orders(line_id);
CREATE INDEX IF NOT EXISTS idx_work_orders_status 
    ON manufacture.work_orders(status);
CREATE INDEX IF NOT EXISTS idx_work_orders_start 
    ON manufacture.work_orders(start_timestamp DESC);

\echo '      ✓ Supply Chain & Manufacture indexes created (11 indexes)'


-- ============================================================================
-- 🆕 CALL CENTER & SUPPORT SCHEMA INDEXES
-- ============================================================================

\echo '[11/12] Creating indexes on call_center & support schemas...'

-- Call Center Calls
CREATE INDEX IF NOT EXISTS idx_calls_customer 
    ON call_center.calls(customer_id);
CREATE INDEX IF NOT EXISTS idx_calls_agent 
    ON call_center.calls(agent_id);
CREATE INDEX IF NOT EXISTS idx_calls_start_time 
    ON call_center.calls(call_start_time DESC);
CREATE INDEX IF NOT EXISTS idx_calls_reason 
    ON call_center.calls(call_reason);
CREATE INDEX IF NOT EXISTS idx_calls_status 
    ON call_center.calls(status);

-- Call Center Transcripts
CREATE INDEX IF NOT EXISTS idx_transcripts_call 
    ON call_center.transcripts(call_id);
CREATE INDEX IF NOT EXISTS idx_transcripts_sentiment 
    ON call_center.transcripts(sentiment_score);

-- Support Tickets
CREATE INDEX IF NOT EXISTS idx_tickets_customer 
    ON support.tickets(customer_id);
CREATE INDEX IF NOT EXISTS idx_tickets_agent 
    ON support.tickets(agent_id);
CREATE INDEX IF NOT EXISTS idx_tickets_category 
    ON support.tickets(category);
CREATE INDEX IF NOT EXISTS idx_tickets_priority 
    ON support.tickets(priority);
CREATE INDEX IF NOT EXISTS idx_tickets_status 
    ON support.tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_created 
    ON support.tickets(created_date DESC);

\echo '      ✓ Call Center & Support indexes created (13 indexes)'


-- ============================================================================
-- 🆕 WEB EVENTS & LOYALTY SCHEMA INDEXES
-- ============================================================================

\echo '[12/12] Creating indexes on web_events & loyalty schemas...'

-- Web Events Page Views
CREATE INDEX IF NOT EXISTS idx_pageviews_session 
    ON web_events.page_views(session_id);
CREATE INDEX IF NOT EXISTS idx_pageviews_customer 
    ON web_events.page_views(customer_id);
CREATE INDEX IF NOT EXISTS idx_pageviews_timestamp 
    ON web_events.page_views(view_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_pageviews_device 
    ON web_events.page_views(device_type);
CREATE INDEX IF NOT EXISTS idx_pageviews_page 
    ON web_events.page_views(page_url);

-- Web Events Events
CREATE INDEX IF NOT EXISTS idx_events_view 
    ON web_events.events(view_id);
CREATE INDEX IF NOT EXISTS idx_events_type 
    ON web_events.events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_timestamp 
    ON web_events.events(event_timestamp DESC);

-- Loyalty Members
CREATE INDEX IF NOT EXISTS idx_loyalty_members_tier 
    ON loyalty.members(tier_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_members_join 
    ON loyalty.members(join_date DESC);

-- Loyalty Redemptions
CREATE INDEX IF NOT EXISTS idx_loyalty_redemptions_customer 
    ON loyalty.redemptions(customer_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_redemptions_date 
    ON loyalty.redemptions(redemption_date DESC);

\echo '      ✓ Web Events & Loyalty indexes created (12 indexes)'


-- ============================================================================
-- ANALYZE TABLES
-- ============================================================================
-- After creating indexes, run ANALYZE to update statistics
-- This helps the query planner make better decisions

\echo ''
\echo 'Updating table statistics...'

-- Core
ANALYZE core.dim_date;
ANALYZE core.dim_region;
ANALYZE core.dim_brand;
ANALYZE core.dim_category;
ANALYZE core.dim_department;
ANALYZE core.dim_expense_category;

-- Sales
ANALYZE sales.orders;
ANALYZE sales.order_items;
ANALYZE sales.payments;
ANALYZE sales.shipments;
ANALYZE sales.returns;

-- Customers
ANALYZE customers.customers;
ANALYZE customers.addresses;
ANALYZE customers.reviews;
ANALYZE customers.loyalty_points;

-- Products
ANALYZE products.products;
ANALYZE products.inventory;
ANALYZE products.promotions;
ANALYZE products.suppliers;

-- Stores
ANALYZE stores.stores;
ANALYZE stores.employees;
ANALYZE stores.expenses;

-- Marketing
ANALYZE marketing.campaigns;
ANALYZE marketing.ads_spend;
ANALYZE marketing.email_clicks;

-- Finance
ANALYZE finance.expenses;
ANALYZE finance.revenue_summary;

-- HR & Payroll
ANALYZE hr.attendance;
ANALYZE hr.salary_history;
ANALYZE payroll.pay_slips;

-- Audit
ANALYZE audit.application_logs;
ANALYZE audit.api_requests;
ANALYZE audit.record_changes;

-- Supply Chain & Manufacture
ANALYZE supply_chain.warehouses;
ANALYZE supply_chain.shipments;
ANALYZE supply_chain.inventory_snapshots;
ANALYZE manufacture.production_lines;
ANALYZE manufacture.work_orders;

-- Call Center & Support
ANALYZE call_center.calls;
ANALYZE call_center.transcripts;
ANALYZE support.tickets;

-- Web Events & Loyalty
ANALYZE web_events.page_views;
ANALYZE web_events.events;
ANALYZE loyalty.tiers;
ANALYZE loyalty.members;
ANALYZE loyalty.redemptions;

\echo '✓ Table statistics updated (44 tables analyzed)'


-- ============================================================================
-- VERIFICATION
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                 PERFORMANCE INDEXES SETUP COMPLETE                         '
\echo '============================================================================'
\echo ''
\echo '✅ Indexes Created:'
\echo '   • Sales schema:          17 indexes'
\echo '   • Customers schema:      12 indexes'
\echo '   • Products schema:        8 indexes'
\echo '   • Stores schema:          9 indexes'
\echo '   • Marketing schema:       6 indexes'
\echo '   • Core schema:            4 indexes'
\echo '   • Finance schema:         3 indexes    🆕'
\echo '   • HR & Payroll schema:    8 indexes    🆕'
\echo '   • Audit schema:          12 indexes    🆕'
\echo '   • Supply Chain schema:   11 indexes    🆕'
\echo '   • Call Center & Support: 13 indexes    🆕'
\echo '   • Web Events & Loyalty:  12 indexes    🆕'
\echo '   ─────────────────────────────────────────'
\echo '   • TOTAL:                115 indexes'
\echo ''
\echo '📊 44 tables analyzed for query planner optimization'
\echo ''
\echo '➡️  Next: Run 02_data_quality/data_quality_checks.sql'
\echo '============================================================================'
\echo ''

-- Show index count by schema
SELECT 
    schemaname as schema,
    COUNT(*) as index_count
FROM pg_indexes
WHERE schemaname IN (
    'sales', 'customers', 'products', 'stores', 'marketing', 'core', 'analytics',
    'finance', 'hr', 'payroll', 'audit', 'supply_chain', 'manufacture',
    'call_center', 'support', 'web_events', 'loyalty'
)
GROUP BY schemaname
ORDER BY index_count DESC;