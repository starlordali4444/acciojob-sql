-- File: 02_kpi_queries/store_analytics.sql

-- ============================================
-- STORE ANALYTICS - COMPREHENSIVE MODULE
-- ============================================

-- ---------------------------------------------
-- 1. STORE PERFORMANCE DASHBOARD
-- ---------------------------------------------
CREATE MATERIALIZED VIEW analytics.mv_store_performance AS
WITH store_sales AS (
    SELECT 
        s.store_id,
        s.store_name,
        s.city,
        s.state,
        s.region,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_revenue,
        ROUND(AVG(o.total_amount), 2) as avg_order_value,
        COUNT(DISTINCT o.cust_id) as unique_customers
    FROM stores.stores s
    LEFT JOIN sales.orders o ON s.store_id = o.store_id AND o.order_status = 'Completed'
    GROUP BY s.store_id, s.store_name, s.city, s.state, s.region
),
store_expenses AS (
    SELECT 
        store_id,
        SUM(amount) as total_expenses
    FROM stores.expenses
    GROUP BY store_id
),
store_employees AS (
    SELECT 
        store_id,
        COUNT(*) as employee_count,
        SUM(salary) as total_payroll,
        ROUND(AVG(salary), 2) as avg_salary
    FROM stores.employees
    GROUP BY store_id
)
SELECT 
    ss.store_id,
    ss.store_name,
    ss.city,
    ss.state,
    ss.region,
    ss.total_orders,
    ROUND(ss.total_revenue, 2) as total_revenue,
    ss.avg_order_value,
    ss.unique_customers,
    COALESCE(se.total_expenses, 0) as total_expenses,
    ROUND(ss.total_revenue - COALESCE(se.total_expenses, 0), 2) as net_profit,
    ROUND(
        100.0 * (ss.total_revenue - COALESCE(se.total_expenses, 0)) / NULLIF(ss.total_revenue, 0),
        2
    ) as profit_margin_pct,
    COALESCE(emp.employee_count, 0) as employee_count,
    COALESCE(ROUND(emp.total_payroll, 2), 0) as total_payroll,
    ROUND(ss.total_revenue / NULLIF(emp.employee_count, 0), 2) as revenue_per_employee,
    RANK() OVER (ORDER BY ss.total_revenue DESC) as revenue_rank,
    RANK() OVER (ORDER BY (ss.total_revenue - COALESCE(se.total_expenses, 0)) DESC) as profit_rank
FROM store_sales ss
LEFT JOIN store_expenses se ON ss.store_id = se.store_id
LEFT JOIN store_employees emp ON ss.store_id = emp.store_id;

CREATE INDEX idx_store_perf_region ON analytics.mv_store_performance(region);

REFRESH MATERIALIZED VIEW analytics.mv_store_performance;


-- ---------------------------------------------
-- 2. REGIONAL PERFORMANCE COMPARISON
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_regional_performance AS
SELECT 
    region,
    COUNT(DISTINCT store_id) as store_count,
    SUM(total_orders) as total_orders,
    ROUND(SUM(total_revenue), 2) as total_revenue,
    ROUND(AVG(avg_order_value), 2) as avg_order_value,
    SUM(unique_customers) as total_customers,
    ROUND(SUM(total_expenses), 2) as total_expenses,
    ROUND(SUM(net_profit), 2) as total_profit,
    ROUND(AVG(profit_margin_pct), 2) as avg_profit_margin,
    SUM(employee_count) as total_employees,
    ROUND(SUM(total_revenue) / NULLIF(SUM(employee_count), 0), 2) as revenue_per_employee,
    ROUND(SUM(total_revenue) / NULLIF(COUNT(DISTINCT store_id), 0), 2) as avg_revenue_per_store
FROM analytics.mv_store_performance
GROUP BY region
ORDER BY total_revenue DESC;


-- ---------------------------------------------
-- 3. STORE INVENTORY STATUS
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_store_inventory_status AS
WITH store_inventory AS (
    SELECT 
        i.store_id,
        s.store_name,
        s.city,
        s.state,
        COUNT(DISTINCT i.prod_id) as products_stocked,
        SUM(i.stock_qty) as total_units_in_stock,
        SUM(i.stock_qty * p.price) as total_inventory_value
    FROM products.inventory i
    JOIN products.products p ON i.prod_id = p.prod_id
    JOIN stores.stores s ON i.store_id = s.store_id
    GROUP BY i.store_id, s.store_name, s.city, s.state
),
low_stock_items AS (
    SELECT 
        store_id,
        COUNT(*) as low_stock_count
    FROM products.inventory
    WHERE stock_qty < 10
    GROUP BY store_id
),
out_of_stock AS (
    SELECT 
        store_id,
        COUNT(*) as out_of_stock_count
    FROM products.inventory
    WHERE stock_qty = 0
    GROUP BY store_id
)
SELECT 
    si.store_id,
    si.store_name,
    si.city,
    si.state,
    si.products_stocked,
    si.total_units_in_stock,
    ROUND(si.total_inventory_value, 2) as inventory_value,
    COALESCE(ls.low_stock_count, 0) as low_stock_items,
    COALESCE(os.out_of_stock_count, 0) as out_of_stock_items,
    CASE 
        WHEN COALESCE(os.out_of_stock_count, 0) > 10 THEN 'Critical'
        WHEN COALESCE(ls.low_stock_count, 0) > 20 THEN 'Warning'
        ELSE 'Good'
    END as inventory_health
FROM store_inventory si
LEFT JOIN low_stock_items ls ON si.store_id = ls.store_id
LEFT JOIN out_of_stock os ON si.store_id = os.store_id
ORDER BY inventory_value DESC;


-- ---------------------------------------------
-- 4. EMPLOYEE PERFORMANCE BY STORE
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_employee_by_store AS
SELECT 
    s.store_id,
    s.store_name,
    d.dept_name,
    COUNT(e.emp_id) as employee_count,
    ROUND(AVG(e.salary), 2) as avg_salary,
    ROUND(MIN(e.salary), 2) as min_salary,
    ROUND(MAX(e.salary), 2) as max_salary,
    ROUND(SUM(e.salary), 2) as total_payroll
FROM stores.employees e
JOIN stores.stores s ON e.store_id = s.store_id
JOIN stores.departments d ON e.dept_id = d.dept_id
GROUP BY s.store_id, s.store_name, d.dept_name
ORDER BY s.store_id, total_payroll DESC;


SELECT 'Store Analytics Module Created Successfully!' as status;