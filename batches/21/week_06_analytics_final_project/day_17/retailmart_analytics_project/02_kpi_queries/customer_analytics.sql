-- File: 02_kpi_queries/customer_analytics.sql

-- ============================================
-- CUSTOMER ANALYTICS - COMPREHENSIVE MODULE
-- ============================================

-- ---------------------------------------------
-- 1. CUSTOMER LIFETIME VALUE (CLV) ANALYSIS
-- ---------------------------------------------
CREATE MATERIALIZED VIEW analytics.mv_customer_lifetime_value AS
WITH customer_transactions AS (
    SELECT 
        c.cust_id,
        c.full_name,
        c.gender,
        c.age,
        c.city,
        c.state,
        c.join_date,
        MIN(o.order_date) as first_purchase_date,
        MAX(o.order_date) as last_purchase_date,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_revenue,
        AVG(o.total_amount) as avg_order_value,
        SUM(oi.quantity) as total_items_purchased,
        CURRENT_DATE - MAX(o.order_date) as days_since_last_purchase,
        MAX(o.order_date) - MIN(o.order_date) as customer_lifespan_days
    FROM customers.customers c
    LEFT JOIN sales.orders o ON c.cust_id = o.cust_id AND o.order_status = 'Completed'
    LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY c.cust_id, c.full_name, c.gender, c.age, c.city, c.state, c.join_date
),
customer_loyalty AS (
    SELECT 
        cust_id,
        total_points,
        last_updated as loyalty_last_updated
    FROM customers.loyalty_points
),
customer_reviews AS (
    SELECT 
        cust_id,
        COUNT(*) as review_count,
        ROUND(AVG(rating), 2) as avg_rating_given
    FROM customers.reviews
    GROUP BY cust_id
)
SELECT 
    ct.*,
    COALESCE(cl.total_points, 0) as loyalty_points,
    COALESCE(cr.review_count, 0) as review_count,
    COALESCE(cr.avg_rating_given, 0) as avg_rating_given,
    -- Calculated Metrics
    ROUND(ct.total_revenue / NULLIF(GREATEST(ct.customer_lifespan_days, 1), 0) * 365, 2) as projected_annual_value,
    ROUND(ct.total_orders::NUMERIC / NULLIF(GREATEST(ct.customer_lifespan_days, 1), 0) * 30, 2) as avg_orders_per_month,
    -- Customer Segmentation by CLV
    CASE 
        WHEN ct.total_revenue >= 15000 THEN 'Platinum'
        WHEN ct.total_revenue >= 8000 THEN 'Gold'
        WHEN ct.total_revenue >= 3000 THEN 'Silver'
        WHEN ct.total_revenue >= 1000 THEN 'Bronze'
        ELSE 'Basic'
    END as clv_tier,
    -- Activity Status
    CASE 
        WHEN ct.days_since_last_purchase IS NULL THEN 'No Purchases'
        WHEN ct.days_since_last_purchase <= 30 THEN 'Active'
        WHEN ct.days_since_last_purchase <= 90 THEN 'At Risk'
        WHEN ct.days_since_last_purchase <= 180 THEN 'Churning'
        ELSE 'Churned'
    END as customer_status
FROM customer_transactions ct
LEFT JOIN customer_loyalty cl ON ct.cust_id = cl.cust_id
LEFT JOIN customer_reviews cr ON ct.cust_id = cr.cust_id;

CREATE INDEX idx_clv_tier ON analytics.mv_customer_lifetime_value(clv_tier);
CREATE INDEX idx_customer_status ON analytics.mv_customer_lifetime_value(customer_status);

REFRESH MATERIALIZED VIEW analytics.mv_customer_lifetime_value;


-- ---------------------------------------------
-- 2. RFM ANALYSIS (Recency, Frequency, Monetary)
-- ---------------------------------------------
CREATE MATERIALIZED VIEW analytics.mv_rfm_analysis AS
WITH rfm_base AS (
    SELECT 
        o.cust_id,
        c.full_name,
        c.city,
        c.state,
        -- Recency: Days since last purchase
        CURRENT_DATE - MAX(o.order_date) as recency_days,
        -- Frequency: Number of orders
        COUNT(DISTINCT o.order_id) as frequency,
        -- Monetary: Total spend
        SUM(o.total_amount) as monetary
    FROM sales.orders o
    JOIN customers.customers c ON o.cust_id = c.cust_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.cust_id, c.full_name, c.city, c.state
),
rfm_scores AS (
    SELECT 
        *,
        -- Score 1-5 (5 is best)
        NTILE(5) OVER (ORDER BY recency_days) as r_score_raw,
        NTILE(5) OVER (ORDER BY frequency DESC) as f_score,
        NTILE(5) OVER (ORDER BY monetary DESC) as m_score
    FROM rfm_base
),
rfm_calculated AS (
    SELECT 
        cust_id,
        full_name,
        city,
        state,
        recency_days,
        frequency,
        ROUND(monetary, 2) as monetary,
        -- Invert R score (lower recency = better)
        (6 - r_score_raw) as r_score,
        f_score,
        m_score,
        -- Combined RFM Score
        (6 - r_score_raw) || f_score || m_score as rfm_score,
        -- RFM Score Numeric
        (6 - r_score_raw) + f_score + m_score as rfm_total
    FROM rfm_scores
)
SELECT 
    *,
    -- Customer Segments
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 4 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score >= 2 AND m_score >= 2 THEN 'Potential Loyalists'
        WHEN r_score >= 4 AND f_score <= 2 AND m_score <= 2 THEN 'New Customers'
        WHEN r_score >= 3 AND f_score <= 2 AND m_score >= 3 THEN 'Promising'
        WHEN r_score = 3 AND f_score = 3 AND m_score = 3 THEN 'Needs Attention'
        WHEN r_score <= 3 AND f_score <= 3 AND m_score <= 3 THEN 'About to Sleep'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
        WHEN r_score <= 1 AND f_score >= 4 AND m_score >= 4 THEN 'Cannot Lose Them'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Hibernating'
        WHEN r_score = 1 THEN 'Lost'
        ELSE 'Others'
    END as rfm_segment,
    -- Recommended Actions
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Reward with VIP benefits & exclusive offers'
        WHEN r_score >= 3 AND f_score >= 4 THEN 'Upsell premium products & loyalty programs'
        WHEN r_score >= 4 AND f_score >= 2 AND m_score >= 2 THEN 'Encourage repeat purchases with discounts'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Provide onboarding & product education'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'Win-back campaign URGENT'
        WHEN r_score <= 1 AND f_score >= 4 THEN 'Special personalized win-back offer'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Reactivation campaign with incentives'
        ELSE 'Standard engagement'
    END as recommended_action
FROM rfm_calculated;

CREATE INDEX idx_rfm_segment ON analytics.mv_rfm_analysis(rfm_segment);

REFRESH MATERIALIZED VIEW analytics.mv_rfm_analysis;


-- ---------------------------------------------
-- 3. CUSTOMER COHORT RETENTION ANALYSIS
-- ---------------------------------------------
CREATE MATERIALIZED VIEW analytics.mv_cohort_retention AS
WITH customer_cohorts AS (
    SELECT 
        cust_id,
        DATE_TRUNC('month', MIN(order_date))::DATE as cohort_month
    FROM sales.orders
    WHERE order_status = 'Completed'
    GROUP BY cust_id
),
customer_activities AS (
    SELECT DISTINCT
        o.cust_id,
        cc.cohort_month,
        DATE_TRUNC('month', o.order_date)::DATE as activity_month
    FROM sales.orders o
    JOIN customer_cohorts cc ON o.cust_id = cc.cust_id
    WHERE o.order_status = 'Completed'
),
cohort_data AS (
    SELECT 
        cohort_month,
        activity_month,
        EXTRACT(YEAR FROM AGE(activity_month, cohort_month)) * 12 + 
        EXTRACT(MONTH FROM AGE(activity_month, cohort_month)) as months_since_cohort,
        COUNT(DISTINCT cust_id) as active_customers
    FROM customer_activities
    GROUP BY cohort_month, activity_month
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        active_customers as cohort_size
    FROM cohort_data
    WHERE months_since_cohort = 0
)
SELECT 
    cd.cohort_month,
    TO_CHAR(cd.cohort_month, 'YYYY-MM') as cohort,
    cd.months_since_cohort as month_number,
    cs.cohort_size as initial_size,
    cd.active_customers as retained_customers,
    ROUND(100.0 * cd.active_customers / cs.cohort_size, 2) as retention_rate
FROM cohort_data cd
JOIN cohort_sizes cs ON cd.cohort_month = cs.cohort_month
WHERE cd.months_since_cohort <= 12
ORDER BY cd.cohort_month DESC, cd.months_since_cohort;

REFRESH MATERIALIZED VIEW analytics.mv_cohort_retention;


-- ---------------------------------------------
-- 4. CUSTOMER CHURN PREDICTION
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_churn_risk_customers AS
WITH customer_metrics AS (
    SELECT 
        c.cust_id,
        c.full_name,
        c.city,
        c.state,
        c.join_date,
        MAX(o.order_date) as last_order_date,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_spent,
        ROUND(AVG(o.total_amount), 2) as avg_order_value,
        CURRENT_DATE - MAX(o.order_date) as days_inactive,
        -- Calculate expected order frequency
        ROUND(
            (MAX(o.order_date) - MIN(o.order_date))::NUMERIC / 
            NULLIF(COUNT(DISTINCT o.order_id) - 1, 0),
            0
        ) as avg_days_between_orders
    FROM customers.customers c
    LEFT JOIN sales.orders o ON c.cust_id = o.cust_id AND o.order_status = 'Completed'
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
    -- Churn Risk Calculation
    CASE 
        WHEN days_inactive IS NULL THEN 'Never Purchased'
        WHEN days_inactive > (avg_days_between_orders * 3) AND total_spent > 5000 THEN 'Critical - High Value'
        WHEN days_inactive > (avg_days_between_orders * 3) THEN 'High Risk'
        WHEN days_inactive > (avg_days_between_orders * 2) THEN 'Medium Risk'
        WHEN days_inactive > (avg_days_between_orders * 1.5) THEN 'Low Risk'
        ELSE 'Active'
    END as churn_risk_level,
    -- Recommended Actions
    CASE 
        WHEN days_inactive IS NULL THEN 'Welcome campaign'
        WHEN days_inactive > (avg_days_between_orders * 3) AND total_spent > 5000 THEN 'Immediate personal outreach + special offer'
        WHEN days_inactive > (avg_days_between_orders * 3) THEN 'Win-back email campaign'
        WHEN days_inactive > (avg_days_between_orders * 2) THEN 'Engagement campaign with discount'
        WHEN days_inactive > (avg_days_between_orders * 1.5) THEN 'Reminder email'
        ELSE 'Standard marketing'
    END as recommended_action,
    -- Priority Score (1-10, 10 being highest priority)
    CASE 
        WHEN days_inactive IS NULL THEN 3
        WHEN days_inactive > (avg_days_between_orders * 3) AND total_spent > 5000 THEN 10
        WHEN days_inactive > (avg_days_between_orders * 3) THEN 8
        WHEN days_inactive > (avg_days_between_orders * 2) THEN 6
        WHEN days_inactive > (avg_days_between_orders * 1.5) THEN 4
        ELSE 1
    END as priority_score
FROM customer_metrics
WHERE days_inactive > 30 OR days_inactive IS NULL
ORDER BY priority_score DESC, total_spent DESC;


-- ---------------------------------------------
-- 5. CUSTOMER DEMOGRAPHIC ANALYSIS
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_customer_demographics AS
WITH customer_stats AS (
    SELECT 
        c.cust_id,
        c.gender,
        c.age,
        c.city,
        c.state,
        CASE 
            WHEN c.age < 25 THEN '18-24'
            WHEN c.age < 35 THEN '25-34'
            WHEN c.age < 45 THEN '35-44'
            WHEN c.age < 55 THEN '45-54'
            WHEN c.age < 65 THEN '55-64'
            ELSE '65+'
        END as age_group,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_spent
    FROM customers.customers c
    LEFT JOIN sales.orders o ON c.cust_id = o.cust_id AND o.order_status = 'Completed'
    GROUP BY c.cust_id, c.gender, c.age, c.city, c.state
)
SELECT 
    age_group,
    gender,
    COUNT(DISTINCT cust_id) as customer_count,
    SUM(total_orders) as total_orders,
    ROUND(AVG(total_orders), 2) as avg_orders_per_customer,
    ROUND(SUM(total_spent), 2) as total_revenue,
    ROUND(AVG(total_spent), 2) as avg_revenue_per_customer,
    ROUND(100.0 * COUNT(DISTINCT cust_id) / SUM(COUNT(DISTINCT cust_id)) OVER (), 2) as pct_of_customers,
    ROUND(100.0 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 2) as pct_of_revenue
FROM customer_stats
WHERE total_orders > 0
GROUP BY age_group, gender
ORDER BY 
    CASE age_group
        WHEN '18-24' THEN 1
        WHEN '25-34' THEN 2
        WHEN '35-44' THEN 3
        WHEN '45-54' THEN 4
        WHEN '55-64' THEN 5
        ELSE 6
    END,
    gender;


-- ---------------------------------------------
-- 6. CUSTOMER GEOGRAPHIC ANALYSIS
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_customer_geography AS
SELECT 
    c.state,
    c.city,
    COUNT(DISTINCT c.cust_id) as customer_count,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(o.total_amount), 2) as total_revenue,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    ROUND(SUM(o.total_amount) / NULLIF(COUNT(DISTINCT c.cust_id), 0), 2) as revenue_per_customer,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as revenue_rank
FROM customers.customers c
LEFT JOIN sales.orders o ON c.cust_id = o.cust_id AND o.order_status = 'Completed'
GROUP BY c.state, c.city
HAVING COUNT(DISTINCT o.order_id) > 0
ORDER BY total_revenue DESC;


SELECT 'Customer Analytics Module Created Successfully!' as status;