-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 02_data_quality/data_quality_checks.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Data quality validation checks before analytics processing
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- DESCRIPTION:
--   "Garbage in, garbage out" — No matter how good your KPIs are, if the
--   underlying data is bad, your insights are worthless.
--
--   Real-world example: At PhonePe, before any report goes to leadership,
--   automated data quality checks run to catch issues like:
--   - Duplicate transactions
--   - Missing customer IDs
--   - Negative payment amounts
--   - Future-dated records
--
-- V2 CHANGES:
--   - full_name → first_name/last_name
--   - total_amount → net_total
--   - discount (%) → discount_amount (absolute)
--   - stock_qty → quantity_on_hand
--   - category → via brand_id JOIN
--   - Removed: age check (no age column), stale inventory check (no last_updated)
--   - Added: V2 schema checks (audit, finance, supply_chain, call_center, etc.)
--
-- EXECUTION ORDER: Run AFTER 01_setup scripts
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '     RETAILMART V2 — DATA QUALITY CHECKS                                   '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- VIEW 1: COMPLETENESS CHECKS
-- ============================================================================

\echo '[1/7] Creating completeness checks view...'

CREATE OR REPLACE VIEW analytics.vw_dq_completeness AS

-- Check 1: Orders without customer
SELECT 
    'Orders Missing Customer' as check_name,
    'COMPLETENESS' as category,
    'HIGH' as severity,
    'sales.orders' as source_table,
    COUNT(*) as issue_count,
    'Orders where cust_id is NULL' as description
FROM sales.orders
WHERE cust_id IS NULL

UNION ALL

-- Check 2: Orders without store
SELECT 
    'Orders Missing Store', 'COMPLETENESS', 'HIGH', 'sales.orders',
    COUNT(*), 'Orders where store_id is NULL'
FROM sales.orders
WHERE store_id IS NULL

UNION ALL

-- Check 3: Order items without price
SELECT 
    'Order Items Missing Price', 'COMPLETENESS', 'CRITICAL', 'sales.order_items',
    COUNT(*), 'Order items where unit_price is NULL or zero'
FROM sales.order_items
WHERE unit_price IS NULL OR unit_price = 0

UNION ALL

-- Check 4: Customers without first_name (V2: separate first/last name)
SELECT 
    'Customers Missing Name', 'COMPLETENESS', 'MEDIUM', 'customers.customers',
    COUNT(*), 'Customers where first_name is NULL or empty'
FROM customers.customers
WHERE first_name IS NULL OR TRIM(first_name) = ''

UNION ALL

-- Check 5: Products without brand (V2: category via brand_id → dim_brand → dim_category)
SELECT 
    'Products Missing Brand', 'COMPLETENESS', 'MEDIUM', 'products.products',
    COUNT(*), 'Products where brand_id is NULL'
FROM products.products
WHERE brand_id IS NULL

UNION ALL

-- Check 6: Shipments without dates
SELECT 
    'Shipments Missing Delivered Date', 'COMPLETENESS', 'HIGH', 'sales.shipments',
    COUNT(*), 'Delivered shipments without delivered_date'
FROM sales.shipments
WHERE status = 'Delivered' AND delivered_date IS NULL

UNION ALL

-- Check 7: 🆕 Employees without department
SELECT 
    'Employees Missing Department', 'COMPLETENESS', 'MEDIUM', 'stores.employees',
    COUNT(*), 'Employees where dept_id is NULL'
FROM stores.employees
WHERE dept_id IS NULL

UNION ALL

-- Check 8: 🆕 Support tickets without agent
SELECT 
    'Tickets Missing Agent', 'COMPLETENESS', 'MEDIUM', 'support.tickets',
    COUNT(*), 'Support tickets where agent_id is NULL'
FROM support.tickets
WHERE agent_id IS NULL

UNION ALL

-- Check 9: 🆕 Audit logs without timestamp
SELECT 
    'Logs Missing Timestamp', 'COMPLETENESS', 'HIGH', 'audit.application_logs',
    COUNT(*), 'Application logs where timestamp is NULL'
FROM audit.application_logs
WHERE timestamp IS NULL;

\echo '      ✓ View created: vw_dq_completeness'


-- ============================================================================
-- VIEW 2: ACCURACY CHECKS
-- ============================================================================

\echo '[2/7] Creating accuracy checks view...'

CREATE OR REPLACE VIEW analytics.vw_dq_accuracy AS

-- Check 1: Negative order amounts (V2: net_total)
SELECT 
    'Negative Order Amount' as check_name,
    'ACCURACY' as category,
    'CRITICAL' as severity,
    'sales.orders' as source_table,
    COUNT(*) as issue_count,
    'Orders where net_total is negative' as description
FROM sales.orders
WHERE net_total < 0

UNION ALL

-- Check 2: Future order dates
SELECT 
    'Future Order Dates', 'ACCURACY', 'CRITICAL', 'sales.orders',
    COUNT(*), 'Orders with order_date in the future'
FROM sales.orders
WHERE order_date > CURRENT_DATE

UNION ALL

-- Check 3: Negative quantities
SELECT 
    'Negative Quantities', 'ACCURACY', 'HIGH', 'sales.order_items',
    COUNT(*), 'Order items with negative quantity'
FROM sales.order_items
WHERE quantity < 0

UNION ALL

-- Check 4: Discount exceeds gross (V2: discount_amount is absolute ₹, not %)
SELECT 
    'Discount Exceeds Gross Amount', 'ACCURACY', 'HIGH', 'sales.order_items',
    COUNT(*), 'Order items where discount_amount > gross_amount'
FROM sales.order_items
WHERE discount_amount > gross_amount

UNION ALL

-- Check 5: Negative inventory (V2: quantity_on_hand)
SELECT 
    'Negative Inventory', 'ACCURACY', 'MEDIUM', 'products.inventory',
    COUNT(*), 'Inventory records with negative quantity_on_hand'
FROM products.inventory
WHERE quantity_on_hand < 0

UNION ALL

-- Check 6: Invalid ratings
SELECT 
    'Invalid Ratings', 'ACCURACY', 'LOW', 'customers.reviews',
    COUNT(*), 'Reviews with rating outside 1-5 range'
FROM customers.reviews
WHERE rating < 1 OR rating > 5

UNION ALL

-- Check 7: Delivered before shipped
SELECT 
    'Delivery Before Shipment', 'ACCURACY', 'HIGH', 'sales.shipments',
    COUNT(*), 'Shipments where delivered_date < shipped_date'
FROM sales.shipments
WHERE delivered_date < shipped_date

UNION ALL

-- Check 8: 🆕 Negative salary
SELECT 
    'Negative Salary', 'ACCURACY', 'HIGH', 'stores.employees',
    COUNT(*), 'Employees with negative salary'
FROM stores.employees
WHERE salary < 0

UNION ALL

-- Check 9: 🆕 Negative expense amounts
SELECT 
    'Negative Expense Amount', 'ACCURACY', 'HIGH', 'finance.expenses',
    COUNT(*), 'Finance expenses with negative amount'
FROM finance.expenses
WHERE amount < 0

UNION ALL

-- Check 10: 🆕 Invalid API status codes
SELECT 
    'Invalid API Status Code', 'ACCURACY', 'MEDIUM', 'audit.api_requests',
    COUNT(*), 'API requests with status_code < 100 or > 599'
FROM audit.api_requests
WHERE status_code < 100 OR status_code > 599

UNION ALL

-- Check 11: 🆕 Negative call duration
SELECT 
    'Negative Call Duration', 'ACCURACY', 'MEDIUM', 'call_center.calls',
    COUNT(*), 'Calls with negative duration'
FROM call_center.calls
WHERE call_duration_seconds < 0

UNION ALL

-- Check 12: 🆕 Invalid sentiment score
SELECT 
    'Invalid Sentiment Score', 'ACCURACY', 'LOW', 'call_center.transcripts',
    COUNT(*), 'Transcripts with sentiment_score outside 0-1 range'
FROM call_center.transcripts
WHERE sentiment_score < 0 OR sentiment_score > 1

UNION ALL

-- Check 13: 🆕 Rejected > Produced in manufacturing
SELECT 
    'Rejected Exceeds Produced', 'ACCURACY', 'HIGH', 'manufacture.work_orders',
    COUNT(*), 'Work orders where rejected_quantity > quantity_produced'
FROM manufacture.work_orders
WHERE rejected_quantity > quantity_produced;

\echo '      ✓ View created: vw_dq_accuracy'


-- ============================================================================
-- VIEW 3: CONSISTENCY CHECKS
-- ============================================================================

\echo '[3/7] Creating consistency checks view...'

CREATE OR REPLACE VIEW analytics.vw_dq_consistency AS

-- Check 1: Orders with invalid customer (V2: customer_id on customers table)
SELECT 
    'Orphan Orders (Invalid Customer)' as check_name,
    'CONSISTENCY' as category,
    'CRITICAL' as severity,
    'sales.orders' as source_table,
    COUNT(*) as issue_count,
    'Orders referencing non-existent customer' as description
FROM sales.orders o
WHERE NOT EXISTS (SELECT 1 FROM customers.customers c WHERE c.customer_id = o.cust_id)
AND o.cust_id IS NOT NULL

UNION ALL

-- Check 2: Orders with invalid store
SELECT 
    'Orphan Orders (Invalid Store)', 'CONSISTENCY', 'HIGH', 'sales.orders',
    COUNT(*), 'Orders referencing non-existent store'
FROM sales.orders o
WHERE NOT EXISTS (SELECT 1 FROM stores.stores s WHERE s.store_id = o.store_id)
AND o.store_id IS NOT NULL

UNION ALL

-- Check 3: Order items with invalid order
SELECT 
    'Orphan Order Items', 'CONSISTENCY', 'CRITICAL', 'sales.order_items',
    COUNT(*), 'Order items referencing non-existent order'
FROM sales.order_items oi
WHERE NOT EXISTS (SELECT 1 FROM sales.orders o WHERE o.order_id = oi.order_id)

UNION ALL

-- Check 4: Order items with invalid product (V2: product_id on products)
SELECT 
    'Invalid Product Reference', 'CONSISTENCY', 'HIGH', 'sales.order_items',
    COUNT(*), 'Order items referencing non-existent product'
FROM sales.order_items oi
WHERE NOT EXISTS (SELECT 1 FROM products.products p WHERE p.product_id = oi.prod_id)

UNION ALL

-- Check 5: Payments with invalid order
SELECT 
    'Orphan Payments', 'CONSISTENCY', 'CRITICAL', 'sales.payments',
    COUNT(*), 'Payments referencing non-existent order'
FROM sales.payments p
WHERE NOT EXISTS (SELECT 1 FROM sales.orders o WHERE o.order_id = p.order_id)

UNION ALL

-- Check 6: Shipments with invalid order
SELECT 
    'Orphan Shipments', 'CONSISTENCY', 'HIGH', 'sales.shipments',
    COUNT(*), 'Shipments referencing non-existent order'
FROM sales.shipments s
WHERE NOT EXISTS (SELECT 1 FROM sales.orders o WHERE o.order_id = s.order_id)

UNION ALL

-- Check 7: Returns with invalid order
SELECT 
    'Orphan Returns', 'CONSISTENCY', 'HIGH', 'sales.returns',
    COUNT(*), 'Returns referencing non-existent order'
FROM sales.returns r
WHERE NOT EXISTS (SELECT 1 FROM sales.orders o WHERE o.order_id = r.order_id)

UNION ALL

-- Check 8: Order total vs item sum mismatch (V2: net_total vs sum of net_amount)
SELECT 
    'Order Total Mismatch', 'CONSISTENCY', 'MEDIUM', 'sales.orders',
    COUNT(*), 'Orders where net_total differs from sum of item net_amounts'
FROM (
    SELECT o.order_id, o.net_total,
           SUM(oi.net_amount) as calculated_total
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.net_total
    HAVING ABS(o.net_total - SUM(oi.net_amount)) > 1
) mismatches

UNION ALL

-- Check 9: 🆕 Products with invalid brand
SELECT 
    'Products Invalid Brand', 'CONSISTENCY', 'HIGH', 'products.products',
    COUNT(*), 'Products referencing non-existent brand'
FROM products.products p
WHERE NOT EXISTS (SELECT 1 FROM core.dim_brand b WHERE b.brand_id = p.brand_id)
AND p.brand_id IS NOT NULL

UNION ALL

-- Check 10: 🆕 Brand with invalid category
SELECT 
    'Brands Invalid Category', 'CONSISTENCY', 'MEDIUM', 'core.dim_brand',
    COUNT(*), 'Brands referencing non-existent category'
FROM core.dim_brand b
WHERE NOT EXISTS (SELECT 1 FROM core.dim_category cat WHERE cat.category_id = b.category_id)
AND b.category_id IS NOT NULL

UNION ALL

-- Check 11: 🆕 Loyalty members with invalid tier
SELECT 
    'Invalid Loyalty Tier', 'CONSISTENCY', 'MEDIUM', 'loyalty.members',
    COUNT(*), 'Loyalty members referencing non-existent tier'
FROM loyalty.members m
WHERE NOT EXISTS (SELECT 1 FROM loyalty.tiers t WHERE t.tier_id = m.tier_id);

\echo '      ✓ View created: vw_dq_consistency'


-- ============================================================================
-- VIEW 4: TIMELINESS CHECKS
-- ============================================================================

\echo '[4/7] Creating timeliness checks view...'

CREATE OR REPLACE VIEW analytics.vw_dq_timeliness AS

-- Check 1: Old pending orders
SELECT 
    'Old Pending Orders' as check_name,
    'TIMELINESS' as category,
    'MEDIUM' as severity,
    'sales.orders' as source_table,
    COUNT(*) as issue_count,
    'Orders pending for more than 7 days' as description
FROM sales.orders
WHERE order_status = 'Pending'
AND order_date < (SELECT MAX(order_date) - INTERVAL '7 days' FROM sales.orders)

UNION ALL

-- Check 2: Shipments not delivered
SELECT 
    'Long-Pending Shipments', 'TIMELINESS', 'HIGH', 'sales.shipments',
    COUNT(*), 'Shipped orders not delivered within 10 days'
FROM sales.shipments
WHERE status = 'Shipped'
AND shipped_date < (SELECT MAX(order_date) - INTERVAL '10 days' FROM sales.orders)

UNION ALL

-- Check 3: 🆕 Unresolved support tickets
SELECT 
    'Old Unresolved Tickets', 'TIMELINESS', 'MEDIUM', 'support.tickets',
    COUNT(*), 'Support tickets open for more than 7 days'
FROM support.tickets
WHERE status NOT IN ('Resolved', 'Closed')
AND created_date < CURRENT_TIMESTAMP - INTERVAL '7 days'

UNION ALL

-- Check 4: 🆕 Stale supply chain shipments
SELECT 
    'Stale Inbound Shipments', 'TIMELINESS', 'HIGH', 'supply_chain.shipments',
    COUNT(*), 'Inbound shipments in-transit for more than 10 days'
FROM supply_chain.shipments
WHERE status = 'Shipped'
AND shipped_date < CURRENT_DATE - INTERVAL '10 days';

\echo '      ✓ View created: vw_dq_timeliness'


-- ============================================================================
-- VIEW 5: UNIQUENESS CHECKS
-- ============================================================================

\echo '[5/7] Creating uniqueness checks view...'

CREATE OR REPLACE VIEW analytics.vw_dq_uniqueness AS

-- Check 1: Potential duplicate customers (V2: first_name + last_name + email)
SELECT 
    'Potential Duplicate Customers' as check_name,
    'UNIQUENESS' as category,
    'LOW' as severity,
    'customers.customers' as source_table,
    COUNT(*) as issue_count,
    'Customers with same name and email' as description
FROM (
    SELECT first_name, last_name, email, COUNT(*) as cnt
    FROM customers.customers
    WHERE first_name IS NOT NULL AND email IS NOT NULL
    GROUP BY first_name, last_name, email
    HAVING COUNT(*) > 1
) dups

UNION ALL

-- Check 2: Multiple payments for same order
SELECT 
    'Multiple Payments Per Order', 'UNIQUENESS', 'LOW', 'sales.payments',
    COUNT(*), 'Orders with more than one payment record'
FROM (
    SELECT order_id, COUNT(*) as cnt
    FROM sales.payments
    GROUP BY order_id
    HAVING COUNT(*) > 1
) multi_payments

UNION ALL

-- Check 3: 🆕 Duplicate product names
SELECT 
    'Duplicate Product Names', 'UNIQUENESS', 'MEDIUM', 'products.products',
    COUNT(*), 'Products with identical product_name'
FROM (
    SELECT product_name, COUNT(*) as cnt
    FROM products.products
    WHERE product_name IS NOT NULL
    GROUP BY product_name
    HAVING COUNT(*) > 1
) dup_products;

\echo '      ✓ View created: vw_dq_uniqueness'


-- ============================================================================
-- VIEW 6: CONSOLIDATED DATA QUALITY REPORT
-- ============================================================================

\echo '[6/7] Creating consolidated DQ report view...'

CREATE OR REPLACE VIEW analytics.vw_data_quality_report AS
SELECT * FROM analytics.vw_dq_completeness WHERE issue_count > 0
UNION ALL
SELECT * FROM analytics.vw_dq_accuracy WHERE issue_count > 0
UNION ALL
SELECT * FROM analytics.vw_dq_consistency WHERE issue_count > 0
UNION ALL
SELECT * FROM analytics.vw_dq_timeliness WHERE issue_count > 0
UNION ALL
SELECT * FROM analytics.vw_dq_uniqueness WHERE issue_count > 0;

\echo '      ✓ View created: vw_data_quality_report'


-- ============================================================================
-- FUNCTION: RUN ALL DATA QUALITY CHECKS
-- ============================================================================

\echo '[7/7] Creating data quality check function...'

CREATE OR REPLACE FUNCTION analytics.fn_run_data_quality_checks()
RETURNS TABLE (
    check_name VARCHAR,
    category VARCHAR,
    severity VARCHAR,
    source_table VARCHAR,
    issue_count BIGINT,
    description TEXT
) AS $$
DECLARE
    v_log_id INTEGER;
    v_total_issues BIGINT := 0;
    rec RECORD;
BEGIN
    v_log_id := analytics.log_operation_start('VALIDATE', 'Data Quality', 'fn_run_data_quality_checks');
    
    -- Clear old issues
    DELETE FROM analytics.data_quality_issues 
    WHERE detected_at < CURRENT_TIMESTAMP - INTERVAL '7 days';
    
    FOR rec IN SELECT * FROM analytics.vw_data_quality_report LOOP
        IF rec.issue_count > 0 THEN
            PERFORM analytics.log_dq_issue(
                rec.check_name, rec.category, rec.severity,
                rec.source_table, rec.issue_count, rec.description
            );
            v_total_issues := v_total_issues + rec.issue_count;
        END IF;
        
        check_name := rec.check_name;
        category := rec.category;
        severity := rec.severity;
        source_table := rec.source_table;
        issue_count := rec.issue_count;
        description := rec.description;
        RETURN NEXT;
    END LOOP;
    
    PERFORM analytics.log_operation_complete(v_log_id, 'SUCCESS', v_total_issues);
    RETURN;
END;
$$ LANGUAGE plpgsql;

\echo '      ✓ Function created: fn_run_data_quality_checks()'


-- ============================================================================
-- VERIFICATION
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '          DATA QUALITY CHECKS (V2) — COMPLETE                               '
\echo '============================================================================'
\echo ''
\echo '✅ Views Created:'
\echo '   • vw_dq_completeness     — Missing/NULL value checks (9 checks)'
\echo '   • vw_dq_accuracy         — Value range and logic checks (13 checks)'
\echo '   • vw_dq_consistency      — Referential integrity checks (11 checks)'
\echo '   • vw_dq_timeliness       — Data freshness checks (4 checks)'
\echo '   • vw_dq_uniqueness       — Duplicate detection (3 checks)'
\echo '   • vw_data_quality_report — Consolidated report'
\echo ''
\echo '✅ Functions Created:'
\echo '   • fn_run_data_quality_checks() — Run all checks and log issues'
\echo ''
\echo '📊 Total: 40 data quality checks across 5 dimensions'
\echo ''
\echo '➡️  Next: Run 03_kpi_queries/01_sales_analytics.sql'
\echo '============================================================================'
\echo ''

SELECT 
    severity,
    COUNT(*) as checks_with_issues,
    SUM(issue_count) as total_issues
FROM analytics.vw_data_quality_report
GROUP BY severity
ORDER BY 
    CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 WHEN 'MEDIUM' THEN 3 WHEN 'LOW' THEN 4 END;