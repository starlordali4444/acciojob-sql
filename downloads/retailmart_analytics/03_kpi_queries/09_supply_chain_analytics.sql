-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 03_kpi_queries/09_supply_chain_analytics.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Supply Chain & Manufacturing — Warehouses, Suppliers, Production
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3) — 🆕 NEW MODULE
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- DESCRIPTION:
--   Supply chain is the backbone of retail. At Amazon, they track:
--   - Warehouse capacity and utilization
--   - Supplier reliability and SLA compliance
--   - Inbound shipment tracking
--   - Production efficiency and quality
--
-- SOURCE TABLES:
--   supply_chain.warehouses, supply_chain.shipments, supply_chain.inventory_snapshots,
--   manufacture.production_lines, manufacture.work_orders,
--   products.suppliers, products.products
--
-- CREATES: 7 Views + 1 MV + 2 JSON Functions
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '     SUPPLY CHAIN & MANUFACTURING MODULE (V2) — STARTING                    '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- VIEW 1: WAREHOUSE UTILIZATION
-- ============================================================================

\echo '[1/8] Creating view: vw_warehouse_utilization...'

CREATE OR REPLACE VIEW analytics.vw_warehouse_utilization AS
WITH latest_snapshot AS (
    SELECT DISTINCT ON (warehouse_id, product_id)
        warehouse_id, product_id, quantity_on_hand, snapshot_date
    FROM supply_chain.inventory_snapshots
    ORDER BY warehouse_id, product_id, snapshot_date DESC
),
warehouse_inventory AS (
    SELECT 
        ls.warehouse_id,
        COUNT(DISTINCT ls.product_id) as products_stored,
        SUM(ls.quantity_on_hand) as total_units,
        MAX(ls.snapshot_date) as latest_snapshot
    FROM latest_snapshot ls
    GROUP BY ls.warehouse_id
)
SELECT 
    w.warehouse_id,
    w.name as warehouse_name,
    w.location_city,
    w.region,
    w.capacity_sqft,
    w.manager_name,
    COALESCE(wi.products_stored, 0) as products_stored,
    COALESCE(wi.total_units, 0) as total_units,
    wi.latest_snapshot,
    -- Inbound shipments
    COALESCE(incoming.pending_shipments, 0) as pending_inbound,
    COALESCE(incoming.total_incoming_qty, 0) as incoming_quantity,
    RANK() OVER (ORDER BY COALESCE(wi.total_units, 0) DESC) as inventory_rank
FROM supply_chain.warehouses w
LEFT JOIN warehouse_inventory wi ON w.warehouse_id = wi.warehouse_id
LEFT JOIN (
    SELECT warehouse_id, COUNT(*) as pending_shipments, SUM(quantity) as total_incoming_qty
    FROM supply_chain.shipments WHERE status IN ('Shipped', 'In Transit')
    GROUP BY warehouse_id
) incoming ON w.warehouse_id = incoming.warehouse_id
ORDER BY total_units DESC;

COMMENT ON VIEW analytics.vw_warehouse_utilization IS 'Warehouse inventory levels and pending inbound';
\echo '      ✓ View created: vw_warehouse_utilization'


-- ============================================================================
-- VIEW 2: SUPPLIER SLA PERFORMANCE
-- ============================================================================

\echo '[2/8] Creating view: vw_supplier_sla_performance...'

CREATE OR REPLACE VIEW analytics.vw_supplier_sla_performance AS
WITH supplier_metrics AS (
    SELECT 
        sup.supplier_id,
        sup.supplier_name,
        sup.city as supplier_city,
        COUNT(DISTINCT sc.shipment_id) as total_shipments,
        SUM(sc.quantity) as total_units_shipped,
        COUNT(*) FILTER (WHERE sc.status = 'Delivered') as delivered_shipments,
        COUNT(*) FILTER (WHERE sc.status IN ('Shipped', 'In Transit')) as in_transit,
        AVG(sc.arrival_date - sc.shipped_date) as avg_delivery_days,
        COUNT(*) FILTER (WHERE (sc.arrival_date - sc.shipped_date) <= 
            (SELECT analytics.get_config_number('alert_supplier_sla_days'))) as on_time_deliveries,
        COUNT(*) FILTER (WHERE (sc.arrival_date - sc.shipped_date) > 
            (SELECT analytics.get_config_number('alert_supplier_sla_days'))) as late_deliveries,
        COUNT(DISTINCT sc.product_id) as unique_products
    FROM products.suppliers sup
    LEFT JOIN supply_chain.shipments sc ON sup.supplier_id = sc.supplier_id
    GROUP BY sup.supplier_id, sup.supplier_name, sup.city
)
SELECT 
    supplier_id, supplier_name, supplier_city,
    total_shipments, total_units_shipped, delivered_shipments, in_transit,
    ROUND(avg_delivery_days::NUMERIC, 1) as avg_delivery_days,
    on_time_deliveries, late_deliveries,
    ROUND((on_time_deliveries::NUMERIC / NULLIF(delivered_shipments, 0) * 100), 2) as on_time_pct,
    unique_products,
    CASE 
        WHEN (on_time_deliveries::NUMERIC / NULLIF(delivered_shipments, 0) * 100) >= 95 THEN 'Excellent'
        WHEN (on_time_deliveries::NUMERIC / NULLIF(delivered_shipments, 0) * 100) >= 80 THEN 'Good'
        WHEN (on_time_deliveries::NUMERIC / NULLIF(delivered_shipments, 0) * 100) >= 60 THEN 'Needs Improvement'
        ELSE 'Poor'
    END as sla_rating,
    RANK() OVER (ORDER BY on_time_deliveries::NUMERIC / NULLIF(delivered_shipments, 0) DESC NULLS LAST) as reliability_rank
FROM supplier_metrics
ORDER BY total_shipments DESC;

COMMENT ON VIEW analytics.vw_supplier_sla_performance IS 'Supplier delivery reliability and SLA compliance';
\echo '      ✓ View created: vw_supplier_sla_performance'


-- ============================================================================
-- VIEW 3: INBOUND SHIPMENT TRACKING
-- ============================================================================

\echo '[3/8] Creating view: vw_inbound_shipment_tracking...'

CREATE OR REPLACE VIEW analytics.vw_inbound_shipment_tracking AS
SELECT 
    DATE_TRUNC('month', sc.shipped_date)::DATE as ship_month,
    TO_CHAR(DATE_TRUNC('month', sc.shipped_date), 'Mon YYYY') as month_name,
    sc.status,
    COUNT(*) as shipment_count,
    SUM(sc.quantity) as total_quantity,
    COUNT(DISTINCT sc.supplier_id) as unique_suppliers,
    COUNT(DISTINCT sc.warehouse_id) as destination_warehouses,
    ROUND(AVG(sc.arrival_date - sc.shipped_date)::NUMERIC, 1) as avg_transit_days
FROM supply_chain.shipments sc
WHERE sc.shipped_date IS NOT NULL
GROUP BY DATE_TRUNC('month', sc.shipped_date), sc.status
ORDER BY ship_month DESC, status;

COMMENT ON VIEW analytics.vw_inbound_shipment_tracking IS 'Inbound shipment volume and transit times';
\echo '      ✓ View created: vw_inbound_shipment_tracking'


-- ============================================================================
-- VIEW 4: WAREHOUSE INVENTORY TREND
-- ============================================================================

\echo '[4/8] Creating view: vw_warehouse_inventory_trend...'

CREATE OR REPLACE VIEW analytics.vw_warehouse_inventory_trend AS
SELECT 
    w.name as warehouse_name,
    w.location_city,
    iss.snapshot_date,
    COUNT(DISTINCT iss.product_id) as products_in_stock,
    SUM(iss.quantity_on_hand) as total_units,
    -- Compare with previous snapshot
    LAG(SUM(iss.quantity_on_hand)) OVER (PARTITION BY iss.warehouse_id ORDER BY iss.snapshot_date) as prev_snapshot_units,
    SUM(iss.quantity_on_hand) - COALESCE(LAG(SUM(iss.quantity_on_hand)) OVER (PARTITION BY iss.warehouse_id ORDER BY iss.snapshot_date), 0) as unit_change
FROM supply_chain.inventory_snapshots iss
JOIN supply_chain.warehouses w ON iss.warehouse_id = w.warehouse_id
GROUP BY iss.warehouse_id, w.name, w.location_city, iss.snapshot_date
ORDER BY w.name, iss.snapshot_date DESC;

COMMENT ON VIEW analytics.vw_warehouse_inventory_trend IS 'Inventory level changes over time by warehouse';
\echo '      ✓ View created: vw_warehouse_inventory_trend'


-- ============================================================================
-- VIEW 5: PRODUCTION LINE EFFICIENCY
-- ============================================================================

\echo '[5/8] Creating view: vw_production_line_efficiency...'

CREATE OR REPLACE VIEW analytics.vw_production_line_efficiency AS
SELECT 
    pl.line_id,
    pl.line_name,
    pl.capacity_per_hour,
    pl.supervisor_name,
    COUNT(wo.work_order_id) as total_work_orders,
    COUNT(wo.work_order_id) FILTER (WHERE wo.status = 'Completed') as completed_orders,
    COUNT(wo.work_order_id) FILTER (WHERE wo.status = 'In Progress') as in_progress,
    SUM(wo.quantity_produced) as total_produced,
    SUM(wo.rejected_quantity) as total_rejected,
    ROUND((SUM(wo.rejected_quantity)::NUMERIC / NULLIF(SUM(wo.quantity_produced), 0) * 100), 2) as reject_rate_pct,
    -- Average time per work order (hours)
    ROUND(AVG(EXTRACT(EPOCH FROM (wo.end_timestamp - wo.start_timestamp)) / 3600)::NUMERIC, 1) as avg_hours_per_order,
    -- Effective output rate vs capacity
    ROUND((SUM(wo.quantity_produced)::NUMERIC / 
           NULLIF(SUM(EXTRACT(EPOCH FROM (wo.end_timestamp - wo.start_timestamp)) / 3600), 0))::NUMERIC, 1) as actual_output_per_hour,
    ROUND(((SUM(wo.quantity_produced)::NUMERIC / 
           NULLIF(SUM(EXTRACT(EPOCH FROM (wo.end_timestamp - wo.start_timestamp)) / 3600), 0)) / 
           NULLIF(pl.capacity_per_hour, 0) * 100)::NUMERIC, 1) as capacity_utilization_pct
FROM manufacture.production_lines pl
LEFT JOIN manufacture.work_orders wo ON pl.line_id = wo.line_id
GROUP BY pl.line_id, pl.line_name, pl.capacity_per_hour, pl.supervisor_name
ORDER BY total_produced DESC;

COMMENT ON VIEW analytics.vw_production_line_efficiency IS 'Production line output, reject rates, and capacity utilization';
\echo '      ✓ View created: vw_production_line_efficiency'


-- ============================================================================
-- VIEW 6: PRODUCTION QUALITY
-- ============================================================================

\echo '[6/8] Creating view: vw_production_quality...'

CREATE OR REPLACE VIEW analytics.vw_production_quality AS
WITH quality_by_product AS (
    SELECT 
        p.product_id,
        p.product_name,
        cat.category_name as category,
        SUM(wo.quantity_produced) as total_produced,
        SUM(wo.rejected_quantity) as total_rejected,
        ROUND((SUM(wo.rejected_quantity)::NUMERIC / NULLIF(SUM(wo.quantity_produced), 0) * 100), 2) as reject_rate_pct,
        COUNT(wo.work_order_id) as work_orders
    FROM manufacture.work_orders wo
    JOIN products.products p ON wo.product_id = p.product_id
    JOIN core.dim_brand b ON p.brand_id = b.brand_id
    JOIN core.dim_category cat ON b.category_id = cat.category_id
    GROUP BY p.product_id, p.product_name, cat.category_name
)
SELECT 
    product_id, product_name, category,
    total_produced, total_rejected, reject_rate_pct, work_orders,
    CASE 
        WHEN reject_rate_pct > (SELECT analytics.get_config_number('alert_production_reject_pct')) THEN 'High Reject'
        WHEN reject_rate_pct > 2 THEN 'Moderate'
        ELSE 'Good'
    END as quality_status,
    RANK() OVER (ORDER BY reject_rate_pct DESC) as worst_quality_rank
FROM quality_by_product
ORDER BY reject_rate_pct DESC;

COMMENT ON VIEW analytics.vw_production_quality IS 'Product quality — reject rates flagged against threshold';
\echo '      ✓ View created: vw_production_quality'


-- ============================================================================
-- VIEW 7: PRODUCTION SCHEDULE
-- ============================================================================

\echo '[7/8] Creating view: vw_production_schedule...'

CREATE OR REPLACE VIEW analytics.vw_production_schedule AS
SELECT 
    wo.status,
    COUNT(*) as order_count,
    SUM(wo.quantity_produced) as total_produced,
    SUM(wo.rejected_quantity) as total_rejected,
    ROUND(AVG(EXTRACT(EPOCH FROM (wo.end_timestamp - wo.start_timestamp)) / 3600)::NUMERIC, 1) as avg_hours,
    MIN(wo.start_timestamp) as earliest_start,
    MAX(wo.end_timestamp) as latest_end,
    ROUND((COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100), 2) as pct_of_orders
FROM manufacture.work_orders wo
GROUP BY wo.status
ORDER BY order_count DESC;

COMMENT ON VIEW analytics.vw_production_schedule IS 'Work order status distribution and timing';
\echo '      ✓ View created: vw_production_schedule'


-- ============================================================================
-- MATERIALIZED VIEW: SUPPLY CHAIN SUMMARY
-- ============================================================================

\echo '[8/8] Creating materialized view: mv_supply_chain_summary...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_supply_chain_summary CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_supply_chain_summary AS
WITH warehouse_stats AS (
    SELECT 
        COUNT(*) as total_warehouses,
        SUM(capacity_sqft) as total_capacity_sqft
    FROM supply_chain.warehouses
),
shipment_stats AS (
    SELECT 
        COUNT(*) as total_inbound_shipments,
        COUNT(*) FILTER (WHERE status = 'Delivered') as delivered,
        COUNT(*) FILTER (WHERE status IN ('Shipped', 'In Transit')) as in_transit,
        ROUND(AVG(arrival_date - shipped_date)::NUMERIC, 1) as avg_transit_days,
        SUM(quantity) as total_units_shipped
    FROM supply_chain.shipments
    WHERE shipped_date IS NOT NULL
),
supplier_stats AS (
    SELECT 
        COUNT(DISTINCT supplier_id) as active_suppliers
    FROM supply_chain.shipments
),
production_stats AS (
    SELECT 
        COUNT(*) as total_work_orders,
        SUM(quantity_produced) as total_produced,
        SUM(rejected_quantity) as total_rejected,
        ROUND((SUM(rejected_quantity)::NUMERIC / NULLIF(SUM(quantity_produced), 0) * 100), 2) as overall_reject_rate
    FROM manufacture.work_orders
)
SELECT 
    CURRENT_DATE as reference_date,
    ws.total_warehouses, ws.total_capacity_sqft,
    ss.total_inbound_shipments, ss.delivered as inbound_delivered, ss.in_transit as inbound_in_transit,
    ss.avg_transit_days, ss.total_units_shipped,
    sups.active_suppliers,
    ps.total_work_orders, ps.total_produced, ps.total_rejected, ps.overall_reject_rate
FROM warehouse_stats ws
CROSS JOIN shipment_stats ss
CROSS JOIN supplier_stats sups
CROSS JOIN production_stats ps;

COMMENT ON MATERIALIZED VIEW analytics.mv_supply_chain_summary IS 'Supply chain and manufacturing KPI summary';
\echo '      ✓ Materialized view created: mv_supply_chain_summary'


-- ============================================================================
-- JSON EXPORT FUNCTIONS
-- ============================================================================

\echo ''
\echo 'Creating JSON export functions...'

CREATE OR REPLACE FUNCTION analytics.get_supply_chain_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'summary', (SELECT row_to_json(t) FROM analytics.mv_supply_chain_summary t),
    'warehouses', (
        SELECT json_agg(json_build_object(
            'name', warehouse_name, 'city', location_city, 'region', region,
            'products', products_stored, 'units', total_units, 'pendingInbound', pending_inbound
        ) ORDER BY total_units DESC)
        FROM analytics.vw_warehouse_utilization
    ),
    'suppliers', (
        SELECT json_agg(json_build_object(
            'name', supplier_name, 'shipments', total_shipments,
            'avgDays', avg_delivery_days, 'onTimePct', on_time_pct, 'rating', sla_rating
        ) ORDER BY reliability_rank)
        FROM analytics.vw_supplier_sla_performance LIMIT 15
    )
); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_manufacturing_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'productionLines', (
        SELECT json_agg(json_build_object(
            'line', line_name, 'supervisor', supervisor_name, 'capacity', capacity_per_hour,
            'produced', total_produced, 'rejected', total_rejected, 'rejectRate', reject_rate_pct,
            'utilization', capacity_utilization_pct
        ) ORDER BY total_produced DESC)
        FROM analytics.vw_production_line_efficiency
    ),
    'qualityIssues', (
        SELECT json_agg(json_build_object(
            'product', product_name, 'category', category,
            'produced', total_produced, 'rejected', total_rejected,
            'rejectRate', reject_rate_pct, 'status', quality_status
        ) ORDER BY reject_rate_pct DESC)
        FROM analytics.vw_production_quality WHERE quality_status != 'Good' LIMIT 20
    ),
    'schedule', (
        SELECT json_agg(json_build_object(
            'status', status, 'orders', order_count, 'produced', total_produced, 'pct', pct_of_orders
        ))
        FROM analytics.vw_production_schedule
    )
); END;
$$ LANGUAGE plpgsql STABLE;

\echo '      ✓ JSON functions created (2 functions)'

REFRESH MATERIALIZED VIEW analytics.mv_supply_chain_summary;

\echo ''
\echo '============================================================================'
\echo '     SUPPLY CHAIN & MANUFACTURING MODULE (V2) — COMPLETE                    '
\echo '============================================================================'
\echo ''
\echo '✅ Views (7): warehouse utilization, supplier SLA, inbound tracking,'
\echo '   inventory trend, production efficiency, production quality, schedule'
\echo '✅ MVs (1): mv_supply_chain_summary'
\echo '✅ JSON (2): supply_chain, manufacturing'
\echo ''
\echo '➡️  Next: Run 04_alerts/business_alerts.sql'
\echo '============================================================================'
\echo ''
