-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 03_kpi_queries/02_customer_analytics.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Customer Analytics Module — CLV, RFM, Cohort, Churn + Loyalty
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- DESCRIPTION:
--   "Your most unhappy customers are your greatest source of learning" — Bill Gates
--   
--   This module helps answer:
--   - Who are our most valuable customers? (CLV Analysis)
--   - How should we segment customers? (RFM Analysis)
--   - Are we retaining customers? (Cohort Retention)
--   - Who is about to leave? (Churn Prediction)
--   - Where are our customers? (Geography via addresses)
--   - How is the loyalty program performing? (NEW in V2)
--
-- V2 CHANGES:
--   - full_name → first_name || ' ' || last_name
--   - gender/age/region_name/city/state REMOVED from customers table
--   - join_date → registration_date
--   - Location data from customers.addresses (via default address)
--   - total_amount → net_total
--   - loyalty_points.total_points → SUM(loyalty_points.points_earned)
--   - vw_customer_demographics → replaced with vw_customer_registration_trends
--   - NEW: 3 loyalty views (tier distribution, redemption patterns, ROI)
--
-- CREATES:
--   • 7 Regular Views (4 updated + 3 new loyalty)
--   • 3 Materialized Views
--   • 7 JSON Export Functions
--
-- EXECUTION ORDER: Run AFTER 01_sales_analytics.sql
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '         CUSTOMER ANALYTICS MODULE (V2) — STARTING                          '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- MATERIALIZED VIEW 1: CUSTOMER LIFETIME VALUE (CLV)
-- ============================================================================
-- V2: No gender/age, location from addresses, net_total, computed full_name
-- ============================================================================

\echo '[1/10] Creating materialized view: mv_customer_lifetime_value...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_customer_lifetime_value CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_customer_lifetime_value AS
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name as full_name,
        c.registration_date,
        
        -- Order Metrics
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.net_total) as total_revenue,
        AVG(o.net_total) as avg_order_value,
        
        -- Timeline
        MIN(o.order_date) as first_order_date,
        MAX(o.order_date) as last_order_date,
        (SELECT MAX(order_date) FROM sales.orders) - MAX(o.order_date) as days_since_last_order,
        MAX(o.order_date) - MIN(o.order_date) as customer_lifespan_days,
        
        -- Items
        SUM(oi.quantity) as total_items_purchased
        
    FROM customers.customers c
    LEFT JOIN sales.orders o ON c.customer_id = o.cust_id AND o.order_status = 'Delivered'
    LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.registration_date
),
-- V2: Get default address for each customer
customer_address AS (
    SELECT DISTINCT ON (customer_id)
        customer_id, city, state
    FROM customers.addresses
    ORDER BY customer_id, is_default DESC, address_id
),
-- V2: Loyalty points are per-transaction, need SUM
customer_loyalty AS (
    SELECT customer_id, SUM(points_earned) as total_points
    FROM customers.loyalty_points
    GROUP BY customer_id
),
customer_reviews AS (
    SELECT customer_id, COUNT(*) as review_count, ROUND(AVG(rating), 2) as avg_rating_given
    FROM customers.reviews
    GROUP BY customer_id
)
SELECT 
    co.customer_id,
    co.full_name,
    COALESCE(ca.city, 'Unknown') as city,
    COALESCE(ca.state, 'Unknown') as state,
    co.registration_date,
    
    -- Order Metrics
    COALESCE(co.total_orders, 0) as total_orders,
    ROUND(COALESCE(co.total_revenue, 0)::NUMERIC, 2) as total_revenue,
    ROUND(COALESCE(co.avg_order_value, 0)::NUMERIC, 2) as avg_order_value,
    COALESCE(co.total_items_purchased, 0) as total_items_purchased,
    
    -- Timeline
    co.first_order_date,
    co.last_order_date,
    COALESCE(co.days_since_last_order, 9999) as days_since_last_order,
    COALESCE(co.customer_lifespan_days, 0) as customer_lifespan_days,
    
    -- Loyalty & Engagement
    COALESCE(cl.total_points, 0) as loyalty_points,
    COALESCE(cr.review_count, 0) as review_count,
    COALESCE(cr.avg_rating_given, 0) as avg_rating_given,
    
    -- Projected Annual Value
    ROUND(
        COALESCE(co.total_revenue, 0) / NULLIF(GREATEST(co.customer_lifespan_days, 1), 0) * 365, 2
    )::NUMERIC as projected_annual_value,
    
    ROUND(
        COALESCE(co.total_orders, 0)::NUMERIC / NULLIF(GREATEST(co.customer_lifespan_days, 1), 0) * 30, 2
    ) as avg_orders_per_month,
    
    -- CLV Tier
    CASE 
        WHEN COALESCE(co.total_revenue, 0) >= (SELECT analytics.get_config_number('clv_tier_platinum')) THEN 'Platinum'
        WHEN COALESCE(co.total_revenue, 0) >= (SELECT analytics.get_config_number('clv_tier_gold')) THEN 'Gold'
        WHEN COALESCE(co.total_revenue, 0) >= (SELECT analytics.get_config_number('clv_tier_silver')) THEN 'Silver'
        WHEN COALESCE(co.total_revenue, 0) >= (SELECT analytics.get_config_number('clv_tier_bronze')) THEN 'Bronze'
        ELSE 'Basic'
    END as clv_tier,
    
    -- Customer Status
    CASE 
        WHEN co.total_orders IS NULL OR co.total_orders = 0 THEN 'Never Purchased'
        WHEN co.days_since_last_order <= (SELECT analytics.get_config_number('rfm_recency_active_days')) THEN 'Active'
        WHEN co.days_since_last_order <= (SELECT analytics.get_config_number('rfm_recency_at_risk_days')) THEN 'At Risk'
        WHEN co.days_since_last_order <= (SELECT analytics.get_config_number('rfm_recency_churning_days')) THEN 'Churning'
        ELSE 'Churned'
    END as customer_status

FROM customer_orders co
LEFT JOIN customer_address ca ON co.customer_id = ca.customer_id
LEFT JOIN customer_loyalty cl ON co.customer_id = cl.customer_id
LEFT JOIN customer_reviews cr ON co.customer_id = cr.customer_id;

CREATE INDEX IF NOT EXISTS idx_clv_tier ON analytics.mv_customer_lifetime_value(clv_tier);
CREATE INDEX IF NOT EXISTS idx_clv_status ON analytics.mv_customer_lifetime_value(customer_status);
CREATE INDEX IF NOT EXISTS idx_clv_city ON analytics.mv_customer_lifetime_value(city);

COMMENT ON MATERIALIZED VIEW analytics.mv_customer_lifetime_value IS 
    'Customer Lifetime Value with tier classification — Refresh daily';

\echo '      ✓ Materialized view created: mv_customer_lifetime_value'


-- ============================================================================
-- MATERIALIZED VIEW 2: RFM ANALYSIS
-- ============================================================================
-- V2: customer_id, computed full_name, city/state from addresses, net_total
-- ============================================================================

\echo '[2/10] Creating materialized view: mv_rfm_analysis...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_rfm_analysis CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_rfm_analysis AS
WITH customer_rfm AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name as full_name,
        (SELECT MAX(order_date) FROM sales.orders) - MAX(o.order_date) as recency_days,
        COUNT(DISTINCT o.order_id) as frequency,
        SUM(o.net_total) as monetary
    FROM customers.customers c
    JOIN sales.orders o ON c.customer_id = o.cust_id AND o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.first_name, c.last_name
),
rfm_scores AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) as r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) as f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) as m_score
    FROM customer_rfm
    WHERE frequency > 0
)
SELECT 
    customer_id,
    full_name,
    
    -- Raw Metrics
    recency_days,
    frequency as order_count,
    ROUND(monetary::NUMERIC, 2) as total_spent,
    
    -- RFM Scores
    r_score as recency_score,
    f_score as frequency_score,
    m_score as monetary_score,
    CONCAT(r_score, f_score, m_score) as rfm_score,
    r_score + f_score + m_score as rfm_total,
    
    -- Customer Segment
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 AND m_score <= 2 THEN 'Recent Customers'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 4 THEN 'Big Spenders'
        WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'At Risk - High Value'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3 THEN 'Hibernating'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost'
        ELSE 'Potential Loyalists'
    END as rfm_segment,
    
    -- Recommended Action
    CASE
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Reward — Exclusive offers & early access'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Nurture — Onboarding, product education'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'Win Back — Special discount, reach out'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3 THEN 'Reactivate — Strong offer to return'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Last Chance — Deep discount or let go'
        ELSE 'Engage — Regular communication'
    END as recommended_action

FROM rfm_scores;

CREATE INDEX IF NOT EXISTS idx_rfm_segment ON analytics.mv_rfm_analysis(rfm_segment);

COMMENT ON MATERIALIZED VIEW analytics.mv_rfm_analysis IS 
    'RFM segmentation for targeted marketing — Refresh weekly';

\echo '      ✓ Materialized view created: mv_rfm_analysis'


-- ============================================================================
-- MATERIALIZED VIEW 3: COHORT RETENTION
-- ============================================================================
-- V2: No column changes needed (uses cust_id/order_date from sales.orders)
-- ============================================================================

\echo '[3/10] Creating materialized view: mv_cohort_retention...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_cohort_retention CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_cohort_retention AS
WITH customer_first_order AS (
    SELECT 
        cust_id,
        DATE_TRUNC('month', MIN(order_date))::DATE as cohort_month
    FROM sales.orders
    WHERE order_status = 'Delivered'
    GROUP BY cust_id
),
customer_activity AS (
    SELECT DISTINCT
        o.cust_id,
        DATE_TRUNC('month', o.order_date)::DATE as activity_month
    FROM sales.orders o
    WHERE o.order_status = 'Delivered'
),
cohort_data AS (
    SELECT 
        cfo.cohort_month,
        ca.activity_month,
        EXTRACT(YEAR FROM AGE(ca.activity_month, cfo.cohort_month)) * 12 +
        EXTRACT(MONTH FROM AGE(ca.activity_month, cfo.cohort_month)) as months_since_cohort,
        COUNT(DISTINCT cfo.cust_id) as customer_count
    FROM customer_first_order cfo
    JOIN customer_activity ca ON cfo.cust_id = ca.cust_id
    GROUP BY cfo.cohort_month, ca.activity_month
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT cust_id) as cohort_size
    FROM customer_first_order
    GROUP BY cohort_month
)
SELECT 
    cd.cohort_month,
    TO_CHAR(cd.cohort_month, 'Mon YYYY') as cohort_name,
    cs.cohort_size,
    cd.months_since_cohort as month_number,
    cd.customer_count as retained_customers,
    ROUND((cd.customer_count::NUMERIC / cs.cohort_size * 100), 2) as retention_rate
FROM cohort_data cd
JOIN cohort_sizes cs ON cd.cohort_month = cs.cohort_month
WHERE cd.months_since_cohort <= 12
ORDER BY cd.cohort_month DESC, cd.months_since_cohort;

CREATE INDEX IF NOT EXISTS idx_cohort_month ON analytics.mv_cohort_retention(cohort_month);

COMMENT ON MATERIALIZED VIEW analytics.mv_cohort_retention IS 
    'Monthly cohort retention analysis — Refresh weekly';

\echo '      ✓ Materialized view created: mv_cohort_retention'


-- ============================================================================
-- VIEW 1: CHURN RISK CUSTOMERS
-- ============================================================================

\echo '[4/10] Creating view: vw_churn_risk_customers...'

CREATE OR REPLACE VIEW analytics.vw_churn_risk_customers AS
SELECT 
    customer_id,
    full_name,
    city,
    state,
    clv_tier,
    total_orders,
    total_revenue as total_spent,
    days_since_last_order as days_inactive,
    
    CASE 
        WHEN days_since_last_order > 180 THEN 'Churned'
        WHEN days_since_last_order > 90 THEN 'High Risk'
        WHEN days_since_last_order > 60 THEN 'Medium Risk'
        WHEN days_since_last_order > 30 THEN 'Low Risk'
        ELSE 'Active'
    END as churn_risk_level,
    
    CASE 
        WHEN clv_tier = 'Platinum' THEN 5
        WHEN clv_tier = 'Gold' THEN 4
        WHEN clv_tier = 'Silver' THEN 3
        WHEN clv_tier = 'Bronze' THEN 2
        ELSE 1
    END +
    CASE 
        WHEN days_since_last_order > 90 THEN 5
        WHEN days_since_last_order > 60 THEN 3
        WHEN days_since_last_order > 30 THEN 1
        ELSE 0
    END as priority_score,
    
    CASE 
        WHEN clv_tier IN ('Platinum', 'Gold') AND days_since_last_order > 60 
            THEN 'URGENT: Personal outreach from account manager'
        WHEN clv_tier IN ('Platinum', 'Gold') AND days_since_last_order > 30 
            THEN 'HIGH: Send exclusive offer + loyalty bonus'
        WHEN days_since_last_order > 90 
            THEN 'Win-back campaign with significant discount'
        WHEN days_since_last_order > 60 
            THEN 'Re-engagement email with personalized recommendations'
        WHEN days_since_last_order > 30 
            THEN 'Reminder email with what''s new'
        ELSE 'No action needed'
    END as recommended_action

FROM analytics.mv_customer_lifetime_value
WHERE total_orders > 0
AND days_since_last_order > 30
ORDER BY priority_score DESC, total_revenue DESC;

COMMENT ON VIEW analytics.vw_churn_risk_customers IS 'High-value customers at risk of churning';

\echo '      ✓ View created: vw_churn_risk_customers'


-- ============================================================================
-- VIEW 2: CUSTOMER REGISTRATION TRENDS (V2 — replaces demographics)
-- ============================================================================
-- V2: No gender/age in schema. This view tracks registration trends,
-- which is more actionable for growth analysis.
-- ============================================================================

\echo '[5/10] Creating view: vw_customer_registration_trends...'

CREATE OR REPLACE VIEW analytics.vw_customer_registration_trends AS
WITH monthly_signups AS (
    SELECT 
        DATE_TRUNC('month', registration_date)::DATE as signup_month,
        COUNT(*) as new_signups
    FROM customers.customers
    GROUP BY DATE_TRUNC('month', registration_date)
)
SELECT 
    signup_month,
    TO_CHAR(signup_month, 'Mon YYYY') as month_name,
    new_signups,
    SUM(new_signups) OVER (ORDER BY signup_month) as cumulative_customers,
    LAG(new_signups) OVER (ORDER BY signup_month) as prev_month_signups,
    ROUND(
        ((new_signups - LAG(new_signups) OVER (ORDER BY signup_month))::NUMERIC /
        NULLIF(LAG(new_signups) OVER (ORDER BY signup_month), 0) * 100), 2
    ) as mom_growth_pct,
    ROUND(
        AVG(new_signups) OVER (ORDER BY signup_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0
    ) as moving_avg_3month
FROM monthly_signups
ORDER BY signup_month DESC;

COMMENT ON VIEW analytics.vw_customer_registration_trends IS 'Monthly customer signup trends with growth metrics';

\echo '      ✓ View created: vw_customer_registration_trends'


-- ============================================================================
-- VIEW 3: CUSTOMER GEOGRAPHY
-- ============================================================================
-- V2: Uses CLV MV which already has city/state from addresses
-- ============================================================================

\echo '[6/10] Creating view: vw_customer_geography...'

CREATE OR REPLACE VIEW analytics.vw_customer_geography AS
WITH geo_stats AS (
    SELECT 
        state,
        city,
        COUNT(*) as customer_count,
        SUM(total_orders) as total_orders,
        SUM(total_revenue) as total_revenue,
        AVG(total_revenue) as avg_revenue_per_customer,
        AVG(avg_order_value) as avg_order_value
    FROM analytics.mv_customer_lifetime_value
    WHERE total_orders > 0
    GROUP BY state, city
)
SELECT 
    state,
    city,
    customer_count,
    total_orders,
    ROUND(total_revenue::NUMERIC, 2) as total_revenue,
    ROUND(avg_order_value::NUMERIC, 2) as avg_order_value,
    ROUND(avg_revenue_per_customer::NUMERIC, 2) as revenue_per_customer,
    RANK() OVER (ORDER BY total_revenue DESC) as revenue_rank,
    RANK() OVER (PARTITION BY state ORDER BY total_revenue DESC) as state_rank
FROM geo_stats
ORDER BY total_revenue DESC;

COMMENT ON VIEW analytics.vw_customer_geography IS 'Customer distribution by location';

\echo '      ✓ View created: vw_customer_geography'


-- ============================================================================
-- VIEW 4: NEW VS RETURNING CUSTOMERS
-- ============================================================================

\echo '[7/10] Creating view: vw_new_vs_returning...'

CREATE OR REPLACE VIEW analytics.vw_new_vs_returning AS
WITH customer_first_order AS (
    SELECT cust_id, MIN(order_date) as first_order_date
    FROM sales.orders
    WHERE order_status = 'Delivered'
    GROUP BY cust_id
),
monthly_breakdown AS (
    SELECT 
        DATE_TRUNC('month', o.order_date)::DATE as order_month,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.net_total) as total_revenue,
        COUNT(DISTINCT o.cust_id) as total_customers,
        COUNT(DISTINCT o.cust_id) FILTER (
            WHERE DATE_TRUNC('month', o.order_date) = DATE_TRUNC('month', cfo.first_order_date)
        ) as new_customers,
        COUNT(DISTINCT o.cust_id) FILTER (
            WHERE DATE_TRUNC('month', o.order_date) > DATE_TRUNC('month', cfo.first_order_date)
        ) as returning_customers
    FROM sales.orders o
    JOIN customer_first_order cfo ON o.cust_id = cfo.cust_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT 
    order_month,
    TO_CHAR(order_month, 'Mon YYYY') as month_name,
    total_orders,
    ROUND(total_revenue::NUMERIC, 2) as total_revenue,
    total_customers,
    new_customers,
    returning_customers,
    ROUND((new_customers::NUMERIC / NULLIF(total_customers, 0) * 100), 2) as new_customer_pct,
    ROUND((returning_customers::NUMERIC / NULLIF(total_customers, 0) * 100), 2) as returning_customer_pct
FROM monthly_breakdown
ORDER BY order_month DESC;

COMMENT ON VIEW analytics.vw_new_vs_returning IS 'New vs returning customer breakdown by month';

\echo '      ✓ View created: vw_new_vs_returning'


-- ============================================================================
-- 🆕 VIEW 5: LOYALTY TIER DISTRIBUTION (NEW in V2)
-- ============================================================================

\echo '[8/10] Creating view: vw_loyalty_tier_distribution...'

CREATE OR REPLACE VIEW analytics.vw_loyalty_tier_distribution AS
SELECT 
    t.tier_name,
    t.min_points,
    t.max_points,
    COUNT(m.customer_id) as member_count,
    ROUND(AVG(m.points_balance)::NUMERIC, 0) as avg_points_balance,
    ROUND(SUM(m.points_balance)::NUMERIC, 0) as total_points_balance,
    ROUND(
        (COUNT(m.customer_id)::NUMERIC / NULLIF(SUM(COUNT(m.customer_id)) OVER (), 0) * 100), 2
    ) as pct_of_members
FROM loyalty.tiers t
LEFT JOIN loyalty.members m ON t.tier_id = m.tier_id
GROUP BY t.tier_id, t.tier_name, t.min_points, t.max_points
ORDER BY t.min_points DESC;

COMMENT ON VIEW analytics.vw_loyalty_tier_distribution IS 'Loyalty program tier distribution and point balances';

\echo '      ✓ View created: vw_loyalty_tier_distribution'


-- ============================================================================
-- 🆕 VIEW 6: LOYALTY REDEMPTION PATTERNS (NEW in V2)
-- ============================================================================

\echo '[9/10] Creating view: vw_loyalty_redemption_patterns...'

CREATE OR REPLACE VIEW analytics.vw_loyalty_redemption_patterns AS
WITH monthly_redemptions AS (
    SELECT 
        DATE_TRUNC('month', r.redemption_date)::DATE as redemption_month,
        COUNT(*) as redemption_count,
        SUM(r.points_redeemed) as total_points_redeemed,
        COUNT(DISTINCT r.customer_id) as unique_redeemers
    FROM loyalty.redemptions r
    GROUP BY DATE_TRUNC('month', r.redemption_date)
),
reward_popularity AS (
    SELECT 
        r.reward_name,
        COUNT(*) as times_redeemed,
        SUM(r.points_redeemed) as total_points,
        COUNT(DISTINCT r.customer_id) as unique_customers,
        RANK() OVER (ORDER BY COUNT(*) DESC) as popularity_rank
    FROM loyalty.redemptions r
    GROUP BY r.reward_name
)
SELECT 
    'monthly' as view_type,
    mr.redemption_month::TEXT as dimension,
    TO_CHAR(mr.redemption_month, 'Mon YYYY') as label,
    mr.redemption_count as count_value,
    mr.total_points_redeemed as points_value,
    mr.unique_redeemers as customer_count,
    NULL::INTEGER as rank_value
FROM monthly_redemptions mr

UNION ALL

SELECT 
    'reward' as view_type,
    rp.reward_name as dimension,
    rp.reward_name as label,
    rp.times_redeemed as count_value,
    rp.total_points as points_value,
    rp.unique_customers as customer_count,
    rp.popularity_rank as rank_value
FROM reward_popularity rp
WHERE rp.popularity_rank <= 15

ORDER BY view_type, dimension DESC;

COMMENT ON VIEW analytics.vw_loyalty_redemption_patterns IS 'Loyalty redemption trends and popular rewards';

\echo '      ✓ View created: vw_loyalty_redemption_patterns'


-- ============================================================================
-- 🆕 VIEW 7: LOYALTY PROGRAM ROI (NEW in V2)
-- ============================================================================

\echo '[10/10] Creating view: vw_loyalty_program_roi...'

CREATE OR REPLACE VIEW analytics.vw_loyalty_program_roi AS
WITH loyalty_member_stats AS (
    -- Revenue from loyalty members vs non-members
    SELECT 
        CASE WHEN lm.customer_id IS NOT NULL THEN 'Loyalty Member' ELSE 'Non-Member' END as segment,
        COUNT(DISTINCT c.customer_id) as customer_count,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.net_total) as total_revenue,
        AVG(o.net_total) as avg_order_value,
        ROUND(
            COUNT(DISTINCT o.order_id)::NUMERIC / NULLIF(COUNT(DISTINCT c.customer_id), 0), 2
        ) as orders_per_customer
    FROM customers.customers c
    LEFT JOIN loyalty.members lm ON c.customer_id = lm.customer_id
    LEFT JOIN sales.orders o ON c.customer_id = o.cust_id AND o.order_status = 'Delivered'
    GROUP BY CASE WHEN lm.customer_id IS NOT NULL THEN 'Loyalty Member' ELSE 'Non-Member' END
),
points_summary AS (
    SELECT 
        SUM(lp.points_earned) as total_points_earned,
        (SELECT SUM(points_redeemed) FROM loyalty.redemptions) as total_points_redeemed,
        (SELECT SUM(points_balance) FROM loyalty.members) as total_points_outstanding
    FROM customers.loyalty_points lp
)
SELECT 
    lms.segment,
    lms.customer_count,
    lms.total_orders,
    ROUND(lms.total_revenue::NUMERIC, 2) as total_revenue,
    ROUND(lms.avg_order_value::NUMERIC, 2) as avg_order_value,
    lms.orders_per_customer,
    ROUND(
        (lms.total_revenue / NULLIF(lms.customer_count, 0))::NUMERIC, 2
    ) as revenue_per_customer,
    ROUND(
        (lms.customer_count::NUMERIC / SUM(lms.customer_count) OVER () * 100), 2
    ) as pct_of_customers,
    ROUND(
        (lms.total_revenue / NULLIF(SUM(lms.total_revenue) OVER (), 0) * 100)::NUMERIC, 2
    ) as pct_of_revenue
FROM loyalty_member_stats lms
ORDER BY total_revenue DESC;

COMMENT ON VIEW analytics.vw_loyalty_program_roi IS 'Loyalty member vs non-member performance comparison';

\echo '      ✓ View created: vw_loyalty_program_roi'


-- ============================================================================
-- JSON EXPORT FUNCTIONS
-- ============================================================================

\echo ''
\echo 'Creating JSON export functions...'

-- JSON 1: Top Customers (Top 50 by CLV)
CREATE OR REPLACE FUNCTION analytics.get_top_customers_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'customerId', customer_id,
                'fullName', full_name,
                'city', city,
                'state', state,
                'clvTier', clv_tier,
                'totalOrders', total_orders,
                'totalRevenue', total_revenue,
                'avgOrderValue', avg_order_value,
                'daysSinceLastOrder', days_since_last_order,
                'customerStatus', customer_status,
                'loyaltyPoints', loyalty_points
            ) ORDER BY total_revenue DESC
        )
        FROM analytics.mv_customer_lifetime_value
        WHERE total_orders > 0
        LIMIT 50
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 2: CLV Tier Distribution
CREATE OR REPLACE FUNCTION analytics.get_clv_tier_distribution_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'tier', clv_tier,
                'customerCount', customer_count,
                'totalRevenue', total_revenue,
                'avgRevenue', avg_revenue,
                'pctOfCustomers', pct_of_customers,
                'pctOfRevenue', pct_of_revenue
            ) ORDER BY 
                CASE clv_tier WHEN 'Platinum' THEN 1 WHEN 'Gold' THEN 2 WHEN 'Silver' THEN 3 WHEN 'Bronze' THEN 4 ELSE 5 END
        )
        FROM (
            SELECT 
                clv_tier,
                COUNT(*) as customer_count,
                ROUND(SUM(total_revenue)::NUMERIC, 2) as total_revenue,
                ROUND(AVG(total_revenue)::NUMERIC, 2) as avg_revenue,
                ROUND((COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100), 2) as pct_of_customers,
                ROUND((SUM(total_revenue) / SUM(SUM(total_revenue)) OVER () * 100)::NUMERIC, 2) as pct_of_revenue
            FROM analytics.mv_customer_lifetime_value
            WHERE total_orders > 0
            GROUP BY clv_tier
        ) tier_stats
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 3: RFM Segments
CREATE OR REPLACE FUNCTION analytics.get_rfm_segments_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'segment', rfm_segment,
                'customerCount', customer_count,
                'totalRevenue', total_revenue,
                'avgRecencyDays', avg_recency,
                'avgFrequency', avg_frequency,
                'avgMonetary', avg_monetary,
                'recommendedAction', recommended_action
            ) ORDER BY total_revenue DESC
        )
        FROM (
            SELECT 
                rfm_segment,
                COUNT(*) as customer_count,
                ROUND(SUM(total_spent)::NUMERIC, 2) as total_revenue,
                ROUND(AVG(recency_days)::NUMERIC, 0) as avg_recency,
                ROUND(AVG(order_count)::NUMERIC, 1) as avg_frequency,
                ROUND(AVG(total_spent)::NUMERIC, 2) as avg_monetary,
                MAX(recommended_action) as recommended_action
            FROM analytics.mv_rfm_analysis
            GROUP BY rfm_segment
        ) segment_stats
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 4: Churn Risk
CREATE OR REPLACE FUNCTION analytics.get_churn_risk_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'distribution', (
                SELECT json_agg(
                    json_build_object(
                        'riskLevel', churn_risk_level,
                        'customerCount', customer_count,
                        'totalValue', total_value,
                        'avgDaysInactive', avg_days_inactive,
                        'pctOfCustomers', pct_of_customers
                    ) ORDER BY 
                        CASE churn_risk_level WHEN 'Churned' THEN 1 WHEN 'High Risk' THEN 2 WHEN 'Medium Risk' THEN 3 WHEN 'Low Risk' THEN 4 ELSE 5 END
                )
                FROM (
                    SELECT 
                        churn_risk_level,
                        COUNT(*) as customer_count,
                        ROUND(SUM(total_spent)::NUMERIC, 2) as total_value,
                        ROUND(AVG(days_inactive)::NUMERIC, 0) as avg_days_inactive,
                        ROUND((COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100), 2) as pct_of_customers
                    FROM analytics.vw_churn_risk_customers
                    GROUP BY churn_risk_level
                ) dist
            ),
            'highPriorityCustomers', (
                SELECT json_agg(
                    json_build_object(
                        'customerId', customer_id,
                        'fullName', full_name,
                        'clvTier', clv_tier,
                        'totalSpent', total_spent,
                        'daysInactive', days_inactive,
                        'recommendedAction', recommended_action
                    ) ORDER BY priority_score DESC
                )
                FROM analytics.vw_churn_risk_customers
                WHERE priority_score >= 7
                LIMIT 20
            )
        )
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 5: Registration Trends (V2 — replaces demographics)
CREATE OR REPLACE FUNCTION analytics.get_registration_trends_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'month', signup_month,
                'monthName', month_name,
                'newSignups', new_signups,
                'cumulative', cumulative_customers,
                'momGrowth', mom_growth_pct,
                'movingAvg3M', moving_avg_3month
            ) ORDER BY signup_month DESC
        )
        FROM analytics.vw_customer_registration_trends
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 6: Geography (Top 50)
CREATE OR REPLACE FUNCTION analytics.get_geography_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'state', state,
                'city', city,
                'customerCount', customer_count,
                'totalOrders', total_orders,
                'totalRevenue', total_revenue,
                'avgOrderValue', avg_order_value,
                'revenuePerCustomer', revenue_per_customer,
                'rank', revenue_rank
            ) ORDER BY revenue_rank
        )
        FROM analytics.vw_customer_geography
        LIMIT 50
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- JSON 7: Loyalty Overview (NEW in V2)
CREATE OR REPLACE FUNCTION analytics.get_loyalty_overview_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'tierDistribution', (
                SELECT json_agg(
                    json_build_object(
                        'tier', tier_name,
                        'members', member_count,
                        'avgBalance', avg_points_balance,
                        'pctOfMembers', pct_of_members
                    ) ORDER BY min_points DESC
                )
                FROM analytics.vw_loyalty_tier_distribution
            ),
            'memberVsNonMember', (
                SELECT json_agg(
                    json_build_object(
                        'segment', segment,
                        'customers', customer_count,
                        'revenue', total_revenue,
                        'avgOrderValue', avg_order_value,
                        'ordersPerCustomer', orders_per_customer,
                        'pctOfRevenue', pct_of_revenue
                    )
                )
                FROM analytics.vw_loyalty_program_roi
            )
        )
    );
END;
$$ LANGUAGE plpgsql STABLE;

\echo '      ✓ JSON functions created (7 functions)'


-- ============================================================================
-- REFRESH MATERIALIZED VIEWS
-- ============================================================================

\echo ''
\echo 'Refreshing materialized views...'

REFRESH MATERIALIZED VIEW analytics.mv_customer_lifetime_value;
REFRESH MATERIALIZED VIEW analytics.mv_rfm_analysis;
REFRESH MATERIALIZED VIEW analytics.mv_cohort_retention;

\echo '✓ Materialized views refreshed'


-- ============================================================================
-- VERIFICATION
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '          CUSTOMER ANALYTICS MODULE (V2) — COMPLETE                         '
\echo '============================================================================'
\echo ''
\echo '✅ Regular Views (7):'
\echo '   • vw_churn_risk_customers        — At-risk customers prioritized'
\echo '   • vw_customer_registration_trends — Signup trends (replaces demographics)'
\echo '   • vw_customer_geography           — Location distribution'
\echo '   • vw_new_vs_returning             — Acquisition vs retention'
\echo '   • vw_loyalty_tier_distribution    — Loyalty tiers 🆕'
\echo '   • vw_loyalty_redemption_patterns  — Redemption trends 🆕'
\echo '   • vw_loyalty_program_roi          — Member vs non-member 🆕'
\echo ''
\echo '✅ Materialized Views (3):'
\echo '   • mv_customer_lifetime_value  — CLV with tiers'
\echo '   • mv_rfm_analysis             — RFM segmentation'
\echo '   • mv_cohort_retention          — Cohort retention rates'
\echo ''
\echo '✅ JSON Functions (7):'
\echo '   • get_top_customers_json()'
\echo '   • get_clv_tier_distribution_json()'
\echo '   • get_rfm_segments_json()'
\echo '   • get_churn_risk_json()'
\echo '   • get_registration_trends_json()  (V2 — replaces demographics)'
\echo '   • get_geography_json()'
\echo '   • get_loyalty_overview_json()     🆕'
\echo ''
\echo '➡️  Next: Run 03_product_analytics.sql'
\echo '============================================================================'
\echo ''

SELECT 
    clv_tier,
    COUNT(*) as customers,
    ROUND(SUM(total_revenue)::NUMERIC, 2) as total_revenue,
    ROUND(AVG(total_revenue)::NUMERIC, 2) as avg_revenue
FROM analytics.mv_customer_lifetime_value
WHERE total_orders > 0
GROUP BY clv_tier
ORDER BY avg_revenue DESC;