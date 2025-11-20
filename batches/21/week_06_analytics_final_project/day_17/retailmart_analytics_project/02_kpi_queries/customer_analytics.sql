-- ============================================================================
-- FILE: 02_kpi_queries/customer_analytics.sql
-- PURPOSE: Customer Analytics Module - Complete customer behavior tracking
-- AUTHOR: RetailMart Analytics Team
-- CREATED: 2024
-- DESCRIPTION: 
--   - Customer Lifetime Value (CLV) analysis
--   - RFM Segmentation (Recency, Frequency, Monetary)
--   - Cohort retention tracking
--   - Churn prediction and risk assessment
--   - Demographic and geographic analysis
--   - JSON export functions for dashboard integration
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                  CUSTOMER ANALYTICS MODULE - STARTING                      '
\echo '============================================================================'
\echo ''
\echo 'This module creates:'
\echo '  - 3 Regular Views (churn risk, demographics, geography)'
\echo '  - 3 Materialized Views (CLV, RFM, cohort retention)'
\echo '  - 6 JSON Export Functions (for dashboard integration)'
\echo ''

-- ============================================================================
-- 1. CUSTOMER LIFETIME VALUE (CLV) ANALYSIS - MATERIALIZED VIEW
-- ============================================================================
-- PURPOSE: Calculate comprehensive customer value metrics and segmentation
-- REFRESH: Manual (call REFRESH MATERIALIZED VIEW or use refresh function)
-- USAGE: SELECT * FROM analytics.mv_customer_lifetime_value WHERE clv_tier = 'Platinum';
-- ============================================================================

\echo '[1/6] Creating materialized view: mv_customer_lifetime_value...'
\echo '      - Calculates customer lifetime value and tier classification'
\echo '      - Tracks purchase history and loyalty metrics'
\echo '      - Identifies customer status (Active, At Risk, Churned)'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_customer_lifetime_value CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_customer_lifetime_value AS
WITH customer_transactions AS (
    -- Step 1: Aggregate all customer transaction history
    SELECT 
        c.cust_id,
        c.full_name,
        c.gender,
        c.age,
        c.city,
        c.state,
        c.join_date,                                                -- Customer registration date
        
        -- Purchase Timeline
        MIN(o.order_date) as first_purchase_date,                   -- Date of first purchase
        MAX(o.order_date) as last_purchase_date,                    -- Date of most recent purchase
        
        -- Purchase Metrics
        COUNT(DISTINCT o.order_id) as total_orders,                 -- Total number of orders
        SUM(o.total_amount) as total_revenue,                       -- Lifetime revenue from customer
        AVG(o.total_amount) as avg_order_value,                     -- Average order size
        SUM(oi.quantity) as total_items_purchased,                  -- Total items bought
        
        -- Engagement Metrics
        CURRENT_DATE - MAX(o.order_date) as days_since_last_purchase,  -- Days since last order (Recency)
        MAX(o.order_date) - MIN(o.order_date) as customer_lifespan_days  -- Total days as customer
    FROM customers.customers c
    LEFT JOIN sales.orders o ON c.cust_id = o.cust_id AND o.order_status = 'Delivered'
    LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY c.cust_id, c.full_name, c.gender, c.age, c.city, c.state, c.join_date
),
customer_loyalty AS (
    -- Step 2: Get loyalty program data
    SELECT 
        cust_id,
        total_points,                                               -- Accumulated loyalty points
        last_updated as loyalty_last_updated
    FROM customers.loyalty_points
),
customer_reviews AS (
    -- Step 3: Get customer review activity
    SELECT 
        cust_id,
        COUNT(*) as review_count,                                   -- Number of reviews written
        ROUND(AVG(rating), 2) as avg_rating_given                   -- Average rating given by customer
    FROM customers.reviews
    GROUP BY cust_id
)
-- Final Select: Combine all customer metrics
SELECT 
    ct.*,
    
    -- Loyalty and Engagement Data
    COALESCE(cl.total_points, 0) as loyalty_points,
    COALESCE(cr.review_count, 0) as review_count,
    COALESCE(cr.avg_rating_given, 0) as avg_rating_given,
    
    -- Calculated Metrics
    -- Projected Annual Value: (Total Revenue / Days as Customer) * 365
    ROUND(ct.total_revenue / NULLIF(GREATEST(ct.customer_lifespan_days, 1), 0) * 365, 2) as projected_annual_value,
    
    -- Average Orders Per Month
    ROUND(ct.total_orders::NUMERIC / NULLIF(GREATEST(ct.customer_lifespan_days, 1), 0) * 30, 2) as avg_orders_per_month,
    
    -- Customer Lifetime Value (CLV) Tier Classification
    CASE 
        WHEN ct.total_revenue >= 15000 THEN 'Platinum'              -- Top tier: $15k+ lifetime value
        WHEN ct.total_revenue >= 8000 THEN 'Gold'                   -- High tier: $8k-$15k
        WHEN ct.total_revenue >= 3000 THEN 'Silver'                 -- Medium tier: $3k-$8k
        WHEN ct.total_revenue >= 1000 THEN 'Bronze'                 -- Entry tier: $1k-$3k
        ELSE 'Basic'                                                 -- Basic tier: <$1k
    END as clv_tier,
    
    -- Customer Status Classification (based on recency)
    CASE 
        WHEN ct.days_since_last_purchase IS NULL THEN 'No Purchases'  -- Never purchased
        WHEN ct.days_since_last_purchase <= 30 THEN 'Active'          -- Purchased within 30 days
        WHEN ct.days_since_last_purchase <= 90 THEN 'At Risk'         -- 30-90 days since purchase
        WHEN ct.days_since_last_purchase <= 180 THEN 'Churning'       -- 90-180 days since purchase
        ELSE 'Churned'                                                 -- >180 days since purchase
    END as customer_status
FROM customer_transactions ct
LEFT JOIN customer_loyalty cl ON ct.cust_id = cl.cust_id
LEFT JOIN customer_reviews cr ON ct.cust_id = cr.cust_id;

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_clv_tier 
ON analytics.mv_customer_lifetime_value(clv_tier);

CREATE INDEX IF NOT EXISTS idx_customer_status 
ON analytics.mv_customer_lifetime_value(customer_status);

\echo '      ✓ Materialized view created: mv_customer_lifetime_value'
\echo '      ✓ Indexes created on (clv_tier, customer_status)'
\echo ''


-- ============================================================================
-- 2. RFM ANALYSIS (RECENCY, FREQUENCY, MONETARY) - MATERIALIZED VIEW
-- ============================================================================
-- PURPOSE: Segment customers using RFM methodology for targeted marketing
-- REFRESH: Manual
-- USAGE: SELECT * FROM analytics.mv_rfm_analysis WHERE rfm_segment = 'Champions';
-- NOTES: RFM scores range from 1-5, with 5 being best
-- ============================================================================

\echo '[2/6] Creating materialized view: mv_rfm_analysis...'
\echo '      - Calculates RFM scores (Recency, Frequency, Monetary)'
\echo '      - Segments customers into behavioral groups'
\echo '      - Provides recommended marketing actions'

-- Drop the broken view if it exists
DROP MATERIALIZED VIEW IF EXISTS analytics.mv_rfm_analysis CASCADE;

-- Create the corrected RFM Analysis view
CREATE MATERIALIZED VIEW analytics.mv_rfm_analysis AS
WITH customer_metrics AS (
    SELECT 
        c.cust_id,
        c.full_name,
        c.city,
        c.state,
        CURRENT_DATE - MAX(o.order_date) as days_since_last_order,
        COUNT(DISTINCT o.order_id) as frequency,
        SUM(o.total_amount) as monetary
    FROM customers.customers c
    LEFT JOIN sales.orders o ON c.cust_id = o.cust_id 
        AND o.order_status = 'Delivered'
    GROUP BY c.cust_id, c.full_name, c.city, c.state
),
rfm_scores AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY days_since_last_order DESC) as r_score_raw,
        NTILE(5) OVER (ORDER BY frequency) as f_score,
        NTILE(5) OVER (ORDER BY monetary) as m_score
    FROM customer_metrics
)
SELECT 
    cust_id,
    full_name,
    city,
    state,
    days_since_last_order as recency_days,
    frequency as order_count,
    ROUND(monetary, 2) as total_spent,
    (6 - r_score_raw) as recency_score,
    f_score as frequency_score,
    m_score as monetary_score,
    -- FIX: Cast integers to TEXT before concatenation
    (6 - r_score_raw)::TEXT || f_score::TEXT || m_score::TEXT as rfm_score,
    CASE 
        WHEN (6 - r_score_raw) >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN (6 - r_score_raw) >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN (6 - r_score_raw) >= 4 AND f_score <= 2 THEN 'New Customers'
        WHEN (6 - r_score_raw) >= 3 AND f_score <= 3 AND m_score <= 3 THEN 'Potential Loyalists'
        WHEN (6 - r_score_raw) <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN (6 - r_score_raw) <= 2 AND f_score <= 2 THEN 'Lost Customers'
        WHEN m_score >= 4 AND f_score <= 2 THEN 'Big Spenders'
        ELSE 'Need Attention'
    END as rfm_segment,
    CASE 
        WHEN (6 - r_score_raw) >= 4 AND f_score >= 4 THEN 'Reward with VIP offers'
        WHEN (6 - r_score_raw) <= 2 AND f_score >= 3 THEN 'Send win-back campaign'
        WHEN (6 - r_score_raw) <= 2 AND f_score <= 2 THEN 'Consider re-engagement'
        WHEN (6 - r_score_raw) >= 4 AND f_score <= 2 THEN 'Nurture with engagement'
        ELSE 'Monitor and engage'
    END as recommended_action
FROM rfm_scores;

-- Create index
CREATE INDEX IF NOT EXISTS idx_rfm_segment 
ON analytics.mv_rfm_analysis(rfm_segment);

-- Refresh the view
REFRESH MATERIALIZED VIEW analytics.mv_rfm_analysis;

\echo '      ✓ Materialized view created: mv_rfm_analysis'
\echo '      ✓ Index created on (rfm_segment)'
\echo ''


-- ============================================================================
-- 3. COHORT RETENTION ANALYSIS - MATERIALIZED VIEW
-- ============================================================================
-- PURPOSE: Track customer retention by acquisition cohort (month-over-month)
-- REFRESH: Manual
-- USAGE: SELECT * FROM analytics.mv_cohort_retention WHERE cohort = '2024-01';
-- NOTES: Tracks retention up to 12 months after acquisition
-- ============================================================================

\echo '[3/6] Creating materialized view: mv_cohort_retention...'
\echo '      - Groups customers by first purchase month (cohort)'
\echo '      - Tracks retention rate for each cohort over 12 months'
\echo '      - Shows how many customers remain active each month'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_cohort_retention CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_cohort_retention AS
WITH customer_cohorts AS (
    -- Step 1: Identify each customer's cohort (first purchase month)
    SELECT 
        cust_id,
        DATE_TRUNC('month', MIN(order_date))::DATE as cohort_month    -- First purchase month
    FROM sales.orders
    WHERE order_status = 'Delivered'
    GROUP BY cust_id
),
customer_activities AS (
    -- Step 2: Get all activity months for each customer
    SELECT DISTINCT
        o.cust_id,
        cc.cohort_month,                                              -- Customer's cohort
        DATE_TRUNC('month', o.order_date)::DATE as activity_month     -- Month of activity
    FROM sales.orders o
    JOIN customer_cohorts cc ON o.cust_id = cc.cust_id
    WHERE o.order_status = 'Delivered'
),
cohort_data AS (
    -- Step 3: Calculate months since cohort and count active customers
    SELECT 
        cohort_month,
        activity_month,
        -- Calculate how many months after cohort month this activity occurred
        EXTRACT(YEAR FROM AGE(activity_month, cohort_month)) * 12 + 
        EXTRACT(MONTH FROM AGE(activity_month, cohort_month)) as months_since_cohort,
        COUNT(DISTINCT cust_id) as active_customers                   -- Customers active in this month
    FROM customer_activities
    GROUP BY cohort_month, activity_month
),
cohort_sizes AS (
    -- Step 4: Get initial cohort size (month 0)
    SELECT 
        cohort_month,
        active_customers as cohort_size                               -- Starting size of cohort
    FROM cohort_data
    WHERE months_since_cohort = 0                                     -- First month
)
-- Final Select: Calculate retention rates
SELECT 
    cd.cohort_month,
    TO_CHAR(cd.cohort_month, 'YYYY-MM') as cohort,                   -- Display format (e.g., "2024-01")
    cd.months_since_cohort as month_number,                           -- 0 = first month, 1 = second month, etc.
    cs.cohort_size as initial_size,                                   -- Starting cohort size
    cd.active_customers as retained_customers,                        -- Customers still active
    
    -- Retention Rate = (Active Customers / Initial Size) * 100
    ROUND(100.0 * cd.active_customers / cs.cohort_size, 2) as retention_rate
FROM cohort_data cd
JOIN cohort_sizes cs ON cd.cohort_month = cs.cohort_month
WHERE cd.months_since_cohort <= 12                                    -- Track up to 12 months
ORDER BY cd.cohort_month DESC, cd.months_since_cohort;

\echo '      ✓ Materialized view created: mv_cohort_retention'
\echo ''


-- ============================================================================
-- 4. CHURN PREDICTION AND RISK ASSESSMENT - VIEW
-- ============================================================================
-- PURPOSE: Identify customers at risk of churning based on purchase patterns
-- UPDATES: Real-time (view refreshes on query)
-- USAGE: SELECT * FROM analytics.vw_churn_risk_customers WHERE churn_risk_level = 'High Risk';
-- ============================================================================

\echo '[4/6] Creating view: vw_churn_risk_customers...'
\echo '      - Identifies customers at risk of churning'
\echo '      - Calculates expected purchase frequency'
\echo '      - Prioritizes intervention by customer value'

CREATE OR REPLACE VIEW analytics.vw_churn_risk_customers AS
WITH customer_metrics AS (
    -- Step 1: Calculate customer purchase patterns
    SELECT 
        c.cust_id,
        c.full_name,
        c.city,
        c.state,
        c.join_date,
        
        -- Purchase History
        MAX(o.order_date) as last_order_date,                         -- Most recent order
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_spent,
        ROUND(AVG(o.total_amount), 2) as avg_order_value,
        
        -- Inactivity Metric
        CURRENT_DATE - MAX(o.order_date) as days_inactive,           -- Days since last purchase
        
        -- Expected Purchase Frequency
        -- Formula: (Last Order Date - First Order Date) / (Number of Orders - 1)
        ROUND(
            (MAX(o.order_date) - MIN(o.order_date))::NUMERIC / 
            NULLIF(COUNT(DISTINCT o.order_id) - 1, 0),               -- Avoid division by zero
            0
        ) as avg_days_between_orders                                  -- Expected days between purchases
    FROM customers.customers c
    LEFT JOIN sales.orders o ON c.cust_id = o.cust_id AND o.order_status = 'Delivered'
    GROUP BY c.cust_id, c.full_name, c.city, c.state, c.join_date
)
SELECT 
    cust_id,
    full_name,
    city,
    state,
    last_order_date,
    total_orders,
    ROUND(total_spent, 2) as total_spent,
    avg_order_value,
    days_inactive,
    avg_days_between_orders,
    
    -- Churn Risk Level Classification
    CASE 
        WHEN days_inactive IS NULL THEN 'Never Purchased'                                        -- No purchase history
        WHEN days_inactive > (avg_days_between_orders * 3) AND total_spent > 5000 
            THEN 'Critical - High Value'                                                          -- High-value customer at extreme risk
        WHEN days_inactive > (avg_days_between_orders * 3) THEN 'High Risk'                     -- 3x expected frequency = high risk
        WHEN days_inactive > (avg_days_between_orders * 2) THEN 'Medium Risk'                   -- 2x expected frequency = medium risk
        WHEN days_inactive > (avg_days_between_orders * 1.5) THEN 'Low Risk'                    -- 1.5x expected frequency = low risk
        ELSE 'Active'                                                                             -- Within normal purchase cycle
    END as churn_risk_level,
    
    -- Recommended Action Based on Risk
    CASE 
        WHEN days_inactive IS NULL THEN 'Welcome campaign'
        WHEN days_inactive > (avg_days_between_orders * 3) AND total_spent > 5000 
            THEN 'Immediate personal outreach'                                                    -- VIP treatment for high-value at-risk
        WHEN days_inactive > (avg_days_between_orders * 3) THEN 'Win-back email campaign'       -- Standard win-back
        WHEN days_inactive > (avg_days_between_orders * 2) THEN 'Engagement campaign with discount'
        WHEN days_inactive > (avg_days_between_orders * 1.5) THEN 'Reminder email'
        ELSE 'Standard marketing'
    END as recommended_action,
    
    -- Priority Score (1-10, higher = more urgent)
    CASE 
        WHEN days_inactive IS NULL THEN 3
        WHEN days_inactive > (avg_days_between_orders * 3) AND total_spent > 5000 THEN 10      -- Highest priority
        WHEN days_inactive > (avg_days_between_orders * 3) THEN 8
        WHEN days_inactive > (avg_days_between_orders * 2) THEN 6
        WHEN days_inactive > (avg_days_between_orders * 1.5) THEN 4
        ELSE 1
    END as priority_score
FROM customer_metrics
WHERE days_inactive > 30 OR days_inactive IS NULL                     -- Focus on inactive customers
ORDER BY priority_score DESC, total_spent DESC;                        -- Prioritize by urgency and value

\echo '      ✓ View created: vw_churn_risk_customers'
\echo ''


-- ============================================================================
-- 5. CUSTOMER DEMOGRAPHICS ANALYSIS - VIEW
-- ============================================================================
-- PURPOSE: Analyze customer base by age group and gender
-- UPDATES: Real-time (view refreshes on query)
-- USAGE: SELECT * FROM analytics.vw_customer_demographics ORDER BY total_revenue DESC;
-- ============================================================================

\echo '[5/6] Creating view: vw_customer_demographics...'
\echo '      - Breaks down customer base by age group and gender'
\echo '      - Shows revenue contribution by demographic segment'
\echo '      - Identifies most valuable demographic groups'

CREATE OR REPLACE VIEW analytics.vw_customer_demographics AS
WITH customer_stats AS (
    -- Step 1: Calculate metrics for each customer
    SELECT 
        c.cust_id,
        c.gender,
        c.age,
        c.city,
        c.state,
        
        -- Age Group Classification
        CASE 
            WHEN c.age < 25 THEN '18-24'
            WHEN c.age < 35 THEN '25-34'
            WHEN c.age < 45 THEN '35-44'
            WHEN c.age < 55 THEN '45-54'
            WHEN c.age < 65 THEN '55-64'
            ELSE '65+'
        END as age_group,
        
        -- Purchase Metrics
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_spent
    FROM customers.customers c
    LEFT JOIN sales.orders o ON c.cust_id = o.cust_id AND o.order_status = 'Delivered'
    GROUP BY c.cust_id, c.gender, c.age, c.city, c.state
)
-- Step 2: Aggregate by demographic segment
SELECT 
    age_group,
    gender,
    
    -- Customer Metrics
    COUNT(DISTINCT cust_id) as customer_count,                        -- Customers in this segment
    SUM(total_orders) as total_orders,                                -- Total orders from segment
    ROUND(AVG(total_orders), 2) as avg_orders_per_customer,          -- Average orders per customer
    
    -- Revenue Metrics
    ROUND(SUM(total_spent), 2) as total_revenue,                     -- Total revenue from segment
    ROUND(AVG(total_spent), 2) as avg_revenue_per_customer,          -- Average customer value
    
    -- Distribution Percentages
    ROUND(100.0 * COUNT(DISTINCT cust_id) / SUM(COUNT(DISTINCT cust_id)) OVER (), 2) as pct_of_customers,  -- % of customer base
    ROUND(100.0 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 2) as pct_of_revenue                    -- % of total revenue
FROM customer_stats
WHERE total_orders > 0                                                -- Only customers who have purchased
GROUP BY age_group, gender
ORDER BY 
    -- Sort age groups in order
    CASE age_group
        WHEN '18-24' THEN 1
        WHEN '25-34' THEN 2
        WHEN '35-44' THEN 3
        WHEN '45-54' THEN 4
        WHEN '55-64' THEN 5
        ELSE 6
    END,
    gender;

\echo '      ✓ View created: vw_customer_demographics'
\echo ''


-- ============================================================================
-- 6. CUSTOMER GEOGRAPHY ANALYSIS - VIEW
-- ============================================================================
-- PURPOSE: Analyze customer distribution and revenue by location
-- UPDATES: Real-time (view refreshes on query)
-- USAGE: SELECT * FROM analytics.vw_customer_geography WHERE state = 'CA';
-- ============================================================================

\echo '[6/6] Creating view: vw_customer_geography...'
\echo '      - Shows customer distribution by city and state'
\echo '      - Identifies high-value geographic markets'
\echo '      - Ranks locations by revenue potential'

CREATE OR REPLACE VIEW analytics.vw_customer_geography AS
SELECT 
    c.state,
    c.city,
    
    -- Customer Metrics
    COUNT(DISTINCT c.cust_id) as customer_count,                     -- Customers in this location
    COUNT(DISTINCT o.order_id) as total_orders,                      -- Orders from this location
    
    -- Revenue Metrics
    ROUND(SUM(o.total_amount), 2) as total_revenue,                  -- Total revenue from location
    ROUND(AVG(o.total_amount), 2) as avg_order_value,                -- Average order size
    ROUND(SUM(o.total_amount) / NULLIF(COUNT(DISTINCT c.cust_id), 0), 2) as revenue_per_customer,  -- Customer lifetime value by location
    
    -- Ranking
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as revenue_rank  -- Rank locations by revenue
FROM customers.customers c
LEFT JOIN sales.orders o ON c.cust_id = o.cust_id AND o.order_status = 'Delivered'
GROUP BY c.state, c.city
HAVING COUNT(DISTINCT o.order_id) > 0                                -- Only locations with orders
ORDER BY total_revenue DESC;

\echo '      ✓ View created: vw_customer_geography'
\echo ''


-- ============================================================================
-- REFRESH MATERIALIZED VIEWS
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '                    REFRESHING MATERIALIZED VIEWS                           '
\echo '============================================================================'
\echo ''

\echo 'Refreshing mv_customer_lifetime_value...'
REFRESH MATERIALIZED VIEW analytics.mv_customer_lifetime_value;
\echo '✓ Refreshed: mv_customer_lifetime_value'

\echo 'Refreshing mv_rfm_analysis...'
REFRESH MATERIALIZED VIEW analytics.mv_rfm_analysis;
\echo '✓ Refreshed: mv_rfm_analysis'

\echo 'Refreshing mv_cohort_retention...'
REFRESH MATERIALIZED VIEW analytics.mv_cohort_retention;
\echo '✓ Refreshed: mv_cohort_retention'

\echo ''


-- ============================================================================
-- JSON EXPORT FUNCTIONS FOR DASHBOARD INTEGRATION
-- ============================================================================
-- PURPOSE: Provide JSON endpoints for dashboard to consume data
-- USAGE: SELECT analytics.get_clv_analysis_json();
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                    CREATING JSON EXPORT FUNCTIONS                          '
\echo '============================================================================'
\echo ''
\echo 'These functions return JSON data for dashboard visualization:'
\echo '  - Top 50 customers by CLV'
\echo '  - CLV tier distribution'
\echo '  - RFM segment breakdown'
\echo '  - Churn risk summary'
\echo '  - Demographic analysis'
\echo '  - Geographic distribution'
\echo ''

-- ----------------------------------------------------------------------------
-- JSON Function 1: Top Customers by CLV
-- ----------------------------------------------------------------------------
\echo '[JSON 1/6] Creating function: get_top_customers_json()'
\echo '           - Returns top 50 customers by lifetime value'

CREATE OR REPLACE FUNCTION analytics.get_top_customers_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'custId', cust_id,
                'fullName', full_name,
                'city', city,
                'state', state,
                'totalOrders', total_orders,
                'totalRevenue', total_revenue,
                'avgOrderValue', avg_order_value,
                'clvTier', clv_tier,
                'customerStatus', customer_status,
                'daysSinceLastPurchase', days_since_last_purchase,
                'loyaltyPoints', loyalty_points,
                'projectedAnnualValue', projected_annual_value
            ) ORDER BY total_revenue DESC
        )
        FROM analytics.mv_customer_lifetime_value
        WHERE total_orders > 0
        LIMIT 50
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_top_customers_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 2: CLV Tier Distribution
-- ----------------------------------------------------------------------------
\echo '[JSON 2/6] Creating function: get_clv_tier_distribution_json()'
\echo '           - Returns customer count and revenue by CLV tier'

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
                CASE clv_tier
                    WHEN 'Platinum' THEN 1
                    WHEN 'Gold' THEN 2
                    WHEN 'Silver' THEN 3
                    WHEN 'Bronze' THEN 4
                    ELSE 5
                END
        )
        FROM (
            SELECT 
                clv_tier,
                COUNT(*) as customer_count,
                ROUND(SUM(total_revenue), 2) as total_revenue,
                ROUND(AVG(total_revenue), 2) as avg_revenue,
                ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as pct_of_customers,
                ROUND(100.0 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER (), 2) as pct_of_revenue
            FROM analytics.mv_customer_lifetime_value
            WHERE total_orders > 0
            GROUP BY clv_tier
        ) clv
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_clv_tier_distribution_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 3: RFM Segment Analysis
-- ----------------------------------------------------------------------------
\echo '[JSON 3/6] Creating function: get_rfm_segments_json()'
\echo '           - Returns customer breakdown by RFM segment'

-- Drop and recreate with correct column names
DROP FUNCTION IF EXISTS analytics.get_rfm_segments_json() CASCADE;

CREATE OR REPLACE FUNCTION analytics.get_rfm_segments_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'segment', rfm_segment,
                'customerCount', customer_count,
                'totalRevenue', total_revenue,
                'avgRecencyDays', avg_recency_days,
                'avgFrequency', avg_frequency,
                'avgMonetary', avg_monetary,
                'recommendedAction', recommended_action
            ) ORDER BY customer_count DESC
        )
        FROM (
            SELECT 
                rfm_segment,
                COUNT(*) as customer_count,
                ROUND(SUM(total_spent), 2) as total_revenue,           -- ✅ FIXED: total_spent not monetary
                ROUND(AVG(recency_days), 0) as avg_recency_days,       -- ✅ CORRECT
                ROUND(AVG(order_count), 1) as avg_frequency,           -- ✅ CORRECT
                ROUND(AVG(total_spent), 2) as avg_monetary,            -- ✅ FIXED: total_spent not monetary
                MAX(recommended_action) as recommended_action
            FROM analytics.mv_rfm_analysis
            GROUP BY rfm_segment
        ) segments
    );
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION analytics.get_rfm_segments_json() TO PUBLIC;


\echo '           ✓ Function created: get_rfm_segments_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 4: Churn Risk Distribution
-- ----------------------------------------------------------------------------
\echo '[JSON 4/6] Creating function: get_churn_risk_json()'
\echo '           - Returns churn risk distribution and high-priority customers'

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
                    ) ORDER BY priority_order
                )
                FROM (
                    SELECT 
                        churn_risk_level,
                        COUNT(*) as customer_count,
                        ROUND(SUM(total_spent), 2) as total_value,
                        ROUND(AVG(days_inactive), 0) as avg_days_inactive,
                        ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as pct_of_customers,
                        MAX(priority_score) as priority_order
                    FROM analytics.vw_churn_risk_customers
                    GROUP BY churn_risk_level
                ) dist
            ),
            'highPriorityCustomers', (
                SELECT json_agg(
                    json_build_object(
                        'custId', cust_id,
                        'fullName', full_name,
                        'riskLevel', churn_risk_level,
                        'totalSpent', total_spent,
                        'daysInactive', days_inactive,
                        'recommendedAction', recommended_action
                    ) ORDER BY priority_score DESC
                )
                FROM analytics.vw_churn_risk_customers
                WHERE priority_score >= 8
                LIMIT 20
            )
        )
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_churn_risk_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 5: Customer Demographics
-- ----------------------------------------------------------------------------
\echo '[JSON 5/6] Creating function: get_demographics_json()'
\echo '           - Returns customer breakdown by age and gender'

CREATE OR REPLACE FUNCTION analytics.get_demographics_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'ageGroup', age_group,
                'gender', gender,
                'customerCount', customer_count,
                'totalRevenue', total_revenue,
                'avgRevenuePerCustomer', avg_revenue_per_customer,
                'pctOfCustomers', pct_of_customers,
                'pctOfRevenue', pct_of_revenue
            ) ORDER BY total_revenue DESC
        )
        FROM analytics.vw_customer_demographics
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_demographics_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 6: Geographic Distribution (Top 50 Locations)
-- ----------------------------------------------------------------------------
\echo '[JSON 6/6] Creating function: get_geography_json()'
\echo '           - Returns top 50 locations by revenue'

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
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_geography_json()'
\echo ''


-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '            CUSTOMER ANALYTICS MODULE - SUCCESSFULLY CREATED                '
\echo '============================================================================'
\echo ''
\echo '✅ REGULAR VIEWS (3):'
\echo '   1. vw_churn_risk_customers        - Churn prediction and prioritization'
\echo '   2. vw_customer_demographics       - Age/gender analysis'
\echo '   3. vw_customer_geography          - Location-based analysis'
\echo ''
\echo '✅ MATERIALIZED VIEWS (3):'
\echo '   1. mv_customer_lifetime_value     - CLV analysis and tiers'
\echo '   2. mv_rfm_analysis                - RFM segmentation'
\echo '   3. mv_cohort_retention            - Cohort retention tracking'
\echo ''
\echo '✅ JSON EXPORT FUNCTIONS (6):'
\echo '   1. get_top_customers_json()           - Top 50 customers'
\echo '   2. get_clv_tier_distribution_json()   - CLV tier breakdown'
\echo '   3. get_rfm_segments_json()            - RFM segments'
\echo '   4. get_churn_risk_json()              - Churn analysis'
\echo '   5. get_demographics_json()            - Demographics'
\echo '   6. get_geography_json()               - Top 50 locations'
\echo ''
\echo '📊 USAGE EXAMPLES:'
\echo '   -- View high-value customers'
\echo '   SELECT * FROM analytics.mv_customer_lifetime_value WHERE clv_tier = ''Platinum'';'
\echo ''
\echo '   -- Get RFM segments as JSON'
\echo '   SELECT analytics.get_rfm_segments_json();'
\echo ''
\echo '   -- Export to file'
\echo '   psql -d retailmart -t -A -c "SELECT analytics.get_top_customers_json();" > top_customers.json'
\echo ''
\echo '============================================================================'
\echo ''