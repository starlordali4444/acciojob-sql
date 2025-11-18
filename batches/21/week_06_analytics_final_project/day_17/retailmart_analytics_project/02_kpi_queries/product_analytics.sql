-- ============================================================================
-- FILE: 02_kpi_queries/product_analytics.sql
-- PURPOSE: Product Analytics Module - Complete product performance tracking
-- AUTHOR: RetailMart Analytics Team
-- CREATED: 2024
-- DESCRIPTION: 
--   - Top products by revenue and units sold
--   - Category and brand performance analysis
--   - ABC classification (Pareto 80-20 rule)
--   - Inventory turnover and stock status
--   - JSON export functions for dashboard integration
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                   PRODUCT ANALYTICS MODULE - STARTING                      '
\echo '============================================================================'
\echo ''
\echo 'This module creates:'
\echo '  - 3 Regular Views (category, brand, inventory turnover)'
\echo '  - 2 Materialized Views (top products, ABC analysis)'
\echo '  - 5 JSON Export Functions (for dashboard integration)'
\echo ''

-- ============================================================================
-- 1. TOP PRODUCTS PERFORMANCE - MATERIALIZED VIEW
-- ============================================================================
-- PURPOSE: Comprehensive product performance metrics with rankings
-- REFRESH: Manual (call REFRESH MATERIALIZED VIEW or use refresh function)
-- USAGE: SELECT * FROM analytics.mv_top_products WHERE revenue_rank <= 20;
-- ============================================================================

\echo '[1/5] Creating materialized view: mv_top_products...'
\echo '      - Aggregates product sales, reviews, and inventory'
\echo '      - Ranks products by revenue, units, and within categories'
\echo '      - Includes ratings and stock information'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_top_products CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_top_products AS
WITH product_sales AS (
    -- Step 1: Aggregate sales metrics per product
    SELECT 
        p.prod_id,                                      -- Product identifier
        p.prod_name,                                    -- Product name
        p.category,                                     -- Product category
        p.brand,                                        -- Brand name
        p.price as list_price,                          -- MSRP/List price
        
        -- Order Metrics
        COUNT(DISTINCT oi.order_id) as times_ordered,   -- Number of orders containing this product
        SUM(oi.quantity) as total_units_sold,          -- Total units sold
        
        -- Revenue Metrics (before and after discounts)
        SUM(oi.quantity * oi.unit_price) as gross_revenue,  -- Revenue before discounts
        SUM(oi.quantity * oi.unit_price * oi.discount / 100) as total_discounts, -- Total discount amount
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) as net_revenue, -- Revenue after discounts
        
        -- Pricing Metrics
        ROUND(AVG(oi.unit_price), 2) as avg_selling_price,  -- Average actual selling price
        ROUND(AVG(oi.discount), 2) as avg_discount_pct      -- Average discount percentage
    FROM products.products p
    JOIN sales.order_items oi ON p.prod_id = oi.prod_id
    GROUP BY p.prod_id, p.prod_name, p.category, p.brand, p.price
),
product_reviews AS (
    -- Step 2: Aggregate review metrics per product
    SELECT 
        prod_id,
        COUNT(*) as review_count,                       -- Total number of reviews
        ROUND(AVG(rating), 2) as avg_rating,           -- Average star rating
        COUNT(*) FILTER (WHERE rating = 5) as five_star_reviews,     -- Count of 5-star reviews
        COUNT(*) FILTER (WHERE rating >= 4) as positive_reviews      -- Count of 4-5 star reviews
    FROM customers.reviews
    GROUP BY prod_id
),
product_inventory AS (
    -- Step 3: Aggregate inventory across all stores
    SELECT 
        prod_id,
        SUM(stock_qty) as total_stock,                 -- Total units in stock across all stores
        COUNT(DISTINCT store_id) as stores_stocking    -- Number of stores carrying this product
    FROM products.inventory
    GROUP BY prod_id
)
-- Final Select: Combine all metrics
SELECT 
    ps.*,
    
    -- Review Metrics (default to 0 if no reviews)
    COALESCE(pr.review_count, 0) as review_count,
    COALESCE(pr.avg_rating, 0) as avg_rating,
    
    -- Inventory Metrics (default to 0 if not in inventory)
    COALESCE(pi.total_stock, 0) as current_stock,
    COALESCE(pi.stores_stocking, 0) as stores_stocking,
    
    -- Rankings
    RANK() OVER (ORDER BY ps.net_revenue DESC) as revenue_rank,              -- Overall revenue rank
    RANK() OVER (ORDER BY ps.total_units_sold DESC) as units_rank,          -- Overall units rank
    RANK() OVER (PARTITION BY ps.category ORDER BY ps.net_revenue DESC) as category_rank, -- Rank within category
    
    -- Calculated Metrics
    ROUND(ps.net_revenue / NULLIF(ps.total_units_sold, 0), 2) as revenue_per_unit,  -- Revenue per unit sold
    ROUND(100.0 * ps.net_revenue / SUM(ps.net_revenue) OVER (), 4) as pct_of_total_revenue  -- % of total revenue
FROM product_sales ps
LEFT JOIN product_reviews pr ON ps.prod_id = pr.prod_id
LEFT JOIN product_inventory pi ON ps.prod_id = pi.prod_id;

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_top_products_category 
ON analytics.mv_top_products(category);

CREATE INDEX IF NOT EXISTS idx_top_products_revenue_rank 
ON analytics.mv_top_products(revenue_rank);

\echo '      ✓ Materialized view created: mv_top_products'
\echo '      ✓ Indexes created on (category, revenue_rank)'
\echo ''


-- ============================================================================
-- 2. CATEGORY PERFORMANCE ANALYSIS
-- ============================================================================
-- PURPOSE: High-level category performance with market share
-- UPDATES: Real-time (view refreshes on query)
-- USAGE: SELECT * FROM analytics.vw_category_performance ORDER BY net_revenue DESC;
-- ============================================================================

\echo '[2/5] Creating view: vw_category_performance...'
\echo '      - Aggregates sales by product category'
\echo '      - Calculates market share and category rankings'
\echo '      - Includes review metrics per category'

CREATE OR REPLACE VIEW analytics.vw_category_performance AS
WITH category_sales AS (
    -- Step 1: Aggregate sales metrics by category
    SELECT 
        p.category,                                     -- Category name
        COUNT(DISTINCT p.prod_id) as product_count,    -- Number of products in category
        COUNT(DISTINCT oi.order_id) as order_count,    -- Number of orders containing this category
        SUM(oi.quantity) as units_sold,                -- Total units sold
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) as net_revenue, -- Net revenue
        ROUND(AVG(oi.unit_price), 2) as avg_price,     -- Average selling price
        ROUND(AVG(oi.discount), 2) as avg_discount_pct -- Average discount %
    FROM products.products p
    JOIN sales.order_items oi ON p.prod_id = oi.prod_id
    GROUP BY p.category
),
category_reviews AS (
    -- Step 2: Aggregate review metrics by category
    SELECT 
        p.category,
        COUNT(*) as total_reviews,                      -- Total reviews in category
        ROUND(AVG(r.rating), 2) as avg_rating          -- Average rating
    FROM customers.reviews r
    JOIN products.products p ON r.prod_id = p.prod_id
    GROUP BY p.category
)
-- Final Select: Combine sales and review metrics
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
    
    -- Market Share Calculations
    ROUND(100.0 * cs.net_revenue / SUM(cs.net_revenue) OVER (), 2) as market_share_pct,  -- % of total revenue
    RANK() OVER (ORDER BY cs.net_revenue DESC) as revenue_rank,
    
    -- Performance Metrics
    ROUND(cs.net_revenue / NULLIF(cs.order_count, 0), 2) as revenue_per_order,  -- Revenue per order
    ROUND(cs.units_sold::NUMERIC / NULLIF(cs.order_count, 0), 2) as units_per_order  -- Units per order
FROM category_sales cs
LEFT JOIN category_reviews cr ON cs.category = cr.category
ORDER BY cs.net_revenue DESC;

\echo '      ✓ View created: vw_category_performance'
\echo ''


-- ============================================================================
-- 3. BRAND PERFORMANCE ANALYSIS
-- ============================================================================
-- PURPOSE: Brand performance within each category with market share
-- UPDATES: Real-time (view refreshes on query)
-- USAGE: SELECT * FROM analytics.vw_brand_performance WHERE category = 'Electronics';
-- ============================================================================

\echo '[3/5] Creating view: vw_brand_performance...'
\echo '      - Analyzes brand performance within categories'
\echo '      - Calculates brand market share within each category'
\echo '      - Includes brand rankings'

CREATE OR REPLACE VIEW analytics.vw_brand_performance AS
SELECT 
    p.brand,                                            -- Brand name
    p.category,                                         -- Category name
    
    -- Product and Order Metrics
    COUNT(DISTINCT p.prod_id) as product_count,        -- Products by this brand
    SUM(oi.quantity) as total_units_sold,              -- Total units sold
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) as net_revenue, -- Net revenue
    ROUND(AVG(oi.unit_price), 2) as avg_selling_price, -- Average selling price
    COUNT(DISTINCT oi.order_id) as order_count,        -- Orders containing this brand
    
    -- Review Metrics
    ROUND(AVG(r.rating), 2) as avg_rating,             -- Average rating
    COUNT(r.review_id) as review_count,                -- Total reviews
    
    -- Market Share within Category
    ROUND(
        100.0 * SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) / 
        SUM(SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100))) OVER (PARTITION BY p.category),
        2
    ) as category_market_share_pct,                    -- % of category revenue
    
    -- Rankings within Category
    RANK() OVER (
        PARTITION BY p.category 
        ORDER BY SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) DESC
    ) as category_rank
FROM products.products p
JOIN sales.order_items oi ON p.prod_id = oi.prod_id
LEFT JOIN customers.reviews r ON p.prod_id = r.prod_id
GROUP BY p.brand, p.category
ORDER BY net_revenue DESC;

\echo '      ✓ View created: vw_brand_performance'
\echo ''


-- ============================================================================
-- 4. ABC ANALYSIS (PARETO 80-20 RULE) - MATERIALIZED VIEW
-- ============================================================================
-- PURPOSE: Classify products using ABC analysis (80-20 rule)
--          A = Top 80% of revenue (high value)
--          B = Next 15% of revenue (medium value)
--          C = Bottom 5% of revenue (low value)
-- REFRESH: Manual
-- USAGE: SELECT * FROM analytics.mv_abc_analysis WHERE abc_classification = 'A - High Value';
-- ============================================================================

\echo '[4/5] Creating materialized view: mv_abc_analysis...'
\echo '      - Applies ABC classification (Pareto 80-20 principle)'
\echo '      - Identifies high-value products (A), medium (B), low (C)'
\echo '      - Calculates cumulative revenue percentages'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_abc_analysis CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_abc_analysis AS
WITH product_revenue AS (
    -- Step 1: Calculate net revenue per product
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
    -- Step 2: Calculate cumulative revenue and percentages
    SELECT 
        *,
        -- Running total of revenue (ordered by highest revenue first)
        SUM(net_revenue) OVER (ORDER BY net_revenue DESC) as cumulative_revenue,
        -- Total revenue across all products
        SUM(net_revenue) OVER () as total_revenue,
        -- Product rank by revenue
        ROW_NUMBER() OVER (ORDER BY net_revenue DESC) as product_rank,
        -- Total product count
        COUNT(*) OVER () as total_products
    FROM product_revenue
)
SELECT 
    prod_id,
    prod_name,
    category,
    ROUND(net_revenue, 2) as net_revenue,
    product_rank,
    
    -- Cumulative Percentages
    ROUND(100.0 * cumulative_revenue / total_revenue, 2) as cumulative_revenue_pct,  -- What % of total revenue
    ROUND(100.0 * product_rank / total_products, 2) as cumulative_products_pct,      -- What % of total products
    
    -- ABC Classification
    CASE 
        WHEN ROUND(100.0 * cumulative_revenue / total_revenue, 2) <= 80 THEN 'A - High Value'    -- Top 80% of revenue
        WHEN ROUND(100.0 * cumulative_revenue / total_revenue, 2) <= 95 THEN 'B - Medium Value'  -- Next 15% of revenue
        ELSE 'C - Low Value'                                                                       -- Bottom 5% of revenue
    END as abc_classification
FROM cumulative_revenue
ORDER BY product_rank;

\echo '      ✓ Materialized view created: mv_abc_analysis'
\echo ''


-- ============================================================================
-- 5. INVENTORY TURNOVER ANALYSIS
-- ============================================================================
-- PURPOSE: Track how quickly inventory is selling (velocity analysis)
-- UPDATES: Real-time (view refreshes on query)
-- USAGE: SELECT * FROM analytics.vw_inventory_turnover WHERE stock_status = 'Low Stock';
-- NOTES: Uses last 90 days of sales to calculate turnover rates
-- ============================================================================

\echo '[5/5] Creating view: vw_inventory_turnover...'
\echo '      - Calculates inventory turnover rate'
\echo '      - Identifies overstocked and understocked items'
\echo '      - Shows days of inventory remaining'

CREATE OR REPLACE VIEW analytics.vw_inventory_turnover AS
WITH sales_last_90days AS (
    -- Step 1: Get sales velocity (last 90 days)
    SELECT 
        prod_id,
        SUM(quantity) as units_sold_90days              -- Units sold in last 90 days
    FROM sales.order_items oi
    JOIN sales.orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '90 days'
        AND o.order_status = 'Delivered'
    GROUP BY prod_id
),
current_inventory AS (
    -- Step 2: Get current stock levels
    SELECT 
        prod_id,
        SUM(stock_qty) as current_stock                 -- Total stock across all stores
    FROM products.inventory
    GROUP BY prod_id
)
SELECT 
    p.prod_id,
    p.prod_name,
    p.category,
    p.brand,
    
    -- Inventory Levels
    COALESCE(ci.current_stock, 0) as current_stock,
    COALESCE(s.units_sold_90days, 0) as units_sold_last_90days,
    
    -- Days of Inventory Remaining
    -- Formula: (Current Stock / Daily Sales Rate)
    CASE 
        WHEN COALESCE(s.units_sold_90days, 0) > 0 THEN
            ROUND(COALESCE(ci.current_stock, 0)::NUMERIC / (s.units_sold_90days / 90.0), 0)
        ELSE NULL                                       -- No sales = can't calculate
    END as days_of_inventory,
    
    -- Annual Turnover Rate
    -- Formula: (Annual Sales / Current Stock)
    CASE 
        WHEN COALESCE(ci.current_stock, 0) > 0 THEN
            ROUND((s.units_sold_90days * 4.0) / ci.current_stock, 2)  -- Annualize 90-day sales
        ELSE NULL
    END as annual_turnover_rate,
    
    -- Stock Status Classification
    CASE 
        WHEN COALESCE(ci.current_stock, 0) = 0 THEN 'Out of Stock'             -- No inventory
        WHEN COALESCE(s.units_sold_90days, 0) = 0 THEN 'No Recent Sales'       -- Not selling
        WHEN ROUND(COALESCE(ci.current_stock, 0)::NUMERIC / NULLIF((s.units_sold_90days / 90.0), 0), 0) < 30 
            THEN 'Low Stock'                                                     -- Less than 30 days supply
        WHEN ROUND(COALESCE(ci.current_stock, 0)::NUMERIC / NULLIF((s.units_sold_90days / 90.0), 0), 0) > 180 
            THEN 'Overstocked'                                                   -- More than 6 months supply
        ELSE 'Normal'                                                            -- 30-180 days supply
    END as stock_status
FROM products.products p
LEFT JOIN current_inventory ci ON p.prod_id = ci.prod_id
LEFT JOIN sales_last_90days s ON p.prod_id = s.prod_id
ORDER BY days_of_inventory NULLS LAST;

\echo '      ✓ View created: vw_inventory_turnover'
\echo ''


-- ============================================================================
-- REFRESH MATERIALIZED VIEWS
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '                    REFRESHING MATERIALIZED VIEWS                           '
\echo '============================================================================'
\echo ''

\echo 'Refreshing mv_top_products...'
REFRESH MATERIALIZED VIEW analytics.mv_top_products;
\echo '✓ Refreshed: mv_top_products'

\echo 'Refreshing mv_abc_analysis...'
REFRESH MATERIALIZED VIEW analytics.mv_abc_analysis;
\echo '✓ Refreshed: mv_abc_analysis'

\echo ''


-- ============================================================================
-- JSON EXPORT FUNCTIONS FOR DASHBOARD INTEGRATION
-- ============================================================================
-- PURPOSE: Provide JSON endpoints for dashboard to consume data
-- USAGE: SELECT analytics.get_top_products_json();
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '                    CREATING JSON EXPORT FUNCTIONS                          '
\echo '============================================================================'
\echo ''
\echo 'These functions return JSON data for dashboard visualization:'
\echo '  - Top 20 products by revenue'
\echo '  - Category performance summary'
\echo '  - Brand performance (top 20)'
\echo '  - ABC classification summary'
\echo '  - Inventory status distribution'
\echo ''

-- ----------------------------------------------------------------------------
-- JSON Function 1: Top 20 Products
-- ----------------------------------------------------------------------------
\echo '[JSON 1/5] Creating function: get_top_products_json()'
\echo '           - Returns top 20 products with all metrics'

CREATE OR REPLACE FUNCTION analytics.get_top_products_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'productId', prod_id,                   -- Product ID
                'productName', prod_name,               -- Product name
                'category', category,                   -- Category
                'brand', brand,                         -- Brand
                'revenue', net_revenue,                 -- Net revenue
                'unitsSold', total_units_sold,         -- Units sold
                'avgRating', avg_rating,                -- Average rating
                'reviewCount', review_count,            -- Review count
                'currentStock', current_stock,          -- Current inventory
                'storesStocking', stores_stocking,      -- Stores carrying product
                'rank', revenue_rank,                   -- Revenue rank
                'categoryRank', category_rank,          -- Rank within category
                'revenuePerUnit', revenue_per_unit,     -- Revenue per unit
                'pctOfRevenue', pct_of_total_revenue    -- % of total revenue
            ) ORDER BY revenue_rank
        )
        FROM analytics.mv_top_products
        WHERE revenue_rank <= 20                        -- Top 20 only
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_top_products_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 2: Category Performance
-- ----------------------------------------------------------------------------
\echo '[JSON 2/5] Creating function: get_category_performance_json()'
\echo '           - Returns all categories with performance metrics'

CREATE OR REPLACE FUNCTION analytics.get_category_performance_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'category', category,                   -- Category name
                'productCount', product_count,          -- Products in category
                'revenue', net_revenue,                 -- Net revenue
                'orders', order_count,                  -- Orders containing category
                'unitsSold', units_sold,                -- Units sold
                'avgPrice', avg_price,                  -- Average price
                'avgRating', avg_rating,                -- Average rating
                'reviewCount', total_reviews,           -- Total reviews
                'marketShare', market_share_pct,        -- Market share %
                'rank', revenue_rank,                   -- Revenue rank
                'revenuePerOrder', revenue_per_order,   -- Revenue per order
                'unitsPerOrder', units_per_order        -- Units per order
            ) ORDER BY revenue_rank
        )
        FROM analytics.vw_category_performance
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_category_performance_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 3: Brand Performance (Top 20)
-- ----------------------------------------------------------------------------
\echo '[JSON 3/5] Creating function: get_brand_performance_json()'
\echo '           - Returns top 20 brands by revenue'

CREATE OR REPLACE FUNCTION analytics.get_brand_performance_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'brand', brand,                         -- Brand name
                'category', category,                   -- Category
                'productCount', product_count,          -- Products by brand
                'revenue', net_revenue,                 -- Net revenue
                'unitsSold', total_units_sold,          -- Units sold
                'avgRating', avg_rating,                -- Average rating
                'reviewCount', review_count,            -- Review count
                'categoryMarketShare', category_market_share_pct, -- Market share in category
                'categoryRank', category_rank           -- Rank within category
            ) ORDER BY net_revenue DESC
        )
        FROM analytics.vw_brand_performance
        LIMIT 20                                        -- Top 20 brands only
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_brand_performance_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 4: ABC Classification Summary
-- ----------------------------------------------------------------------------
\echo '[JSON 4/5] Creating function: get_abc_analysis_json()'
\echo '           - Returns ABC classification distribution'

CREATE OR REPLACE FUNCTION analytics.get_abc_analysis_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'classification', json_object_agg(
                abc_classification,
                json_build_object(
                    'productCount', product_count,      -- Products in class
                    'totalRevenue', total_revenue,      -- Total revenue
                    'revenuePercent', revenue_pct,      -- % of total revenue
                    'productsPercent', products_pct     -- % of total products
                )
            )
        )
        FROM (
            SELECT 
                abc_classification,
                COUNT(*) as product_count,
                ROUND(SUM(net_revenue), 2) as total_revenue,
                ROUND(100.0 * SUM(net_revenue) / SUM(SUM(net_revenue)) OVER (), 2) as revenue_pct,
                ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as products_pct
            FROM analytics.mv_abc_analysis
            GROUP BY abc_classification
        ) abc
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_abc_analysis_json()'


-- ----------------------------------------------------------------------------
-- JSON Function 5: Inventory Status Summary
-- ----------------------------------------------------------------------------
\echo '[JSON 5/5] Creating function: get_inventory_status_json()'
\echo '           - Returns inventory status distribution'

CREATE OR REPLACE FUNCTION analytics.get_inventory_status_json()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'status', stock_status,                 -- Stock status
                'productCount', product_count,          -- Products in status
                'avgDaysOfInventory', avg_days_inventory, -- Avg days supply
                'pctOfProducts', pct_of_products        -- % of total products
            ) ORDER BY 
                CASE stock_status
                    WHEN 'Out of Stock' THEN 1
                    WHEN 'Low Stock' THEN 2
                    WHEN 'Normal' THEN 3
                    WHEN 'Overstocked' THEN 4
                    ELSE 5
                END
        )
        FROM (
            SELECT 
                stock_status,
                COUNT(*) as product_count,
                ROUND(AVG(days_of_inventory), 0) as avg_days_inventory,
                ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as pct_of_products
            FROM analytics.vw_inventory_turnover
            GROUP BY stock_status
        ) inv
    );
END;
$$ LANGUAGE plpgsql;

\echo '           ✓ Function created: get_inventory_status_json()'
\echo ''


-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '             PRODUCT ANALYTICS MODULE - SUCCESSFULLY CREATED                '
\echo '============================================================================'
\echo ''
\echo '✅ REGULAR VIEWS (3):'
\echo '   1. vw_category_performance        - Category-level metrics'
\echo '   2. vw_brand_performance           - Brand analysis within categories'
\echo '   3. vw_inventory_turnover          - Stock velocity and status'
\echo ''
\echo '✅ MATERIALIZED VIEWS (2):'
\echo '   1. mv_top_products                - Top products with rankings'
\echo '   2. mv_abc_analysis                - ABC classification (Pareto)'
\echo ''
\echo '✅ JSON EXPORT FUNCTIONS (5):'
\echo '   1. get_top_products_json()        - Top 20 products'
\echo '   2. get_category_performance_json()- All categories'
\echo '   3. get_brand_performance_json()   - Top 20 brands'
\echo '   4. get_abc_analysis_json()        - ABC classification summary'
\echo '   5. get_inventory_status_json()    - Inventory status distribution'
\echo ''
\echo '📊 USAGE EXAMPLES:'
\echo '   -- View top products'
\echo '   SELECT * FROM analytics.mv_top_products WHERE revenue_rank <= 10;'
\echo ''
\echo '   -- Get category data as JSON'
\echo '   SELECT analytics.get_category_performance_json();'
\echo ''
\echo '   -- Export to file'
\echo '   psql -d retailmart -t -A -c "SELECT analytics.get_top_products_json();" > top_products.json'
\echo ''
\echo '============================================================================'
\echo ''