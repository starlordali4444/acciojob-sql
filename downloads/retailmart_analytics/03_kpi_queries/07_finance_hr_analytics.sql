-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 03_kpi_queries/07_finance_hr_analytics.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Finance & HR Analytics — Expenses, P&L, Attendance, Salary, Payroll
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3) — 🆕 NEW MODULE
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- DESCRIPTION:
--   Every CFO wants to know: "Are we profitable? Where's the money going?"
--   Every HR head asks: "Who's showing up? What's our payroll burden?"
--
--   This module combines finance and HR into one dashboard tab:
--   - Expense tracking by category and trends
--   - Revenue vs Expense (P&L)
--   - Budget tracking and overspend detection
--   - Employee attendance patterns
--   - Salary analysis by department/role
--   - Payroll cost breakdown with tax analysis
--
-- SOURCE TABLES:
--   finance.expenses, finance.revenue_summary, core.dim_expense_category,
--   hr.attendance, hr.salary_history, payroll.pay_slips, payroll.tax_brackets,
--   stores.employees, core.dim_department
--
-- CREATES: 8 Views + 1 MV + 3 JSON Functions
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '       FINANCE & HR ANALYTICS MODULE (V2) — STARTING                        '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- VIEW 1: FINANCE EXPENSE SUMMARY
-- ============================================================================

\echo '[1/9] Creating view: vw_finance_expense_summary...'

CREATE OR REPLACE VIEW analytics.vw_finance_expense_summary AS
SELECT 
    DATE_TRUNC('month', fe.expense_date)::DATE as expense_month,
    TO_CHAR(DATE_TRUNC('month', fe.expense_date), 'Mon YYYY') as month_name,
    ec.category_name as expense_category,
    COUNT(*) as transaction_count,
    ROUND(SUM(fe.amount)::NUMERIC, 2) as total_amount,
    ROUND(AVG(fe.amount)::NUMERIC, 2) as avg_amount,
    ROUND((SUM(fe.amount) / SUM(SUM(fe.amount)) OVER (PARTITION BY DATE_TRUNC('month', fe.expense_date)) * 100)::NUMERIC, 2) as pct_of_monthly_total
FROM finance.expenses fe
JOIN core.dim_expense_category ec ON fe.exp_cat_id = ec.exp_cat_id
GROUP BY DATE_TRUNC('month', fe.expense_date), ec.category_name
ORDER BY expense_month DESC, total_amount DESC;

COMMENT ON VIEW analytics.vw_finance_expense_summary IS 'Monthly expenses by category with percentage breakdown';
\echo '      ✓ View created: vw_finance_expense_summary'


-- ============================================================================
-- VIEW 2: REVENUE VS EXPENSE (P&L)
-- ============================================================================

\echo '[2/9] Creating view: vw_finance_revenue_vs_expense...'

CREATE OR REPLACE VIEW analytics.vw_finance_revenue_vs_expense AS
WITH monthly_revenue AS (
    -- Revenue = realized order value from sales.orders (the dashboard's source of
    -- truth, same as the Sales tab), rolled up to month grain. We exclude orders
    -- that never completed. To change the revenue definition, edit the WHERE below:
    --   delivered only -> WHERE order_status = 'Delivered'
    --   all orders     -> remove the WHERE clause entirely
    SELECT
        DATE_TRUNC('month', order_date)::DATE as month_date,
        SUM(net_total) as total_revenue,
        COUNT(*)::INTEGER as total_orders,
        CASE WHEN COUNT(*) > 0
             THEN SUM(net_total) / COUNT(*)
             ELSE 0 END as avg_order_value
    FROM sales.orders
    WHERE order_status NOT IN ('Cancelled', 'Failed', 'Returned')
    GROUP BY DATE_TRUNC('month', order_date)
),
monthly_expenses AS (
    SELECT 
        DATE_TRUNC('month', expense_date)::DATE as month_date,
        SUM(amount) as total_expenses
    FROM finance.expenses
    GROUP BY DATE_TRUNC('month', expense_date)
),
store_expenses AS (
    SELECT 
        DATE_TRUNC('month', expense_date)::DATE as month_date,
        SUM(amount) as total_store_expenses
    FROM stores.expenses
    GROUP BY DATE_TRUNC('month', expense_date)
)
SELECT 
    r.month_date,
    TO_CHAR(r.month_date, 'Mon YYYY') as month_name,
    ROUND(r.total_revenue::NUMERIC, 2) as total_revenue,
    r.total_orders,
    ROUND(r.avg_order_value::NUMERIC, 2) as avg_order_value,
    ROUND(COALESCE(e.total_expenses, 0)::NUMERIC, 2) as finance_expenses,
    ROUND(COALESCE(se.total_store_expenses, 0)::NUMERIC, 2) as store_expenses,
    ROUND((COALESCE(e.total_expenses, 0) + COALESCE(se.total_store_expenses, 0))::NUMERIC, 2) as total_expenses,
    ROUND((r.total_revenue - COALESCE(e.total_expenses, 0) - COALESCE(se.total_store_expenses, 0))::NUMERIC, 2) as net_profit,
    ROUND(((r.total_revenue - COALESCE(e.total_expenses, 0) - COALESCE(se.total_store_expenses, 0)) / 
           NULLIF(r.total_revenue, 0) * 100)::NUMERIC, 2) as profit_margin_pct,
    -- MoM Growth
    ROUND(((r.total_revenue - LAG(r.total_revenue) OVER (ORDER BY r.month_date)) /
           NULLIF(LAG(r.total_revenue) OVER (ORDER BY r.month_date), 0) * 100)::NUMERIC, 2) as revenue_mom_pct
FROM monthly_revenue r
LEFT JOIN monthly_expenses e ON r.month_date = e.month_date
LEFT JOIN store_expenses se ON r.month_date = se.month_date
ORDER BY r.month_date DESC;

COMMENT ON VIEW analytics.vw_finance_revenue_vs_expense IS 'Monthly P&L: revenue minus all expenses';
\echo '      ✓ View created: vw_finance_revenue_vs_expense'


-- ============================================================================
-- VIEW 3: FINANCE BUDGET TRACKING
-- ============================================================================

\echo '[3/9] Creating view: vw_finance_budget_tracking...'

CREATE OR REPLACE VIEW analytics.vw_finance_budget_tracking AS
WITH expense_by_type AS (
    SELECT 
        ec.category_name as expense_category,
        ROUND(SUM(fe.amount)::NUMERIC, 2) as total_spent,
        COUNT(*) as transaction_count,
        MIN(fe.expense_date) as first_expense,
        MAX(fe.expense_date) as last_expense
    FROM finance.expenses fe
    JOIN core.dim_expense_category ec ON fe.exp_cat_id = ec.exp_cat_id
    GROUP BY ec.category_name
)
SELECT 
    expense_category,
    total_spent,
    transaction_count,
    first_expense, last_expense,
    ROUND((total_spent / SUM(total_spent) OVER () * 100)::NUMERIC, 2) as pct_of_total,
    RANK() OVER (ORDER BY total_spent DESC) as spend_rank,
    -- Trend: avg monthly spend
    ROUND((total_spent / NULLIF(EXTRACT(MONTH FROM AGE(last_expense, first_expense)) + 1, 0))::NUMERIC, 2) as avg_monthly_spend
FROM expense_by_type
ORDER BY total_spent DESC;

COMMENT ON VIEW analytics.vw_finance_budget_tracking IS 'Expense allocation by category with spending trends';
\echo '      ✓ View created: vw_finance_budget_tracking'


-- ============================================================================
-- MATERIALIZED VIEW: MONTHLY P&L
-- ============================================================================

\echo '[4/9] Creating materialized view: mv_finance_monthly_pnl...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_finance_monthly_pnl CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_finance_monthly_pnl AS
SELECT * FROM analytics.vw_finance_revenue_vs_expense;

CREATE INDEX IF NOT EXISTS idx_pnl_month ON analytics.mv_finance_monthly_pnl(month_date);

COMMENT ON MATERIALIZED VIEW analytics.mv_finance_monthly_pnl IS 'Monthly P&L materialized for dashboard speed';
\echo '      ✓ Materialized view created: mv_finance_monthly_pnl'


-- ============================================================================
-- VIEW 4: HR ATTENDANCE SUMMARY
-- ============================================================================

\echo '[5/9] Creating view: vw_hr_attendance_summary...'

CREATE OR REPLACE VIEW analytics.vw_hr_attendance_summary AS
WITH attendance_data AS (
    SELECT 
        a.employee_id,
        e.first_name || ' ' || e.last_name as employee_name,
        d.dept_name as department,
        e.role,
        DATE_TRUNC('month', a.attendance_date)::DATE as attend_month,
        COUNT(*) as days_present,
        ROUND(AVG(EXTRACT(EPOCH FROM (a.check_out - a.check_in)) / 3600)::NUMERIC, 1) as avg_hours_worked
    FROM hr.attendance a
    JOIN stores.employees e ON a.employee_id = e.employee_id
    JOIN core.dim_department d ON e.dept_id = d.dept_id
    WHERE a.check_in IS NOT NULL
    GROUP BY a.employee_id, e.first_name, e.last_name, d.dept_name, e.role, DATE_TRUNC('month', a.attendance_date)
)
SELECT 
    attend_month,
    TO_CHAR(attend_month, 'Mon YYYY') as month_name,
    department,
    COUNT(DISTINCT employee_id) as employee_count,
    ROUND(AVG(days_present)::NUMERIC, 1) as avg_days_present,
    ROUND(AVG(avg_hours_worked)::NUMERIC, 1) as avg_hours_per_day,
    -- Assuming ~22 working days per month
    ROUND((AVG(days_present) / 22.0 * 100)::NUMERIC, 1) as attendance_pct
FROM attendance_data
GROUP BY attend_month, department
ORDER BY attend_month DESC, department;

COMMENT ON VIEW analytics.vw_hr_attendance_summary IS 'Monthly attendance by department with working hours';
\echo '      ✓ View created: vw_hr_attendance_summary'


-- ============================================================================
-- VIEW 5: HR SALARY ANALYSIS
-- ============================================================================

\echo '[6/9] Creating view: vw_hr_salary_analysis...'

CREATE OR REPLACE VIEW analytics.vw_hr_salary_analysis AS
SELECT 
    d.dept_name as department,
    e.role,
    COUNT(*) as employee_count,
    ROUND(AVG(e.salary)::NUMERIC, 2) as avg_salary,
    ROUND(MIN(e.salary)::NUMERIC, 2) as min_salary,
    ROUND(MAX(e.salary)::NUMERIC, 2) as max_salary,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY e.salary)::NUMERIC, 2) as median_salary,
    ROUND(SUM(e.salary)::NUMERIC, 2) as total_payroll,
    ROUND((SUM(e.salary) / SUM(SUM(e.salary)) OVER () * 100)::NUMERIC, 2) as pct_of_total_payroll
FROM stores.employees e
JOIN core.dim_department d ON e.dept_id = d.dept_id
GROUP BY d.dept_name, e.role
ORDER BY total_payroll DESC;

COMMENT ON VIEW analytics.vw_hr_salary_analysis IS 'Salary distribution by department and role';
\echo '      ✓ View created: vw_hr_salary_analysis'


-- ============================================================================
-- VIEW 6: PAYROLL DEPARTMENT COST
-- ============================================================================

\echo '[7/9] Creating view: vw_payroll_department_cost...'

CREATE OR REPLACE VIEW analytics.vw_payroll_department_cost AS
SELECT 
    d.dept_name as department,
    COUNT(DISTINCT ps.employee_id) as employees_paid,
    ROUND(SUM(ps.basic_salary)::NUMERIC, 2) as total_basic,
    ROUND(SUM(ps.hra)::NUMERIC, 2) as total_hra,
    ROUND(SUM(ps.other_allowances)::NUMERIC, 2) as total_allowances,
    ROUND(SUM(ps.gross_salary)::NUMERIC, 2) as total_gross,
    ROUND(SUM(ps.pf)::NUMERIC, 2) as total_pf,
    ROUND(SUM(ps.professional_tax)::NUMERIC, 2) as total_prof_tax,
    ROUND(SUM(ps.income_tax)::NUMERIC, 2) as total_income_tax,
    ROUND(SUM(ps.net_salary)::NUMERIC, 2) as total_net,
    ROUND((SUM(ps.gross_salary) - SUM(ps.net_salary))::NUMERIC, 2) as total_deductions,
    ROUND(((SUM(ps.gross_salary) - SUM(ps.net_salary)) / NULLIF(SUM(ps.gross_salary), 0) * 100)::NUMERIC, 2) as deduction_pct,
    ROUND((SUM(ps.net_salary) / SUM(SUM(ps.net_salary)) OVER () * 100)::NUMERIC, 2) as pct_of_total_payroll
FROM payroll.pay_slips ps
JOIN stores.employees e ON ps.employee_id = e.employee_id
JOIN core.dim_department d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY total_gross DESC;

COMMENT ON VIEW analytics.vw_payroll_department_cost IS 'Department-wise payroll breakdown with deductions';
\echo '      ✓ View created: vw_payroll_department_cost'


-- ============================================================================
-- VIEW 7: PAYROLL TAX SUMMARY
-- ============================================================================

\echo '[8/9] Creating view: vw_payroll_tax_summary...'

CREATE OR REPLACE VIEW analytics.vw_payroll_tax_summary AS
WITH payslip_stats AS (
    SELECT 
        ps.salary_year,
        ps.salary_month,
        COUNT(*) as slips_processed,
        ROUND(SUM(ps.gross_salary)::NUMERIC, 2) as total_gross,
        ROUND(SUM(ps.net_salary)::NUMERIC, 2) as total_net,
        ROUND(SUM(ps.pf)::NUMERIC, 2) as total_pf,
        ROUND(SUM(ps.professional_tax)::NUMERIC, 2) as total_prof_tax,
        ROUND(SUM(ps.income_tax)::NUMERIC, 2) as total_income_tax,
        ROUND(AVG(ps.gross_salary)::NUMERIC, 2) as avg_gross,
        ROUND(AVG(ps.net_salary)::NUMERIC, 2) as avg_net
    FROM payroll.pay_slips ps
    GROUP BY ps.salary_year, ps.salary_month
)
SELECT 
    salary_year, salary_month,
    slips_processed,
    total_gross, total_net,
    total_pf, total_prof_tax, total_income_tax,
    ROUND((total_pf + total_prof_tax + total_income_tax)::NUMERIC, 2) as total_deductions,
    avg_gross, avg_net,
    ROUND(((total_gross - total_net) / NULLIF(total_gross, 0) * 100)::NUMERIC, 2) as effective_tax_rate_pct
FROM payslip_stats
ORDER BY salary_year DESC, salary_month DESC;

COMMENT ON VIEW analytics.vw_payroll_tax_summary IS 'Monthly payroll tax and deduction analysis';
\echo '      ✓ View created: vw_payroll_tax_summary'


-- ============================================================================
-- VIEW 8: SALARY PAYMENT HISTORY
-- ============================================================================

\echo '[9/9] Creating view: vw_hr_salary_payment_history...'

CREATE OR REPLACE VIEW analytics.vw_hr_salary_payment_history AS
SELECT 
    DATE_TRUNC('month', sh.payment_date)::DATE as payment_month,
    TO_CHAR(DATE_TRUNC('month', sh.payment_date), 'Mon YYYY') as month_name,
    sh.status as payment_status,
    COUNT(*) as payment_count,
    COUNT(DISTINCT sh.employee_id) as employees,
    ROUND(SUM(sh.amount)::NUMERIC, 2) as total_amount,
    ROUND(AVG(sh.amount)::NUMERIC, 2) as avg_amount
FROM hr.salary_history sh
GROUP BY DATE_TRUNC('month', sh.payment_date), sh.status
ORDER BY payment_month DESC, payment_status;

COMMENT ON VIEW analytics.vw_hr_salary_payment_history IS 'Salary payment tracking by month and status';
\echo '      ✓ View created: vw_hr_salary_payment_history'


-- ============================================================================
-- JSON EXPORT FUNCTIONS
-- ============================================================================

\echo ''
\echo 'Creating JSON export functions...'

CREATE OR REPLACE FUNCTION analytics.get_finance_summary_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'pnl', (
        -- latest 12 months: LIMIT must cap the rows BEFORE aggregating, not after
        SELECT json_agg(json_build_object(
            'month', month_name, 'revenue', total_revenue, 'expenses', total_expenses,
            'profit', net_profit, 'margin', profit_margin_pct, 'revenueMoM', revenue_mom_pct
        ) ORDER BY month_date DESC)
        FROM (
            SELECT * FROM analytics.mv_finance_monthly_pnl
            ORDER BY month_date DESC LIMIT 12
        ) p
    ),
    'expenseBreakdown', (
        SELECT json_agg(json_build_object(
            'category', expense_category, 'spent', total_spent, 'pct', pct_of_total, 'rank', spend_rank
        ) ORDER BY spend_rank)
        FROM analytics.vw_finance_budget_tracking
    )
); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_hr_overview_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'attendance', (
        SELECT json_agg(json_build_object(
            'month', month_name, 'department', department, 'employees', employee_count,
            'avgDays', avg_days_present, 'avgHours', avg_hours_per_day, 'attendancePct', attendance_pct
        ) ORDER BY attend_month DESC, department)
        FROM analytics.vw_hr_attendance_summary LIMIT 50
    ),
    'salaryByDept', (
        SELECT json_agg(json_build_object(
            'department', department, 'role', role, 'employees', employee_count,
            'avgSalary', avg_salary, 'medianSalary', median_salary, 'totalPayroll', total_payroll
        ) ORDER BY total_payroll DESC)
        FROM analytics.vw_hr_salary_analysis
    )
); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_payroll_summary_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'byDepartment', (
        SELECT json_agg(json_build_object(
            'department', department, 'employees', employees_paid,
            'gross', total_gross, 'net', total_net, 'deductions', total_deductions,
            'deductionPct', deduction_pct, 'pctOfPayroll', pct_of_total_payroll
        ) ORDER BY total_gross DESC)
        FROM analytics.vw_payroll_department_cost
    ),
    'monthlyTrend', (
        SELECT json_agg(json_build_object(
            'year', salary_year, 'month', salary_month, 'gross', total_gross,
            'net', total_net, 'taxRate', effective_tax_rate_pct
        ) ORDER BY salary_year DESC, salary_month DESC)
        FROM analytics.vw_payroll_tax_summary LIMIT 12
    )
); END;
$$ LANGUAGE plpgsql STABLE;

\echo '      ✓ JSON functions created (3 functions)'

REFRESH MATERIALIZED VIEW analytics.mv_finance_monthly_pnl;

\echo ''
\echo '============================================================================'
\echo '       FINANCE & HR ANALYTICS MODULE (V2) — COMPLETE                        '
\echo '============================================================================'
\echo ''
\echo '✅ Views (8): expense summary, revenue vs expense, budget tracking,'
\echo '   attendance, salary analysis, payroll dept cost, payroll tax, salary history'
\echo '✅ MVs (1): mv_finance_monthly_pnl'
\echo '✅ JSON (3): finance_summary, hr_overview, payroll_summary'
\echo ''
\echo '➡️  Next: Run 08_audit_compliance_analytics.sql'
\echo '============================================================================'
\echo ''
