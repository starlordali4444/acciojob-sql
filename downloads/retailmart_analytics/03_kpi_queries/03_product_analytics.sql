-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 03_kpi_queries/03_product_analytics.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Product Analytics Module — Top Products, ABC, Category, Brand, Inventory
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- V2 CHANGES:
--   - prod_name → product_name
--   - category/brand → via dim_brand → dim_category JOIN chain
--   - oi.discount (%) → oi.discount_amount / oi.net_amount (absolute)
--   - stock_qty → quantity_on_hand
--   - prod_id → product_id on products/inventory tables
--   - reviews: prod_id → product_id, cust_id → customer_id
--
-- CREATES: 3 Views + 2 MVs + 5 JSON Functions
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '          PRODUCT ANALYTICS MODULE (V2) — STARTING                          '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- MATERIALIZED VIEW 1: TOP PRODUCTS
-- ============================================================================

\echo '[1/5] Creating materialized view: mv_top_products...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_top_products CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_top_products AS
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        cat.category_name as category,
        b.brand_name as brand,
        p.price as list_price,
        p.cost_price,
        COUNT(DISTINCT oi.order_id) as times_ordered,
        SUM(oi.quantity) as total_units_sold,
        SUM(oi.gross_amount) as gross_revenue,
        SUM(oi.discount_amount) as total_discounts,
        SUM(oi.net_amount) as net_revenue,
        AVG(oi.unit_price) as avg_selling_price
    FROM products.products p
    JOIN core.dim_brand b ON p.brand_id = b.brand_id
    JOIN core.dim_category cat ON b.category_id = cat.category_id
    JOIN sales.order_items oi ON p.product_id = oi.prod_id
    JOIN sales.orders o ON oi.order_id = o.order_id AND o.order_status = 'Delivered'
    GROUP BY p.product_id, p.product_name, cat.category_name, b.brand_name, p.price, p.cost_price
),
product_reviews AS (
    SELECT product_id, COUNT(*) as review_count, ROUND(AVG(rating), 2) as avg_rating
    FROM customers.reviews
    GROUP BY product_id
),
product_inventory AS (
    SELECT product_id, SUM(quantity_on_hand) as total_stock, COUNT(DISTINCT store_id) as stores_stocking
    FROM products.inventory
    GROUP BY product_id
)
SELECT 
    ps.product_id,
    ps.product_name,
    ps.category,
    ps.brand,
    ROUND(ps.list_price::NUMERIC, 2) as list_price,
    ROUND(ps.cost_price::NUMERIC, 2) as cost_price,
    ps.times_ordered,
    ps.total_units_sold,
    ROUND(ps.gross_revenue::NUMERIC, 2) as gross_revenue,
    ROUND(ps.total_discounts::NUMERIC, 2) as total_discounts,
    ROUND(ps.net_revenue::NUMERIC, 2) as net_revenue,
    ROUND(ps.avg_selling_price::NUMERIC, 2) as avg_selling_price,
    -- Profit margin (V2: we have cost_price now!)
    ROUND(((ps.net_revenue - (ps.total_units_sold * ps.cost_price)) / NULLIF(ps.net_revenue, 0) * 100)::NUMERIC, 2) as profit_margin_pct,
    COALESCE(pr.review_count, 0) as review_count,
    COALESCE(pr.avg_rating, 0) as avg_rating,
    COALESCE(pi.total_stock, 0) as current_stock,
    COALESCE(pi.stores_stocking, 0) as stores_stocking,
    RANK() OVER (ORDER BY ps.net_revenue DESC) as revenue_rank,
    RANK() OVER (ORDER BY ps.total_units_sold DESC) as units_rank,
    RANK() OVER (PARTITION BY ps.category ORDER BY ps.net_revenue DESC) as category_rank,
    ROUND((ps.net_revenue / SUM(ps.net_revenue) OVER () * 100)::NUMERIC, 4) as pct_of_total_revenue
FROM product_sales ps
LEFT JOIN product_reviews pr ON ps.product_id = pr.product_id
LEFT JOIN product_inventory pi ON ps.product_id = pi.product_id;

CREATE INDEX IF NOT EXISTS idx_top_products_category ON analytics.mv_top_products(category);
CREATE INDEX IF NOT EXISTS idx_top_products_rank ON analytics.mv_top_products(revenue_rank);

COMMENT ON MATERIALIZED VIEW analytics.mv_top_products IS 'Top products with revenue, margins, and ratings — V2 with cost_price';

\echo '      ✓ Materialized view created: mv_top_products'


-- ============================================================================
-- MATERIALIZED VIEW 2: ABC ANALYSIS (Pareto)
-- ============================================================================

\echo '[2/5] Creating materialized view: mv_abc_analysis...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_abc_analysis CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_abc_analysis AS
WITH product_revenue AS (
    SELECT 
        p.product_id,
        p.product_name,
        cat.category_name as category,
        b.brand_name as brand,
        SUM(oi.net_amount) as net_revenue
    FROM products.products p
    JOIN core.dim_brand b ON p.brand_id = b.brand_id
    JOIN core.dim_category cat ON b.category_id = cat.category_id
    JOIN sales.order_items oi ON p.product_id = oi.prod_id
    JOIN sales.orders o ON oi.order_id = o.order_id AND o.order_status = 'Delivered'
    GROUP BY p.product_id, p.product_name, cat.category_name, b.brand_name
),
with_cumulative AS (
    SELECT 
        *,
        SUM(net_revenue) OVER (ORDER BY net_revenue DESC) as cumulative_revenue,
        SUM(net_revenue) OVER () as total_revenue
    FROM product_revenue
)
SELECT 
    product_id, product_name, category, brand,
    ROUND(net_revenue::NUMERIC, 2) as net_revenue,
    ROUND((net_revenue / total_revenue * 100)::NUMERIC, 4) as pct_of_revenue,
    ROUND((cumulative_revenue / total_revenue * 100)::NUMERIC, 2) as cumulative_pct,
    CASE 
        WHEN cumulative_revenue / total_revenue <= 0.80 THEN 'A'
        WHEN cumulative_revenue / total_revenue <= 0.95 THEN 'B'
        ELSE 'C'
    END as abc_classification,
    ROW_NUMBER() OVER (ORDER BY net_revenue DESC) as revenue_rank
FROM with_cumulative
ORDER BY net_revenue DESC;

COMMENT ON MATERIALIZED VIEW analytics.mv_abc_analysis IS 'ABC/Pareto classification — 80/20 rule analysis';

\echo '      ✓ Materialized view created: mv_abc_analysis'


-- ============================================================================
-- VIEW 1: CATEGORY PERFORMANCE
-- ============================================================================

\echo '[3/5] Creating view: vw_category_performance...'

CREATE OR REPLACE VIEW analytics.vw_category_performance AS
WITH category_stats AS (
    SELECT 
        cat.category_name as category,
        COUNT(DISTINCT p.product_id) as product_count,
        COUNT(DISTINCT oi.order_id) as order_count,
        SUM(oi.quantity) as units_sold,
        SUM(oi.net_amount) as net_revenue,
        AVG(oi.unit_price) as avg_price
    FROM products.products p
    JOIN core.dim_brand b ON p.brand_id = b.brand_id
    JOIN core.dim_category cat ON b.category_id = cat.category_id
    JOIN sales.order_items oi ON p.product_id = oi.prod_id
    JOIN sales.orders o ON oi.order_id = o.order_id AND o.order_status = 'Delivered'
    GROUP BY cat.category_name
),
category_reviews AS (
    SELECT cat.category_name as category, COUNT(*) as total_reviews, AVG(r.rating) as avg_rating
    FROM customers.reviews r
    JOIN products.products p ON r.product_id = p.product_id
    JOIN core.dim_brand b ON p.brand_id = b.brand_id
    JOIN core.dim_category cat ON b.category_id = cat.category_id
    GROUP BY cat.category_name
)
SELECT 
    cs.category,
    cs.product_count,
    cs.order_count,
    cs.units_sold,
    ROUND(cs.net_revenue::NUMERIC, 2) as net_revenue,
    ROUND(cs.avg_price::NUMERIC, 2) as avg_price,
    COALESCE(cr.total_reviews, 0) as total_reviews,
    ROUND(COALESCE(cr.avg_rating, 0)::NUMERIC, 2) as avg_rating,
    ROUND((cs.net_revenue / SUM(cs.net_revenue) OVER () * 100)::NUMERIC, 2) as market_share_pct,
    RANK() OVER (ORDER BY cs.net_revenue DESC) as revenue_rank
FROM category_stats cs
LEFT JOIN category_reviews cr ON cs.category = cr.category
ORDER BY net_revenue DESC;

COMMENT ON VIEW analytics.vw_category_performance IS 'Category-level performance metrics';

\echo '      ✓ View created: vw_category_performance'


-- ============================================================================
-- VIEW 2: BRAND PERFORMANCE
-- ============================================================================

\echo '[4/5] Creating view: vw_brand_performance...'

CREATE OR REPLACE VIEW analytics.vw_brand_performance AS
SELECT 
    brand,
    category,
    COUNT(DISTINCT product_id) as product_count,
    SUM(total_units_sold) as total_units_sold,
    ROUND(SUM(net_revenue)::NUMERIC, 2) as net_revenue,
    ROUND(AVG(avg_rating)::NUMERIC, 2) as avg_rating,
    SUM(review_count) as review_count,
    ROUND((SUM(net_revenue) / SUM(SUM(net_revenue)) OVER (PARTITION BY category) * 100)::NUMERIC, 2) as category_market_share_pct,
    RANK() OVER (PARTITION BY category ORDER BY SUM(net_revenue) DESC) as category_rank
FROM analytics.mv_top_products
GROUP BY brand, category
ORDER BY net_revenue DESC;

COMMENT ON VIEW analytics.vw_brand_performance IS 'Brand-level performance within categories';

\echo '      ✓ View created: vw_brand_performance'


-- ============================================================================
-- VIEW 3: INVENTORY TURNOVER
-- ============================================================================

\echo '[5/5] Creating view: vw_inventory_turnover...'

CREATE OR REPLACE VIEW analytics.vw_inventory_turnover AS
WITH product_velocity AS (
    SELECT 
        p.product_id,
        p.product_name,
        cat.category_name as category,
        i.quantity_on_hand as current_stock,
        i.reorder_level,
        COALESCE(SUM(oi.quantity), 0) as units_sold_30d
    FROM products.products p
    JOIN core.dim_brand b ON p.brand_id = b.brand_id
    JOIN core.dim_category cat ON b.category_id = cat.category_id
    LEFT JOIN products.inventory i ON p.product_id = i.product_id
    LEFT JOIN sales.order_items oi ON p.product_id = oi.prod_id
    LEFT JOIN sales.orders o ON oi.order_id = o.order_id 
        AND o.order_status = 'Delivered'
        AND o.order_date >= (SELECT MAX(order_date) - INTERVAL '30 days' FROM sales.orders)
    GROUP BY p.product_id, p.product_name, cat.category_name, i.quantity_on_hand, i.reorder_level
)
SELECT 
    product_id,
    product_name,
    category,
    COALESCE(current_stock, 0) as current_stock,
    COALESCE(reorder_level, 0) as reorder_level,
    units_sold_30d,
    ROUND(units_sold_30d / 30.0, 2) as daily_velocity,
    CASE 
        WHEN units_sold_30d > 0 THEN ROUND(COALESCE(current_stock, 0) / (units_sold_30d / 30.0), 0)
        ELSE 9999
    END as days_of_inventory,
    CASE 
        WHEN COALESCE(current_stock, 0) = 0 THEN 'Out of Stock'
        WHEN units_sold_30d = 0 THEN 'Dead Stock'
        WHEN COALESCE(current_stock, 0) <= COALESCE(reorder_level, 10) THEN 'Low Stock'
        WHEN COALESCE(current_stock, 0) / NULLIF(units_sold_30d / 30.0, 0) > 90 THEN 'Overstocked'
        ELSE 'Normal'
    END as stock_status
FROM product_velocity
ORDER BY days_of_inventory;

COMMENT ON VIEW analytics.vw_inventory_turnover IS 'Inventory velocity and stock health — V2 with reorder_level';

\echo '      ✓ View created: vw_inventory_turnover'


-- ============================================================================
-- JSON EXPORT FUNCTIONS
-- ============================================================================

\echo ''
\echo 'Creating JSON export functions...'

CREATE OR REPLACE FUNCTION analytics.get_top_products_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(json_build_object(
            'productId', product_id, 'productName', product_name, 'category', category, 'brand', brand,
            'revenue', net_revenue, 'unitsSold', total_units_sold, 'avgRating', avg_rating,
            'profitMargin', profit_margin_pct, 'currentStock', current_stock,
            'revenueRank', revenue_rank, 'categoryRank', category_rank
        ) ORDER BY revenue_rank)
        FROM analytics.mv_top_products LIMIT 20
    );
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_category_performance_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(json_build_object(
            'category', category, 'productCount', product_count, 'revenue', net_revenue,
            'unitsSold', units_sold, 'avgPrice', avg_price, 'avgRating', avg_rating,
            'marketShare', market_share_pct, 'rank', revenue_rank
        ) ORDER BY revenue_rank)
        FROM analytics.vw_category_performance
    );
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_brand_performance_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(json_build_object(
            'brand', brand, 'category', category, 'productCount', product_count,
            'revenue', net_revenue, 'unitsSold', total_units_sold, 'avgRating', avg_rating,
            'categoryMarketShare', category_market_share_pct, 'categoryRank', category_rank
        ) ORDER BY net_revenue DESC)
        FROM analytics.vw_brand_performance LIMIT 20
    );
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_abc_analysis_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'summary', (
                SELECT json_agg(json_build_object(
                    'class', abc_classification, 'productCount', cnt, 'totalRevenue', revenue, 'pctOfRevenue', pct
                ))
                FROM (
                    SELECT abc_classification, COUNT(*) as cnt, 
                           ROUND(SUM(net_revenue)::NUMERIC, 2) as revenue,
                           ROUND((SUM(net_revenue) / SUM(SUM(net_revenue)) OVER () * 100)::NUMERIC, 2) as pct
                    FROM analytics.mv_abc_analysis GROUP BY abc_classification
                ) s
            ),
            'topAProducts', (
                SELECT json_agg(json_build_object('productName', product_name, 'revenue', net_revenue, 'pct', pct_of_revenue))
                FROM analytics.mv_abc_analysis WHERE abc_classification = 'A' LIMIT 20
            )
        )
    );
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_inventory_status_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(json_build_object('status', stock_status, 'productCount', cnt, 'pctOfProducts', pct))
        FROM (
            SELECT stock_status, COUNT(*) as cnt,
                   ROUND((COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100), 2) as pct
            FROM analytics.vw_inventory_turnover GROUP BY stock_status
        ) s
    );
END;
$$ LANGUAGE plpgsql STABLE;

\echo '      ✓ JSON functions created (5 functions)'

REFRESH MATERIALIZED VIEW analytics.mv_top_products;
REFRESH MATERIALIZED VIEW analytics.mv_abc_analysis;

\echo ''
\echo '============================================================================'
\echo '          PRODUCT ANALYTICS MODULE (V2) — COMPLETE                          '
\echo '============================================================================'
\echo ''
\echo '✅ Views: vw_category_performance, vw_brand_performance, vw_inventory_turnover'
\echo '✅ MVs: mv_top_products, mv_abc_analysis'
\echo '✅ JSON: 5 export functions'
\echo ''
\echo '➡️  Next: Run 04_store_analytics.sql'
\echo '============================================================================'
\echo ''