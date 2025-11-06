-- ================================================
-- Day 5: Aggregate Functions & Grouping
-- Level: HARD (100 Questions)
-- Topics: Complex Aggregations, Multi-table Analysis, Business Intelligence Queries
-- ================================================

-- ## HARD

-- Q1: Find customers who have spent more than the average order amount, showing customer name, total spending, and order count from customers.customers and sales.orders.

-- Q2: Identify stores where total sales in 2024 exceeded ₹50 lakh and had more than 200 orders from sales.orders and stores.stores.

-- Q3: Calculate the sales growth percentage for each store comparing Q1 2024 vs Q4 2024 from sales.orders and stores.stores.

-- Q4: Find products available in all stores, showing product name and total stock across stores from products.products and products.inventory.

-- Q5: Identify customers who placed orders in every quarter of 2024 from customers.customers and sales.orders.

-- Q6: Calculate the customer retention rate by finding customers who ordered in both January and December 2024 from sales.orders.

-- Q7: Find the top performing product in each category based on total revenue from sales.order_items and products.products.

-- Q8: Identify products with declining sales trend by comparing Q1 vs Q4 2024 quantities from sales.order_items and sales.orders.

-- Q9: Calculate the average basket size (items per order) for each store and identify stores above average from sales.orders and sales.order_items.

-- Q10: Find categories where the price variance (max price - min price) exceeds ₹10000 and have at least 20 products from products.products.

-- Q11: Identify customers who ordered from more than 5 different stores and spent over ₹1 lakh total from customers.customers and sales.orders.

-- Q12: Calculate revenue per product for each store from sales.orders, sales.order_items, and products.inventory.

-- Q13: Find suppliers who supply products in the top 3 revenue-generating categories from products.suppliers, products.products, and sales.order_items.

-- Q14: Identify stores where average employee salary is above the overall company average from stores.employees.

-- Q15: Calculate customer lifetime value for customers who joined in 2023: total orders, spending, and average order value from customers.customers and sales.orders.

-- Q16: Find products that are low stock (stock_qty < 5) in more than 50% of stores from products.inventory and stores.stores.

-- Q17: Identify the most profitable product in each category based on revenue (quantity * unit_price) from sales.order_items and products.products.

-- Q18: Calculate the review-to-purchase ratio: products with many reviews but low sales from customers.reviews and sales.order_items.

-- Q19: Find stores with above-average order value but below-average order count in their state from sales.orders and stores.stores.

-- Q20: Identify seasonal patterns by calculating quarterly sales averages across all years from sales.orders.

-- Q21: Find product pairs frequently bought together (appearing in same order_id) from sales.order_items.

-- Q22: Calculate the salary-to-revenue ratio for each department per store from stores.employees and sales.orders.

-- Q23: Identify customers whose spending increased by more than 50% between 2023 and 2024 from sales.orders.

-- Q24: Calculate inventory turnover rate (quantity sold / average stock) for each product from sales.order_items and products.inventory.

-- Q25: Find top 5 customer segments by revenue: group by city, gender, and age group (18-30, 31-45, 46+) from customers.customers and sales.orders.

-- Q26: Identify products with high return rates (returns > 10% of total orders) from sales.order_items and sales.returns.

-- Q27: Calculate ROI for each campaign: revenue during campaign vs campaign budget from marketing.campaigns and sales.orders.

-- Q28: Find stores that ranked in top 25% by sales in every month of 2024 from sales.orders.

-- Q29: Calculate sell-through rate (sold quantity / stock quantity) for each supplier's products from products.products, sales.order_items, and products.inventory.

-- Q30: Identify customer churn: customers who ordered in Q1 2024 but not in Q4 2024 from sales.orders.

-- Q31: Find products where average discount exceeds 15% and calculate revenue impact from sales.order_items.

-- Q32: Identify inventory imbalances: high stock for slow-selling products per store from products.inventory and sales.order_items.

-- Q33: Calculate customer acquisition value: average first order amount by join month from customers.customers and sales.orders.

-- Q34: Find categories with repeat purchase rate above 60% (customers ordering same category multiple times) from sales.orders and sales.order_items.

-- Q35: Calculate average order value by day of week (extract from order_date) from sales.orders.

-- Q36: Find product category diversity per store: count unique categories in inventory from products.inventory and products.products.

-- Q37: Identify customers with high order value variance (some very high, some very low orders) from sales.orders.

-- Q38: Find top 10 peak shopping dates by both order count and total revenue in 2024 from sales.orders.

-- Q39: Calculate employee productivity: store revenue per employee for each store from sales.orders and stores.employees.

-- Q40: Find pricing anomalies: where unit_price in orders differs by more than 10% from product price from sales.order_items and products.products.

-- Q41: Compare category performance across regions: sales by category and region from sales.orders, sales.order_items, stores.stores, and products.products.

-- Q42: Segment customers by lifetime value: low (< ₹10000), medium (₹10000-50000), high (> ₹50000) and analyze from sales.orders.

-- Q43: Find stores with best inventory efficiency: highest sales per unit of average stock from sales.orders and products.inventory.

-- Q44: Identify brand-loyal customers: customers buying 80%+ orders from single brand with 10+ orders from sales.orders, sales.order_items, and products.products.

-- Q45: Analyze payment preferences by customer demographics: age group and gender from sales.payments, sales.orders, and customers.customers.

-- Q46: Calculate price elasticity: correlation between discount % and quantity sold for products from sales.order_items.

-- Q47: Find underperforming stores: below regional average in both sales and order count from sales.orders and stores.stores.

-- Q48: Identify dormant customers: no orders in last 6 months but were active before from sales.orders and customers.customers.

-- Q49: Find suppliers with quality concerns: higher than average product return rates from products.suppliers, products.products, and sales.returns.

-- Q50: Calculate revenue concentration: percentage of total revenue from top 10% customers from sales.orders.

-- Q51: Analyze promotional effectiveness: sales during promo period vs non-promo period by category from sales.orders, sales.order_items, and products.promotions.

-- Q52: Determine optimal stock levels: products with excess stock (> 3 months of sales) or stockouts from products.inventory and sales.order_items.

-- Q53: Find complementary categories: category pairs frequently bought together in orders from sales.order_items and products.products.

-- Q54: Calculate RFM score: recency, frequency, and monetary value for customer segmentation from sales.orders and customers.customers.

-- Q55: Identify stores with seasonal variance: high coefficient of variation in monthly sales from sales.orders and stores.stores.

-- Q56: Analyze customer cohorts: group by join month and calculate lifetime value from customers.customers and sales.orders.

-- Q57: Calculate average days between repeat purchases by customer spending tier from sales.orders.

-- Q58: Find browse-to-buy gap: products with many reviews but low sales conversion from customers.reviews and sales.order_items.

-- Q59: Identify geographic expansion opportunities: high-value states with low store density from sales.orders, customers.customers, and stores.stores.

-- Q60: Calculate break-even analysis: cumulative revenue vs cumulative expenses by store from sales.orders and stores.expenses.

-- Q61: Evaluate marketing channel effectiveness: conversion rate and cost per acquisition from marketing.ads_spend and sales.orders.

-- Q62: Find supplier price consistency: products with high price variance over time from products.products.

-- Q63: Calculate customer concentration per store: % of sales from top 20% customers from sales.orders.

-- Q64: Analyze department staffing efficiency: compare current vs average headcount needs from stores.employees.

-- Q65: Identify upsell opportunities: products frequently bought individually that could be bundled from sales.order_items.

-- Q66: Calculate regional category preference: which categories overperform in specific regions vs national average from sales.orders, sales.order_items, stores.stores, and products.products.

-- Q67: Find at-risk customers: declining order frequency and value over last 4 quarters from sales.orders.

-- Q68: Identify discount-dependent customers: customers who only buy during high-discount periods from sales.orders and sales.order_items.

-- Q69: Categorize product lifecycle: growth, mature, or declining based on quarterly sales trends from sales.order_items and sales.orders.

-- Q70: Analyze store-product affinity: products performing exceptionally well in specific stores from sales.orders, sales.order_items, and stores.stores.

-- Q71: Track customer segment migration: movement from low to high value segments over time from sales.orders and customers.customers.

-- Q72: Calculate carrying cost impact: products with high stock but low sales velocity from products.inventory and sales.order_items.

-- Q73: Find recession-resistant categories: consistent sales despite market fluctuations from sales.order_items and sales.orders.

-- Q74: Calculate cross-sell attachment rate: frequency of category pairs in orders from sales.order_items and products.products.

-- Q75: Measure customer winback rate: churned customers who returned within 6 months from sales.orders.

-- Q76: Evaluate optimal store staffing: stores meeting ₹10 lakh revenue per employee benchmark from sales.orders and stores.employees.

-- Q77: Identify product cannibalization: new products negatively impacting existing product sales from sales.order_items and products.products.

-- Q78: Estimate wallet share: RetailMart spending vs estimated total customer retail spending from sales.orders and customers.customers.

-- Q79: Analyze delivery impact on retention: correlation between delivery time and repeat purchases from sales.shipments and sales.orders.

-- Q80: Find pricing optimization opportunities: high-demand products priced below category average from products.products and sales.order_items.

-- Q81: Perform Pareto analysis: 80/20 rule for products contributing to revenue from sales.order_items and products.products.

-- Q82: Identify high-potential customers: frequent buyers with low average order value (upsell targets) from sales.orders.

-- Q83: Evaluate marketing spend efficiency: campaigns with high cost but low revenue contribution from marketing.campaigns, marketing.ads_spend, and sales.orders.

-- Q84: Analyze store cannibalization: overlapping catchment areas hurting performance from stores.stores and sales.orders.

-- Q85: Correlate quality and price: relationship between price point and return rates by category from products.products and sales.returns.

-- Q86: Calculate customer acquisition channel value based on CLV from customers.customers and sales.orders.

-- Q87: Evaluate demand forecast accuracy: actual vs predicted sales patterns for products from sales.order_items.

-- Q88: Find untapped market stores: underperforming stores in high-spending customer areas from stores.stores, sales.orders, and customers.customers.

-- Q89: Identify premium customer segments: consistently high order values with low price sensitivity from sales.orders and sales.order_items.

-- Q90: Calculate SKU productivity: sales per product per store from sales.order_items and products.inventory.

-- Q91: Measure loyalty program impact: spending comparison of loyalty vs non-loyalty customers from customers.loyalty_points, customers.customers, and sales.orders.

-- Q92: Identify trend-setters: early adopters of new products who influence wider adoption from sales.orders and sales.order_items.

-- Q93: Analyze brand regional strength: market share and growth by region for brands from sales.order_items, products.products, and stores.stores.

-- Q94: Optimize pricing strategy: elasticity analysis at different price points by category from sales.order_items and products.products.

-- Q95: Study multi-store shopping behavior: customers ordering across multiple locations from sales.orders and customers.customers.

-- Q96: Calculate staff-to-customer efficiency: employees vs unique customers per store from stores.employees and sales.orders.

-- Q97: Identify export-ready products: high-margin items with low market penetration from products.products, sales.order_items, and products.inventory.

-- Q98: Analyze rating-sales paradox: high-rated low-sales vs low-rated high-sales products from customers.reviews and sales.order_items.

-- Q99: Compare store format effectiveness: large vs small format performance (by employee count) from stores.employees, stores.stores, and sales.orders.

-- Q100: Identify ultimate revenue drivers: top customers, products, and stores contributing 80% of revenue using Pareto principle from sales.orders, sales.order_items, customers.customers, and stores.stores.
