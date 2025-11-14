-- View for Monthly Revenue Trend
CREATE OR REPLACE VIEW sales.chart_monthly_revenue AS
SELECT 
    DATE_TRUNC('month', order_date) as month,
    TO_CHAR(order_date, 'Mon-YYYY') as month_label,
    COUNT(DISTINCT order_id) as total_orders,
    ROUND(SUM(total_amount)::numeric, 2) as revenue,
    ROUND(AVG(total_amount)::numeric, 2) as avg_order_value
FROM sales.orders
WHERE order_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', order_date), TO_CHAR(order_date, 'Mon-YYYY')
ORDER BY month;

-- Query it
SELECT * FROM sales.chart_monthly_revenue;