-- File: 02_kpi_queries/product_analytics.sql

-- ============================================
-- PRODUCT ANALYTICS - COMPREHENSIVE MODULE
-- ============================================

-- ---------------------------------------------
-- 1. TOP PRODUCTS PERFORMANCE
-- ---------------------------------------------
CREATE MATERIALIZED VIEW analytics.mv_top_products AS
WITH product_sales AS (
    SELECT 
        p.prod_id,
        p.prod_name,
        p.category,
        p.brand,
        p.price as list_price,
        COUNT(DISTINCT oi.order_id) as times_ordered,
        SUM(oi.quantity) as total_units_sold,
        SUM(oi.quantity * oi.unit_price) as gross_revenue,
        SUM(oi.quantity * oi.unit_price * oi.discount / 100) as total_discounts,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) as net_revenue,
        ROUND(AVG(oi.unit_price), 2) as avg_selling_price,
        ROUND(AVG(oi.discount), 2) as avg_discount_pct
    FROM products.products p
    JOIN sales.order_items oi ON p.prod_id = oi.prod_id
    GROUP BY p.prod_id, p.prod_name, p.category, p.brand, p.price
),
product_reviews AS (
    SELECT 
        prod_id,
        COUNT(*) as review_count,
        ROUND(AVG(rating), 2) as avg_rating,
        COUNT(*) FILTER (WHERE rating = 5) as five_star_reviews,
        COUNT(*) FILTER (WHERE rating >= 4) as positive_reviews
    FROM customers.reviews
    GROUP BY prod_id
),
product_inventory AS (
    SELECT 
        prod_id,
        SUM(stock_qty) as total_stock,
        COUNT(DISTINCT store_id) as stores_stocking
    FROM products.inventory
    GROUP BY prod_id
)
SELECT 
    ps.*,
    COALESCE(pr.review_count, 0) as review_count,
    COALESCE(pr.avg_rating, 0) as avg_rating,
    COALESCE(pi.total_stock, 0) as current_stock,
    COALESCE(pi.stores_stocking, 0) as stores_stocking,
    -- Rankings
    RANK() OVER (ORDER BY ps.net_revenue DESC) as revenue_rank,
    RANK() OVER (ORDER BY ps.total_units_sold DESC) as units_rank,
    RANK() OVER (PARTITION BY ps.category ORDER BY ps.net_revenue DESC) as category_rank,
    -- Performance Metrics
    ROUND(ps.net_revenue / NULLIF(ps.total_units_sold, 0), 2) as revenue_per_unit,
    ROUND(100.0 * ps.net_revenue / SUM(ps.net_revenue) OVER (), 4) as pct_of_total_revenue
FROM product_sales ps
LEFT JOIN product_reviews pr ON ps.prod_id = pr.prod_id
LEFT JOIN product_inventory pi ON ps.prod_id = pi.prod_id;

CREATE INDEX idx_top_products_category ON analytics.mv_top_products(category);
CREATE INDEX idx_top_products_revenue_rank ON analytics.mv_top_products(revenue_rank);

REFRESH MATERIALIZED VIEW analytics.mv_top_products;


-- ---------------------------------------------
-- 2. CATEGORY PERFORMANCE ANALYSIS
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_category_performance AS
WITH category_sales AS (
    SELECT 
        p.category,
        COUNT(DISTINCT p.prod_id) as product_count,
        COUNT(DISTINCT oi.order_id) as order_count,
        SUM(oi.quantity) as units_sold,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) as net_revenue,
        ROUND(AVG(oi.unit_price), 2) as avg_price,
        ROUND(AVG(oi.discount), 2) as avg_discount_pct
    FROM products.products p
    JOIN sales.order_items oi ON p.prod_id = oi.prod_id
    GROUP BY p.category
),
category_reviews AS (
    SELECT 
        p.category,
        COUNT(*) as total_reviews,
        ROUND(AVG(r.rating), 2) as avg_rating
    FROM customers.reviews r
    JOIN products.products p ON r.prod_id = p.prod_id
    GROUP BY p.category
)
SELECT 
    cs.category,
    cs.product_count,
    cs.order_count,
    cs.units_sold,
    ROUND(cs.net_revenue, 2) as net_revenue,
    cs.avg_price,
    cs.avg_discount_pct,
    COALESCE(cr.total_reviews, 0) as total_reviews,
    COALESCE(cr.avg_rating, 0) as avg_rating,
    -- Market Share
    ROUND(100.0 * cs.net_revenue / SUM(cs.net_revenue) OVER (), 2) as market_share_pct,
    RANK() OVER (ORDER BY cs.net_revenue DESC) as revenue_rank,
    -- Performance Metrics
    ROUND(cs.net_revenue / NULLIF(cs.order_count, 0), 2) as revenue_per_order,
    ROUND(cs.units_sold::NUMERIC / NULLIF(cs.order_count, 0), 2) as units_per_order
FROM category_sales cs
LEFT JOIN category_reviews cr ON cs.category = cr.category
ORDER BY cs.net_revenue DESC;


-- ---------------------------------------------
-- 3. BRAND PERFORMANCE ANALYSIS
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_brand_performance AS
SELECT 
    p.brand,
    p.category,
    COUNT(DISTINCT p.prod_id) as product_count,
    SUM(oi.quantity) as total_units_sold,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) as net_revenue,
    ROUND(AVG(oi.unit_price), 2) as avg_selling_price,
    COUNT(DISTINCT oi.order_id) as order_count,
    ROUND(AVG(r.rating), 2) as avg_rating,
    COUNT(r.review_id) as review_count,
    -- Market Share within Category
    ROUND(
        100.0 * SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) / 
        SUM(SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100))) OVER (PARTITION BY p.category),
        2
    ) as category_market_share_pct,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) DESC) as category_rank
FROM products.products p
JOIN sales.order_items oi ON p.prod_id = oi.prod_id
LEFT JOIN customers.reviews r ON p.prod_id = r.prod_id
GROUP BY p.brand, p.category
ORDER BY net_revenue DESC;


-- ---------------------------------------------
-- 4. ABC ANALYSIS (Pareto 80-20)
-- ---------------------------------------------
CREATE MATERIALIZED VIEW analytics.mv_abc_analysis AS
WITH product_revenue AS (
    SELECT 
        p.prod_id,
        p.prod_name,
        p.category,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) as net_revenue
    FROM products.products p
    JOIN sales.order_items oi ON p.prod_id = oi.prod_id
    GROUP BY p.prod_id, p.prod_name, p.category
),
cumulative_revenue AS (
    SELECT 
        *,
        SUM(net_revenue) OVER (ORDER BY net_revenue DESC) as cumulative_revenue,
        SUM(net_revenue) OVER () as total_revenue,
        ROW_NUMBER() OVER (ORDER BY net_revenue DESC) as product_rank,
        COUNT(*) OVER () as total_products
    FROM product_revenue
)
SELECT 
    prod_id,
    prod_name,
    category,
    ROUND(net_revenue, 2) as net_revenue,
    product_rank,
    ROUND(100.0 * cumulative_revenue / total_revenue, 2) as cumulative_revenue_pct,
    ROUND(100.0 * product_rank / total_products, 2) as cumulative_products_pct,
    CASE 
        WHEN ROUND(100.0 * cumulative_revenue / total_revenue, 2) <= 80 THEN 'A - High Value (Top 80%)'
        WHEN ROUND(100.0 * cumulative_revenue / total_revenue, 2) <= 95 THEN 'B - Medium Value (Next 15%)'
        ELSE 'C - Low Value (Bottom 5%)'
    END as abc_classification
FROM cumulative_revenue
ORDER BY product_rank;

REFRESH MATERIALIZED VIEW analytics.mv_abc_analysis;


-- ---------------------------------------------
-- 5. INVENTORY TURNOVER ANALYSIS
-- ---------------------------------------------
CREATE OR REPLACE VIEW analytics.vw_inventory_turnover AS
WITH sales_last_90days AS (
    SELECT 
        prod_id,
        SUM(quantity) as units_sold_90days
    FROM sales.order_items oi
    JOIN sales.orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '90 days'
        AND o.order_status = 'Completed'
    GROUP BY prod_id
),
current_inventory AS (
    SELECT 
        prod_id,
        SUM(stock_qty) as current_stock
    FROM products.inventory
    GROUP BY prod_id
)
SELECT 
    p.prod_id,
    p.prod_name,
    p.category,
    p.brand,
    COALESCE(ci.current_stock, 0) as current_stock,
    COALESCE(s.units_sold_90days, 0) as units_sold_last_90days,
    -- Days of Inventory
    CASE 
        WHEN COALESCE(s.units_sold_90days, 0) > 0 THEN
            ROUND(COALESCE(ci.current_stock, 0)::NUMERIC / (s.units_sold_90days / 90.0), 0)
        ELSE NULL
    END as days_of_inventory,
    -- Turnover Rate (annualized)
    CASE 
        WHEN COALESCE(ci.current_stock, 0) > 0 THEN
            ROUND((s.units_sold_90days * 4.0) / ci.current_stock, 2)
        ELSE NULL
    END as annual_turnover_rate,
    -- Stock Status
    CASE 
        WHEN COALESCE(ci.current_stock, 0) = 0 THEN 'Out of Stock'
        WHEN COALESCE(s.units_sold_90days, 0) = 0 THEN 'No Recent Sales'
        WHEN ROUND(COALESCE(ci.current_stock, 0)::NUMERIC / NULLIF((s.units_sold_90days / 90.0), 0), 0) < 30 THEN 'Low Stock'
        WHEN ROUND(COALESCE(ci.current_stock, 0)::NUMERIC / NULLIF((s.units_sold_90days / 90.0), 0), 0) > 180 THEN 'Overstocked'
        ELSE 'Normal'
    END as stock_status
FROM products.products p
LEFT JOIN current_inventory ci ON p.prod_id = ci.prod_id
LEFT JOIN sales_last_90days s ON p.prod_id = s.prod_id
ORDER BY days_of_inventory NULLS LAST;


SELECT 'Product Analytics Module Created Successfully!' as status;