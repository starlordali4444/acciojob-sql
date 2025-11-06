-- ================================================
-- Day 7: Joins (Foundations & Advanced)
-- Level: HARD (100 Questions)
-- Topics: Advanced Multi-table Joins, Complex Analytics, Join Optimization
-- ================================================

-- ## HARD

-- Q1: Find customers who have purchased products from at least 5 different categories, showing customer details, category count, and total spending across categories from customers.customers, sales.orders, sales.order_items, and products.products.

-- Q2: Identify products that are bestsellers in one region but poor performers in another, comparing sales volumes across regions from products.products, sales.order_items, sales.orders, stores.stores, and core.dim_region.

-- Q3: Calculate customer cohort analysis: group customers by join month and track their purchasing behavior over subsequent months from customers.customers, sales.orders, and sales.order_items.

-- Q4: Find employees whose stores consistently rank in top 20% by monthly sales, showing employee details and store performance metrics from stores.employees, stores.stores, and sales.orders.

-- Q5: Identify product pairs frequently purchased together (market basket analysis), showing pair frequency and combined revenue from sales.order_items, sales.orders, and products.products.

-- Q6: Calculate supplier dependency risk: identify products where single supplier accounts for >80% of category supply from products.suppliers, products.products, core.dim_category, and sales.order_items.

-- Q7: Find customers showing churn signals: decreasing order frequency and value over last 4 quarters compared to their historical average from customers.customers and sales.orders.

-- Q8: Identify stores with inventory-sales mismatch: high stock of slow-moving items and low stock of fast-moving items from stores.stores, products.inventory, sales.order_items, and products.products.

-- Q9: Calculate marketing attribution: trace customer journey from campaign touch to final purchase, attributing revenue across touchpoints from marketing.campaigns, marketing.email_clicks, customers.customers, sales.orders, and sales.order_items.

-- Q10: Find pricing anomalies: products where average selling price varies by more than 15% across different stores from products.products, sales.order_items, sales.orders, and stores.stores.

-- Q11: Identify cross-selling opportunities: customers who bought category A but never category B, where A-B is a common combination from customers.customers, sales.orders, sales.order_items, and products.products.

-- Q12: Calculate employee retention impact: correlate employee tenure with store performance and customer satisfaction from stores.employees, stores.stores, sales.orders, and customers.reviews.

-- Q13: Find products with declining sales trend but increasing inventory, indicating overstock risk from products.products, products.inventory, sales.order_items, and sales.orders.

-- Q14: Identify premium customer segments: high spenders who also write reviews and have low return rates from customers.customers, sales.orders, customers.reviews, and sales.returns.

-- Q15: Calculate supply chain efficiency: average time from order to delivery by supplier-store combination from products.suppliers, products.products, sales.order_items, sales.orders, sales.shipments, and stores.stores.

-- Q16: Find complementary products: items frequently purchased within same order but from different categories from sales.order_items, sales.orders, products.products, and core.dim_category.

-- Q17: Identify seasonal staffing patterns: correlate employee count with sales volume across months and stores from stores.employees, stores.stores, and sales.orders.

-- Q18: Calculate customer wallet share: estimate total retail spending vs RetailMart spending by analyzing purchase patterns from customers.customers, sales.orders, and sales.order_items.

-- Q19: Find underperforming product-store combinations: products that sell well overall but poorly in specific stores from products.products, sales.order_items, sales.orders, and stores.stores.

-- Q20: Identify campaign synergies: customers exposed to multiple campaigns showing higher conversion and order value from customers.customers, marketing.email_clicks, marketing.campaigns, and sales.orders.

-- Q21: Analyze return patterns: identify products with high return rates in specific stores or customer segments from products.products, sales.returns, sales.orders, stores.stores, and customers.customers.

-- Q22: Calculate inventory optimization: identify products needing rebalancing between stores based on sales velocity from products.inventory, sales.order_items, sales.orders, products.products, and stores.stores.

-- Q23: Find customer migration patterns: customers shifting spend from one category to another over time from customers.customers, sales.orders, sales.order_items, and products.products.

-- Q24: Identify profit leakage: orders with high discounts, low margins, or frequent returns from sales.orders, sales.order_items, products.products, and sales.returns.

-- Q25: Calculate brand loyalty: customers who consistently purchase same brands, showing brand preference strength from customers.customers, sales.orders, sales.order_items, products.products, and core.dim_brand.

-- Q26: Find delivery performance impact: correlate delivery times with customer repeat purchase rates from sales.shipments, sales.orders, and customers.customers.

-- Q27: Identify category cannibalization: new product launches negatively impacting existing product sales within category from products.products, sales.order_items, sales.orders, and core.dim_category.

-- Q28: Calculate store traffic patterns: analyze order timing and volume to identify peak hours by store from sales.orders and stores.stores.

-- Q29: Find supplier quality issues: correlate return rates with suppliers across product categories from products.suppliers, products.products, sales.returns, and sales.order_items.

-- Q30: Identify high-value dormant customers: previously big spenders who haven't ordered recently, with reactivation potential from customers.customers and sales.orders.

-- Q31: Build customer RFM scoring: Recency, Frequency, Monetary value with segment classification from customers.customers and sales.orders.

-- Q32: Create product performance matrix: sales volume vs profit margin classification from products.products, sales.order_items, and sales.orders.

-- Q33: Analyze geographic expansion opportunity: identify underserved cities with high customer concentration from customers.customers, stores.stores, and sales.orders.

-- Q34: Calculate employee productivity variance: identify top and bottom performers by sales per employee from stores.employees, stores.stores, and sales.orders.

-- Q35: Find optimal product assortment: identify products contributing to 80% of revenue (Pareto analysis) by store from stores.stores, sales.orders, sales.order_items, and products.products.

-- Q36: Identify payment fraud patterns: unusual payment behaviors indicating potential fraud from sales.payments, sales.orders, and customers.customers.

-- Q37: Calculate campaign incrementality: revenue from campaign-exposed customers vs control group from marketing.campaigns, marketing.email_clicks, customers.customers, and sales.orders.

-- Q38: Find pricing optimization opportunities: products with high demand elasticity (price-quantity relationship) from products.products, sales.order_items, and sales.orders.

-- Q39: Identify customer service quality issues: stores with high return rates and low review ratings from stores.stores, sales.orders, sales.returns, and customers.reviews.

-- Q40: Calculate inventory carrying costs: identify products with high stock but low sales velocity from products.inventory, sales.order_items, products.products, and stores.stores.

-- Q41: Find regional preference patterns: products overperforming in specific regions vs national average from products.products, sales.order_items, sales.orders, stores.stores, and core.dim_region.

-- Q42: Identify bundling opportunities: product combinations with higher margins and conversion rates from sales.order_items, sales.orders, and products.products.

-- Q43: Calculate customer acquisition cost by channel: marketing spend per new customer acquired from marketing.campaigns, marketing.ads_spend, customers.customers, and sales.orders.

-- Q44: Find category management opportunities: underperforming categories needing attention from products.products, core.dim_category, sales.order_items, and sales.orders.

-- Q45: Identify store format effectiveness: compare performance across different store sizes and formats from stores.stores, stores.employees, sales.orders, and products.inventory.

-- Q46: Calculate supplier concentration risk: stores heavily dependent on few suppliers from products.suppliers, products.products, products.inventory, stores.stores, and sales.order_items.

-- Q47: Find customer lifetime value prediction: model future value based on current behavior patterns from customers.customers, sales.orders, customers.reviews, and customers.loyalty_points.

-- Q48: Identify markdown effectiveness: analyze discount impact on sales velocity and profitability from products.products, sales.order_items, sales.orders, and products.promotions.

-- Q49: Calculate store cannibalization: measure sales overlap between nearby stores from stores.stores, sales.orders, and customers.customers.

-- Q50: Find upsell opportunities: customers buying entry-level products who could upgrade from customers.customers, sales.orders, sales.order_items, and products.products.

-- Q51: Analyze complete order journey: from product selection to delivery, identifying bottlenecks from sales.orders, sales.order_items, sales.payments, sales.shipments, products.products, and products.inventory.

-- Q52: Build comprehensive customer profile: demographics, purchase history, preferences, loyalty, and engagement from customers.customers, sales.orders, sales.order_items, customers.reviews, customers.loyalty_points, and marketing.email_clicks.

-- Q53: Create end-to-end supply chain view: from supplier to customer delivery with all touchpoints from products.suppliers, products.products, products.inventory, sales.orders, sales.order_items, sales.shipments, and stores.stores.

-- Q54: Analyze marketing funnel: campaign exposure → email opens → website visits → purchases → reviews from marketing.campaigns, marketing.ads_spend, marketing.email_clicks, sales.orders, and customers.reviews.

-- Q55: Build product ecosystem map: products, categories, brands, suppliers, and sales relationships from products.products, core.dim_category, core.dim_brand, products.suppliers, and sales.order_items.

-- Q56: Create store operations dashboard: sales, inventory, employees, expenses, all integrated from stores.stores, sales.orders, products.inventory, stores.employees, and stores.expenses.

-- Q57: Analyze customer value creation: from acquisition through purchases to advocacy (reviews) from customers.customers, sales.orders, sales.order_items, customers.reviews, and marketing.email_clicks.

-- Q58: Build supplier performance ecosystem: products, quality, delivery, pricing, sales contribution from products.suppliers, products.products, sales.order_items, sales.returns, and products.inventory.

-- Q59: Create employee impact analysis: link employee actions to sales, customer satisfaction, and store performance from stores.employees, stores.stores, sales.orders, customers.reviews, and hr.attendance.

-- Q60: Analyze campaign ecosystem: campaigns, channels, customers, orders, revenue attribution from marketing.campaigns, marketing.ads_spend, marketing.email_clicks, customers.customers, and sales.orders.

-- Q61: Find customers purchasing high-value items but with low order frequency, indicating potential for subscription model from customers.customers, sales.orders, and sales.order_items.

-- Q62: Identify stores with misaligned workforce: too many employees for sales volume or too few for customer demand from stores.stores, stores.employees, sales.orders, and customers.customers.

-- Q63: Calculate product affinity scores: likelihood of buying product B given purchase of product A from sales.order_items, sales.orders, and products.products.

-- Q64: Find seasonal inventory planning insights: historical patterns for future stock allocation from products.inventory, sales.order_items, sales.orders, and products.products.

-- Q65: Identify customer segment migration: movement between value tiers over time from customers.customers and sales.orders.

-- Q66: Calculate store contribution to customer lifetime value: which stores acquire valuable long-term customers from stores.stores, sales.orders, and customers.customers.

-- Q67: Find products with geographic preferences: selling better in specific regions/climates from products.products, sales.order_items, sales.orders, stores.stores, and core.dim_region.

-- Q68: Identify marketing waste: campaigns with high spend but low customer engagement or conversion from marketing.campaigns, marketing.ads_spend, marketing.email_clicks, and sales.orders.

-- Q69: Calculate perfect order rate: orders fulfilled completely, on-time, without returns from sales.orders, sales.order_items, sales.shipments, and sales.returns.

-- Q70: Find supplier-category fit: suppliers optimally aligned with category requirements and performance from products.suppliers, products.products, core.dim_category, and sales.order_items.

-- Q71: Compare online vs offline customer behavior: purchase patterns, basket size, preferences from sales.orders, sales.order_items, stores.stores, and customers.customers.

-- Q72: Identify festival season effectiveness: sales lift during festival periods vs baseline from sales.orders, sales.order_items, and products.products.

-- Q73: Calculate customer concentration risk: percentage of revenue from top customers by store from stores.stores, sales.orders, and customers.customers.

-- Q74: Find new product launch success patterns: factors correlating with successful launches from products.products, sales.order_items, sales.orders, and customers.reviews.

-- Q75: Identify inventory redundancy: similar products cannibalizing each other's sales from products.products, sales.order_items, and sales.orders.

-- Q76: Calculate delivery promise adherence: on-time delivery rates by courier and region from sales.shipments, sales.orders, and stores.stores.

-- Q77: Find price-sensitive customer segments: customers who primarily buy during discounts from customers.customers, sales.orders, and sales.order_items.

-- Q78: Identify category expansion opportunities: customer segments buying many categories vs single-category buyers from customers.customers, sales.orders, sales.order_items, and products.products.

-- Q79: Calculate store location effectiveness: sales per square foot equivalent by location type from stores.stores and sales.orders.

-- Q80: Find employee training needs: correlate employee tenure with store performance gaps from stores.employees, stores.stores, and sales.orders.

-- Q81: Optimize join order for complex query: customers → orders → order_items → products → suppliers analyzing performance implications from customers.customers, sales.orders, sales.order_items, products.products, and products.suppliers.

-- Q82: Compare LEFT JOIN vs INNER JOIN performance: same query with different join types, analyzing execution plans from any relevant tables.

-- Q83: Analyze impact of join conditions: single condition vs multiple conditions on query performance from sales.orders and sales.order_items.

-- Q84: Optimize multi-table join query: reorder joins for better performance based on table sizes from stores.stores, stores.employees, sales.orders, and customers.customers.

-- Q85: Compare subquery vs JOIN performance: same analytical question solved both ways from sales.orders and sales.order_items.

-- Q86: Analyze NULL handling impact: queries with IS NULL conditions in joins from products.products and products.inventory.

-- Q87: Optimize aggregate with join: GROUP BY performance with multiple joined tables from sales.orders, sales.order_items, and products.products.

-- Q88: Compare CROSS JOIN vs multiple INNER JOINs: performance characteristics from smaller dimension tables.

-- Q89: Analyze self-join performance: recursive hierarchical queries optimization from any table with hierarchical structure.

-- Q90: Optimize join with CASE logic: performance of conditional joins from sales.orders and customers.customers.

-- Q91: Build sales performance report: revenue, orders, customers, products across all dimensions with proper join strategy from sales.orders, sales.order_items, customers.customers, products.products, and stores.stores.

-- Q92: Create customer analytics dashboard: lifetime value, segment, preferences, satisfaction with optimized joins from customers.customers, sales.orders, customers.reviews, and customers.loyalty_points.

-- Q93: Design product intelligence report: sales, inventory, supplier, reviews with minimal join operations from products.products, sales.order_items, products.inventory, products.suppliers, and customers.reviews.

-- Q94: Build operational excellence dashboard: stores, employees, inventory, expenses with efficient join patterns from stores.stores, stores.employees, products.inventory, and stores.expenses.

-- Q95: Create marketing ROI report: campaigns, channels, engagement, revenue with join optimization from marketing.campaigns, marketing.ads_spend, marketing.email_clicks, and sales.orders.

-- Q96: Design supply chain visibility report: suppliers, products, inventory, orders with proper join sequencing from products.suppliers, products.products, products.inventory, and sales.order_items.

-- Q97: Build financial performance report: revenue, expenses, profitability across all entities with optimized joins from sales.orders, stores.expenses, stores.stores, and sales.order_items.

-- Q98: Create customer journey analytics: touchpoints, conversions, lifetime value with efficient join strategy from customers.customers, marketing.email_clicks, sales.orders, and customers.reviews.

-- Q99: Design inventory intelligence report: stock levels, sales velocity, reorder points with join optimization from products.inventory, sales.order_items, products.products, and stores.stores.

-- Q100: Build executive summary dashboard: comprehensive business metrics with most efficient join pattern across all relevant tables from all schemas.
