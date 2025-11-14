CREATE MATERIALIZED VIEW sales.mv_order_complete_details as 
SELECT
	-- Order Information
	o.order_id,
	o.order_date,
	o.order_status,
	o.total_amount,
	--Customer Information
	c.cust_id,
	c.full_name as customer_name,
	c.city as customer_city,
	c.state as customer_state,
	c.region_name,
	-- Store Information
	s.store_id,
	s.store_name,
	s.city as store_city,
	s.state as store_state,
	s.region,
	-- Orde Items
	count(DISTINCT oi.prod_id) as unique_products,
	sum(oi.quantity) as total_items,
	sum(oi.quantity* oi.unit_price) as gross_amount,
	sum(oi.quantity* oi.discount) as total_discount,
	--Payment Information
	py.payment_id,
	py.payment_date,
	py.payment_mode,
	py.amount as payment_amount,
	--Shipment Information
	sh.shipment_id,
	sh.courier_name,
	sh.shipped_date,
	sh.delivered_date,
	sh.status as shipment_status,
	-- Custom KPI
	CASE
		WHEN sh.delivered_date IS NOT NULL
		THEN sh.delivered_date - o.order_date
		ELSE NULL
	END as delivery_days,
	CASE
		WHEN o.order_status = 'Delivered' AND sh.delivered_date <=o.order_date + INTERVAL '3 Days'
		THEN 'On Time'
		WHEN o.order_status = 'Delivered' AND sh.delivered_date > o.order_date + INTERVAL '3 Days'
		THEN 'Delayed'
		ELSE 'In Progress'
	END as delivery_performance
FROM sales.orders o
JOIN customers.customers c ON c.cust_id = o.cust_id
JOIN stores.stores s ON s.store_id = o.store_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
-- JOIN products.products p ON p.prod_id = oi.prod_id
JOIN sales.payments py ON py.order_id = o.order_id
JOIN sales.shipments sh ON sh.order_id = o.order_id
GROUP BY
	o.order_id,o.order_date,o.order_status,o.total_amount,c.cust_id,c.full_name,c.city,c.state,c.region_name,
	s.store_id,s.store_name,s.city,s.state,s.region,py.payment_id,py.payment_date,py.payment_mode,py.amount,
	sh.shipment_id,sh.courier_name,sh.shipped_date,sh.delivered_date,sh.status;


select * from sales.mv_order_complete_details


-- Create materialized view for daily sales
CREATE MATERIALIZED VIEW sales.mv_daily_sales_summary AS
SELECT 
    o.order_date,
    s.region as store_region,
    s.state as store_state,
    s.city as store_city,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.cust_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.total_amount) as max_order_value,
    MIN(o.total_amount) as min_order_value,
    -- Additional metrics
    COUNT(DISTINCT CASE WHEN o.order_status = 'Delivered' THEN o.order_id END) as delivered_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'Cancelled' THEN o.order_id END) as cancelled_orders
FROM sales.orders o
INNER JOIN stores.stores s ON o.store_id = s.store_id
GROUP BY o.order_date, s.region, s.state, s.city;

-- Query is SUPER FAST now!
SELECT 
    order_date,
    store_region,
    total_orders,
    ROUND(total_revenue::numeric, 2) as revenue,
    ROUND(avg_order_value::numeric, 2) as avg_order
FROM sales.mv_daily_sales_summary
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY order_date DESC, total_revenue DESC;

-- Region performance last 7 days
SELECT 
    store_region,
    SUM(total_orders) as orders,
    SUM(unique_customers) as customers,
    ROUND(SUM(total_revenue)::numeric, 2) as revenue,
    ROUND(AVG(avg_order_value)::numeric, 2) as avg_order
FROM sales.mv_daily_sales_summary
WHERE order_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY store_region
ORDER BY revenue DESC;

-- Refresh materialized view (run daily at 1 AM)
REFRESH MATERIALIZED VIEW sales.mv_daily_sales_summary;


-- Query 1: Monthly Revenue Trend (Line Chart)
SELECT 
    TO_CHAR(order_date, 'Mon-YY') as month,
    ROUND(SUM(total_amount)::numeric, 2) as revenue
FROM sales.orders
WHERE order_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY TO_CHAR(order_date, 'Mon-YY'), DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date);




-- Store performance matrix
SELECT 
    s.store_name,
    COUNT(o.order_id) as orders,
    ROUND(SUM(o.total_amount)::numeric, 2) as revenue,
    ROUND(AVG(o.total_amount)::numeric, 2) as avg_order,
    COUNT(DISTINCT o.cust_id) as customers,
    CASE 
        WHEN SUM(o.total_amount) >= 500000 THEN 'Excellent'
        WHEN SUM(o.total_amount) >= 300000 THEN 'Good'
        WHEN SUM(o.total_amount) >= 100000 THEN 'Average'
        ELSE 'Needs Attention'
    END as performance_category
FROM stores.stores s
LEFT JOIN sales.orders o ON s.store_id = o.store_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY s.store_name
ORDER BY revenue DESC;






-- Create HTML Dashboard View
CREATE OR REPLACE VIEW sales.vw_html_dashboard AS
SELECT '
<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
        }
        .dashboard {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            text-align: center;
            color: white;
            margin-bottom: 30px;
        }
        .kpi-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .kpi-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            transition: transform 0.3s;
        }
        .kpi-card:hover {
            transform: translateY(-5px);
        }
        .kpi-value {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
            margin: 10px 0;
        }
        .kpi-label {
            font-size: 14px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .kpi-change {
            font-size: 14px;
            margin-top: 10px;
        }
        .positive { color: #10b981; }
        .negative { color: #ef4444; }
        .table-container {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th {
            background: #667eea;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }
        tr:hover {
            background: #f9fafb;
        }
    </style>
</head>
<body>
    <div class="dashboard">
        <div class="header">
            <h1>🏪 RetailMart Executive Dashboard</h1>
            <p>Real-time Business Intelligence</p>
        </div>
        
        <div class="kpi-container">
            <div class="kpi-card">
                <div class="kpi-label">📦 Total Orders</div>
                <div class="kpi-value">' || 
                (SELECT COUNT(*) FROM sales.orders 
                 WHERE order_date >= CURRENT_DATE - INTERVAL '30 days')::text || 
                '</div>
                <div class="kpi-change positive">↑ Last 30 Days</div>
            </div>
            
            <div class="kpi-card">
                <div class="kpi-label">💰 Revenue</div>
                <div class="kpi-value">₹' || 
                (SELECT TO_CHAR(SUM(total_amount), 'FM999,999,999') 
                 FROM sales.orders 
                 WHERE order_date >= CURRENT_DATE - INTERVAL '30 days') || 
                '</div>
                <div class="kpi-change positive">↑ Last 30 Days</div>
            </div>
            
            <div class="kpi-card">
                <div class="kpi-label">👥 Active Customers</div>
                <div class="kpi-value">' || 
                (SELECT COUNT(DISTINCT cust_id) FROM sales.orders 
                 WHERE order_date >= CURRENT_DATE - INTERVAL '30 days')::text || 
                '</div>
                <div class="kpi-change positive">↑ Unique Buyers</div>
            </div>
            
            <div class="kpi-card">
                <div class="kpi-label">📊 Avg Order Value</div>
                <div class="kpi-value">₹' || 
                (SELECT TO_CHAR(AVG(total_amount), 'FM999,999') 
                 FROM sales.orders 
                 WHERE order_date >= CURRENT_DATE - INTERVAL '30 days') || 
                '</div>
                <div class="kpi-change">📈 Per Transaction</div>
            </div>
        </div>
        
        <div class="table-container">
            <h2>🏆 Top 10 Products</h2>
            <table>
                <tr>
                    <th>Product</th>
                    <th>Category</th>
                    <th>Units Sold</th>
                    <th>Revenue</th>
                </tr>' ||
                (SELECT STRING_AGG(
                    '<tr>
                        <td>' || p.prod_name || '</td>
                        <td>' || p.category || '</td>
                        <td>' || SUM(oi.quantity)::text || '</td>
                        <td>₹' || TO_CHAR(SUM(oi.quantity * oi.unit_price), 'FM999,999') || '</td>
                    </tr>', '')
                 FROM sales.order_items oi
                 INNER JOIN products.products p ON oi.prod_id = p.prod_id
                 INNER JOIN sales.orders o ON oi.order_id = o.order_id
                 WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days'
                 GROUP BY p.prod_id, p.prod_name, p.category
                 ORDER BY SUM(oi.quantity * oi.unit_price) DESC
                 LIMIT 10) ||
            '</table>
        </div>
    </div>
</body>
</html>
' as html_dashboard;

-- To use: Copy the output and save as dashboard.html
SELECT * FROM sales.vw_html_dashboard;











-- Daily sales sparkline (last 30 days)
WITH daily_sales AS (
    SELECT 
        order_date,
        SUM(total_amount) as daily_revenue,
        MAX(SUM(total_amount)) OVER () as max_revenue
    FROM sales.orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY order_date
    ORDER BY order_date
)
SELECT 
    'Last 30 Days Revenue Trend' as metric,
    STRING_AGG(
        CASE 
            WHEN daily_revenue >= max_revenue * 0.8 THEN '█'
            WHEN daily_revenue >= max_revenue * 0.6 THEN '▆'
            WHEN daily_revenue >= max_revenue * 0.4 THEN '▄'
            WHEN daily_revenue >= max_revenue * 0.2 THEN '▂'
            ELSE '▁'
        END, 
        '' ORDER BY order_date
    ) as sparkline
FROM daily_sales;
```

**Output:**
```
           metric            |              sparkline              
-----------------------------+-------------------------------------
 Last 30 Days Revenue Trend  | ▄▆█▅▃▂▁▃▅▆█▆▅▄▂▃▅▆█▇▆▅▄▃▂▁▃▄▆█