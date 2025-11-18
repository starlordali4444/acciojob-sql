-- ============================================================================
-- FILE: 02_kpi_queries/store_analytics.sql
-- PURPOSE: Store Analytics Module - Complete store performance tracking
-- AUTHOR: RetailMart Analytics Team
-- CREATED: 2024
-- DESCRIPTION: 
--   - Store-level performance metrics (revenue, profit, efficiency)
--   - Regional performance comparison
--   - Inventory health by store
--   - Employee productivity analysis
--   - Global refresh function for all analytics modules
--   - JSON export functions for dashboard integration
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                   STORE ANALYTICS MODULE - STARTING                        '
\echo '============================================================================'
\echo ''
\echo 'This module creates:'
\echo '  - 3 Regular Views (regional, inventory, employee analysis)'
\echo '  - 1 Materialized View (store performance)'
\echo '  - 1 Global Refresh Function (refreshes all analytics modules)'
\echo '  - 4 JSON Export Functions (for dashboard integration)'
\echo ''

-- ============================================================================
-- 1. STORE PERFORMANCE DASHBOARD - MATERIALIZED VIEW
-- ============================================================================
-- PURPOSE: Comprehensive store-level metrics with profitability analysis
-- REFRESH: Manual (call REFRESH MATERIALIZED VIEW or use refresh function)
-- USAGE: SELECT * FROM analytics.mv_store_performance ORDER BY total_revenue DESC;
-- ============================================================================

\echo '[1/4] Creating materialized view: mv_store_performance...'
\echo '      - Aggregates sales, expenses, and employee data per store'
\echo '      - Calculates profit margins and efficiency metrics'
\echo '      - Ranks stores by revenue and profitability'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_store_performance CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_store_performance AS
WITH store_sales AS (
    -- Step 1: Aggregate sales metrics per store
    SELECT 
        s.store_id,
        s.store_name,
        s.city,
        s.state,
        s.region,
        
        -- Order Metrics
        COUNT(DISTINCT o.order_id) as total_orders,                   -- Total orders from this store
        SUM(o.total_amount) as total_revenue,                         -- Total revenue generated
        ROUND(AVG(o.total_amount), 2) as avg_order_value,            -- Average order size
        COUNT(DISTINCT o.cust_id) as unique_customers                 -- Unique customers served
    FROM stores.stores s
    LEFT JOIN sales.orders o ON s.store_id = o.store_id AND o.order_status = 'Delivered'
    GROUP BY s.store_id, s.store_name, s.city, s.state, s.region
),
store_expenses AS (
    -- Step 2: Aggregate operating expenses per store
    SELECT 
        store_id,
        SUM(amount) as total_expenses                                 -- Total operating costs
    FROM stores.expenses
    GROUP BY store_id
),
store_employees AS (
    -- Step 3: Aggregate employee metrics per store
    SELECT 
        store_id,
        COUNT(*) as employee_count,                                   -- Number of employees
        SUM(salary) as total_payroll,                                 -- Total payroll expense
        ROUND(AVG(salary), 2) as avg_salary                           -- Average employee salary
    FROM stores.employees
    GROUP BY store_id
)
-- Final Select: Combine all metrics and calculate profitability
SELECT 
    ss.store_id,
    ss.store_name,
    ss.city,
    ss.state,
    ss.region,
    
    -- Core Performance Metrics
    ss.total_orders,
    ROUND(ss.total_revenue, 2) as total_revenue,
    ss.avg_order_value,
    ss.unique_customers,
    
    -- Expense and Profitability
    COALESCE(se.total_expenses, 0) as total_expenses,
    ROUND(ss.total_revenue - COALESCE(se.total_expenses, 0), 2) as net_profit,  -- Revenue - Expenses
    ROUND(100.0 * (ss.total_revenue - COALESCE(se.total_expenses, 0)) / NULLIF(ss.total_revenue, 0), 2) as profit_margin_pct,  -- (Profit / Revenue) * 100
    
    -- Employee Metrics
    COALESCE(emp.employee_count, 0) as employee_count,
    COALESCE(ROUND(emp.total_payroll, 2), 0) as total_payroll,
    
    -- Efficiency Metrics
    ROUND(ss.total_revenue / NULLIF(emp.employee_count, 0), 2) as revenue_per_employee,  -- Productivity metric
    
    -- Rankings
    RANK() OVER (ORDER BY ss.total_revenue DESC) as revenue_rank,                        -- Rank by revenue
    RANK() OVER (ORDER BY (ss.total_revenue - COALESCE(se.total_expenses, 0)) DESC) as profit_rank  -- Rank by profit
FROM store_sales ss
LEFT JOIN store_expenses se ON ss.store_id = se.store_id
LEFT JOIN store_employees emp ON ss.store_id = emp.store_id;

-- Create index for faster regional queries
CREATE INDEX IF NOT EXISTS idx_store_perf_region 
ON analytics.mv_store_performance(region);

\echo '      ✓ Materialized view created: mv_store_performance'
\echo '      ✓ Index created on (region)'
\echo ''


-- ============================================================================
-- 2. REGIONAL PERFORMANCE ANALYSIS - VIEW
-- ============================================================================
-- PURPOSE: Aggregate store performance at the regional level
-- UPDATES: Real-time (view refreshes on query)
-- USAGE: SELECT * FROM analytics.vw_regional_performance ORDER BY total_revenue DESC;
-- ============================================================================

\echo '[2/4] Creating view: vw_regional_performance...'
\echo '      - Rolls up store metrics by region'
\echo '      - Compares regional performance'
\echo '      - Shows regional efficiency metrics'

CREATE OR REPLACE VIEW analytics.vw_regional_performance AS
SELECT 
    region,
    
    -- Store Count
    COUNT(DISTINCT store_id) as store_count,                          -- Stores in this region
    
    -- Performance Metrics
    SUM(total_orders) as total_orders,                                -- Total orders from region
    ROUND(SUM(total_revenue), 2) as total_revenue,                    -- Total revenue from region
    ROUND(AVG(avg_order_value), 2) as avg_order_value,               -- Average order value across region
    SUM(unique_customers) as total_customers,                         -- Total customers served
    
    -- Financial Metrics
    ROUND(SUM(total_expenses), 2) as total_expenses,                  -- Total regional expenses
    ROUND(SUM(net_profit), 2) as total_profit,                        -- Total regional profit
    ROUND(AVG(profit_margin_pct), 2) as avg_profit_margin,           -- Average profit margin across stores
    
    -- Employee Metrics
    SUM(employee_count) as total_employees,                           -- Total employees in region
    
    -- Efficiency Metrics
    ROUND(SUM(total_revenue) / NULLIF(SUM(employee_count), 0), 2) as revenue_per_employee,  -- Regional productivity
    ROUND(SUM(total_revenue) / NULLIF(COUNT(DISTINCT store_id), 0), 2) as avg_revenue_per_store  -- Average store performance
FROM analytics.mv_store_performance
GROUP BY region
ORDER BY total_revenue DESC;

\echo '      ✓ View created: vw_regional_performance'
\echo ''


-- ============================================================================
-- 3. STORE INVENTORY STATUS - VIEW
-- ============================================================================
-- PURPOSE: Track inventory health and identify stock issues by store
-- UPDATES: Real-time (view refreshes on query)
-- USAGE: SELECT * FROM analytics.vw_store_inventory_status WHERE inventory_health = 'Critical';
-- ============================================================================

\echo '[3/4] Creating view: vw_store_inventory_status...'
\echo '      - Shows inventory levels by store'
\echo '      - Identifies low stock and out-of-stock items'
\echo '      - Classifies inventory health status'

CREATE OR REPLACE VIEW analytics.vw_store_inventory_status AS
WITH store_inventory AS (
    -- Step 1: Calculate inventory value per store
    SELECT 
        i.store_id,
        s.store_name,
        s.city,
        s.state,
        COUNT(DISTINCT i.prod_id) as products_stocked,                -- Unique products carried
        SUM(i.stock_qty) as total_units_in_stock,                     -- Total inventory units
        SUM(i.stock_qty * p.price) as total_inventory_value           -- Total $ value of inventory
    FROM products.inventory i
    JOIN products.products p ON i.prod_id = p.prod_id
    JOIN stores.stores s ON i.store_id = s.store_id
    GROUP BY i.store_id, s.store_name, s.city, s.state
),
low_stock_items AS (
    -- Step 2: Count items with low stock (< 10 units)
    SELECT 
        store_id,
        COUNT(*) as low_stock_count                                   -- Products with < 10 units
    FROM products.inventory
    WHERE stock_qty < 10
    GROUP BY store_id
),
out_of_stock AS (
    -- Step 3: Count items completely out of stock
    SELECT 
        store_id,
        COUNT(*) as out_of_stock_count                                -- Products with 0 units
    FROM products.inventory
    WHERE stock_qty = 0
    GROUP BY store_id
)
-- Final Select: Combine inventory metrics and classify health
SELECT 
    si.store_id,
    si.store_name,
    si.city,
    si.state,
    
    -- Inventory Metrics
    si.products_stocked,
    si.total_units_in_stock,
    ROUND(si.total_inventory_value, 2) as inventory_value,
    
    -- Stock Issues
    COALESCE(ls.low_stock_count, 0) as low_stock_items,              -- Items needing reorder
    COALESCE(os.out_of_stock_count, 0) as out_of_stock_items,        -- Items unavailable
    
    -- Inventory Health Classification
    CASE 
        WHEN COALESCE(os.out_of_stock_count, 0) > 10 THEN 'Critical'  -- >10 items out of stock
        WHEN COALESCE(ls.low_stock_count, 0) > 20 THEN 'Warning'      -- >20 items low stock
        ELSE 'Good'                                                     -- Healthy inventory
    END as inventory_health
FROM store_inventory si
LEFT JOIN low_stock_items ls ON si.store_id = ls.store_id
LEFT JOIN out_of_stock os ON si.store_id = os.store_id
ORDER BY inventory_value DESC;

\echo '      ✓ View created: vw_store_inventory_status'
\echo ''


-- ============================================================================
-- 4. EMPLOYEE PERFORMANCE BY STORE - VIEW
-- ============================================================================
-- PURPOSE: Analyze employee distribution and payroll by store and department
-- UPDATES: Real-time (view refreshes on query)
-- USAGE: SELECT * FROM analytics.vw_employee_by_store WHERE store_name = 'Store A';
-- ============================================================================

\echo '[4/4] Creating view: vw_employee_by_store...'
\echo '      - Shows employee breakdown by store and department'
\echo '      - Tracks payroll expenses'
\echo '      - Identifies salary ranges'

CREATE OR REPLACE VIEW analytics.vw_employee_by_store AS
SELECT 
    s.store_id,
    s.store_name,
    d.dept_name,                                                      -- Department name
    
    -- Employee Metrics
    COUNT(e.emp_id) as employee_count,                                -- Employees in this dept/store
    
    -- Salary Metrics
    ROUND(AVG(e.salary), 2) as avg_salary,                           -- Average salary
    ROUND(MIN(e.salary), 2) as min_salary,                           -- Lowest salary
    ROUND(MAX(e.salary), 2) as max_salary,                           -- Highest salary
    ROUND(SUM(e.salary), 2) as total_payroll                         -- Total payroll cost
FROM stores.employees e
JOIN stores.stores s ON e.store_id = s.store_id
JOIN stores.departments d ON e.dept_id = d.dept_id
GROUP BY s.store_id, s.store_name, d.dept_name
ORDER BY s.store_id, total_payroll DESC;

\echo '      ✓ View created: vw_employee_by_store'
\echo ''


-- ============================================================================
-- REFRESH MATERIALIZED VIEWS
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '                    REFRESHING MATERIALIZED VIEWS                           '
\echo '============================================================================'
\echo ''

\echo 'Refreshing mv_store_performance...'
REFRESH MATERIALIZED VIEW analytics.mv_store_performance;
\echo '✓ Refreshed: mv_store_performance'

\echo ''


-- ============================================================================
-- JSON EXPORT FUNCTIONS FOR DASHBOARD INTEGRATION
-- ============================================================================
-- PURPOSE: Provide JSON endpoints for dashboard to consume data
-- USAGE: SELECT analytics.get_store_performance_json();
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                    CREATING JSON EXPORT FUNCTIONS                          '
\echo '============================================================================'
\echo ''
\echo 'These functions return JSON data for dashboard visualization:'
\echo '  - Top 20 stores by revenue'
\echo '  - Regional performance summary'
\echo '  - Store inventory health status'
\echo '  - Employee distribution by store'
\echo ''

-- ----------------------------------------------------------------------------
-- JSON Function 1: Top Stores Performance
-- ----------------------------------------------------------------------------
\echo '[JSON 1/4] Creating function: get_top_stores_json()'
\echo '           - Returns top 20 stores with all performance metrics'

CREATE OR REPLACE FUNCTION analytics.get_top_stores_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'storeId', store_id,
                'storeName', store_name,
                'city', city,
                'state', state,
                'region', region,
                'orders', total_orders,
                'revenue', total_revenue,
                'expenses', total_expenses,
                'profit', net_profit,
                'profitMargin', profit_margin_pct,
                'customers', unique_customers,
                'employees', employee_count,
                'revenuePerEmployee', revenue_per_employee,
                'revenueRank', revenue_rank,
                'profitRank', profit_rank
            ) ORDER BY revenue_rank
        )
        FROM analytics.mv_store_performance
        WHERE revenue_rank <= 20                                      -- Top 20 stores only
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_top_stores_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 2: Regional Performance Summary
-- ----------------------------------------------------------------------------
\echo '[JSON 2/4] Creating function: get_regional_performance_json()'
\echo '           - Returns performance metrics by region'

CREATE OR REPLACE FUNCTION analytics.get_regional_performance_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'region', region,
                'storeCount', store_count,
                'orders', total_orders,
                'revenue', total_revenue,
                'expenses', total_expenses,
                'profit', total_profit,
                'avgProfitMargin', avg_profit_margin,
                'customers', total_customers,
                'employees', total_employees,
                'revenuePerEmployee', revenue_per_employee,
                'avgRevenuePerStore', avg_revenue_per_store
            ) ORDER BY total_revenue DESC
        )
        FROM analytics.vw_regional_performance
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_regional_performance_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 3: Store Inventory Health
-- ----------------------------------------------------------------------------
\echo '[JSON 3/4] Creating function: get_store_inventory_json()'
\echo '           - Returns inventory status for all stores'

CREATE OR REPLACE FUNCTION analytics.get_store_inventory_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'summary', (
                SELECT json_agg(
                    json_build_object(
                        'inventoryHealth', inventory_health,
                        'storeCount', store_count,
                        'totalInventoryValue', total_value,
                        'avgLowStockItems', avg_low_stock,
                        'avgOutOfStockItems', avg_out_of_stock
                    ) ORDER BY 
                        CASE inventory_health
                            WHEN 'Critical' THEN 1
                            WHEN 'Warning' THEN 2
                            ELSE 3
                        END
                )
                FROM (
                    SELECT 
                        inventory_health,
                        COUNT(*) as store_count,
                        ROUND(SUM(inventory_value), 2) as total_value,
                        ROUND(AVG(low_stock_items), 0) as avg_low_stock,
                        ROUND(AVG(out_of_stock_items), 0) as avg_out_of_stock
                    FROM analytics.vw_store_inventory_status
                    GROUP BY inventory_health
                ) summary
            ),
            'storeDetails', (
                SELECT json_agg(
                    json_build_object(
                        'storeId', store_id,
                        'storeName', store_name,
                        'city', city,
                        'state', state,
                        'productsStocked', products_stocked,
                        'totalUnits', total_units_in_stock,
                        'inventoryValue', inventory_value,
                        'lowStockItems', low_stock_items,
                        'outOfStockItems', out_of_stock_items,
                        'inventoryHealth', inventory_health
                    ) ORDER BY inventory_value DESC
                )
                FROM analytics.vw_store_inventory_status
            )
        )
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_store_inventory_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 4: Employee Distribution
-- ----------------------------------------------------------------------------
\echo '[JSON 4/4] Creating function: get_employee_distribution_json()'
\echo '           - Returns employee and payroll breakdown by store'

CREATE OR REPLACE FUNCTION analytics.get_employee_distribution_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'storeId', store_id,
                'storeName', store_name,
                'departments', dept_data
            ) ORDER BY store_id
        )
        FROM (
            SELECT 
                store_id,
                store_name,
                json_agg(
                    json_build_object(
                        'department', dept_name,
                        'employeeCount', employee_count,
                        'avgSalary', avg_salary,
                        'minSalary', min_salary,
                        'maxSalary', max_salary,
                        'totalPayroll', total_payroll
                    ) ORDER BY total_payroll DESC
                ) as dept_data
            FROM analytics.vw_employee_by_store
            GROUP BY store_id, store_name
        ) emp
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_employee_distribution_json()'
\echo ''


-- ============================================================================
-- GLOBAL REFRESH FUNCTION FOR ALL ANALYTICS MODULES
-- ============================================================================
-- PURPOSE: Single function to refresh all materialized views across modules
-- USAGE: SELECT * FROM analytics.fn_refresh_all_analytics();
-- RETURNS: Table with refresh status for each module
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                  CREATING GLOBAL REFRESH FUNCTION                          '
\echo '============================================================================'
\echo ''
\echo 'This function refreshes all materialized views across all modules:'
\echo '  - Sales Module (2 materialized views)'
\echo '  - Product Module (2 materialized views)'
\echo '  - Customer Module (3 materialized views)'
\echo '  - Store Module (1 materialized view)'
\echo '  - Updates metadata tracking'
\echo ''

CREATE OR REPLACE FUNCTION analytics.fn_refresh_all_analytics()
RETURNS TABLE(
    module TEXT,                                                      -- Module name (Sales, Product, etc.)
    view_name TEXT,                                                   -- Names of views refreshed
    status TEXT,                                                      -- SUCCESS or FAILED
    execution_time INTERVAL,                                          -- Time taken to refresh
    refreshed_at TIMESTAMP                                            -- Timestamp of refresh
)
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    -- ========================================================================
    -- MODULE 1: SALES ANALYTICS
    -- ========================================================================
    start_time := CLOCK_TIMESTAMP();
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_monthly_sales_dashboard;
        REFRESH MATERIALIZED VIEW analytics.mv_executive_summary;
        end_time := CLOCK_TIMESTAMP();
        
        module := 'Sales';
        view_name := 'mv_monthly_sales_dashboard, mv_executive_summary';
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        module := 'Sales';
        view_name := 'All views';
        status := 'FAILED: ' || SQLERRM;                              -- Return error message
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- ========================================================================
    -- MODULE 2: PRODUCT ANALYTICS
    -- ========================================================================
    start_time := CLOCK_TIMESTAMP();
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_top_products;
        REFRESH MATERIALIZED VIEW analytics.mv_abc_analysis;
        end_time := CLOCK_TIMESTAMP();
        
        module := 'Product';
        view_name := 'mv_top_products, mv_abc_analysis';
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        module := 'Product';
        view_name := 'All views';
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- ========================================================================
    -- MODULE 3: CUSTOMER ANALYTICS
    -- ========================================================================
    start_time := CLOCK_TIMESTAMP();
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_customer_lifetime_value;
        REFRESH MATERIALIZED VIEW analytics.mv_rfm_analysis;
        REFRESH MATERIALIZED VIEW analytics.mv_cohort_retention;
        end_time := CLOCK_TIMESTAMP();
        
        module := 'Customer';
        view_name := 'mv_customer_lifetime_value, mv_rfm_analysis, mv_cohort_retention';
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        module := 'Customer';
        view_name := 'All views';
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- ========================================================================
    -- MODULE 4: STORE ANALYTICS
    -- ========================================================================
    start_time := CLOCK_TIMESTAMP();
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_store_performance;
        end_time := CLOCK_TIMESTAMP();
        
        module := 'Store';
        view_name := 'mv_store_performance';
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        module := 'Store';
        view_name := 'All views';
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- ========================================================================
    -- UPDATE METADATA TRACKING
    -- ========================================================================
    UPDATE analytics.kpi_metadata
    SET last_refreshed = CURRENT_TIMESTAMP;
    
END;
$$;

\echo '✓ Function created: fn_refresh_all_analytics()'
\echo ''


-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '              STORE ANALYTICS MODULE - SUCCESSFULLY CREATED                 '
\echo '============================================================================'
\echo ''
\echo '✅ REGULAR VIEWS (3):'
\echo '   1. vw_regional_performance        - Regional aggregation'
\echo '   2. vw_store_inventory_status      - Inventory health tracking'
\echo '   3. vw_employee_by_store           - Employee/payroll breakdown'
\echo ''
\echo '✅ MATERIALIZED VIEWS (1):'
\echo '   1. mv_store_performance           - Store-level metrics'
\echo ''
\echo '✅ GLOBAL FUNCTIONS (1):'
\echo '   1. fn_refresh_all_analytics()     - Refreshes ALL modules'
\echo ''
\echo '✅ JSON EXPORT FUNCTIONS (4):'
\echo '   1. get_top_stores_json()          - Top 20 stores'
\echo '   2. get_regional_performance_json()- Regional summary'
\echo '   3. get_store_inventory_json()     - Inventory status'
\echo '   4. get_employee_distribution_json()- Employee breakdown'
\echo ''
\echo '📊 USAGE EXAMPLES:'
\echo '   -- View store performance'
\echo '   SELECT * FROM analytics.mv_store_performance ORDER BY revenue_rank LIMIT 10;'
\echo ''
\echo '   -- Refresh all analytics modules at once'
\echo '   SELECT * FROM analytics.fn_refresh_all_analytics();'
\echo ''
\echo '   -- Get regional data as JSON'
\echo '   SELECT analytics.get_regional_performance_json();'
\echo ''
\echo '   -- Export to file'
\echo '   psql -d retailmart -t -A -c "SELECT analytics.get_top_stores_json();" > top_stores.json'
\echo ''
\echo '============================================================================'
\echo '                    ALL ANALYTICS MODULES COMPLETE!                         '
\echo '============================================================================'
\echo ''
\echo '🎉 SUMMARY OF ALL 4 MODULES:'
\echo ''
\echo '   📈 SALES MODULE:'
\echo '      - 8 Views, 2 Materialized Views, 1 Table, 7 JSON Functions'
\echo ''
\echo '   📦 PRODUCT MODULE:'
\echo '      - 3 Views, 2 Materialized Views, 5 JSON Functions'
\echo ''
\echo '   👥 CUSTOMER MODULE:'
\echo '      - 3 Views, 3 Materialized Views, 6 JSON Functions'
\echo ''
\echo '   🏪 STORE MODULE:'
\echo '      - 3 Views, 1 Materialized View, 1 Global Function, 4 JSON Functions'
\echo ''
\echo '   📊 TOTAL: 17 Views + 8 Materialized Views + 22 JSON Functions'
\echo ''
\echo '🚀 NEXT STEPS:'
\echo '   1. Test JSON functions: SELECT analytics.get_executive_summary_json();'
\echo '   2. Export JSON files for dashboard'
\echo '   3. Set up scheduled refresh: Call fn_refresh_all_analytics() daily'
\echo ''
\echo '============================================================================'
\echo ''