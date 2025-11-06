-- ================================================
-- Day 6: Conditional Logic & Derived Columns
-- Level: HARD (100 Questions)
-- Topics: Advanced CASE Logic, Complex Derived Columns, Multi-condition Analysis
-- ================================================

-- ## HARD

-- Q1: Create a comprehensive customer segmentation report using RFM (Recency, Frequency, Monetary) scoring with CASE statements, categorizing customers into 8 segments from customers.customers and sales.orders.

-- Q2: Build a dynamic pricing model showing optimal price point for each product based on demand elasticity (analyze quantity sold at different discount levels) using nested CASE from sales.order_items.

-- Q3: Calculate employee performance score combining multiple factors: sales contribution (40%), attendance (30%), tenure (20%), customer satisfaction (10%) using complex CASE logic from stores.employees, sales.orders, and customers.reviews.

-- Q4: Create a product lifecycle classification system identifying Introduction, Growth, Maturity, Decline phases based on sales trends, using CASE with quarter-over-quarter analysis from sales.order_items and sales.orders.

-- Q5: Design a store health scorecard with weighted metrics: profitability (35%), growth (25%), customer satisfaction (20%), inventory efficiency (20%) using nested CASE from sales.orders, stores.expenses, customers.reviews, and products.inventory.

-- Q6: Build an intelligent inventory reorder recommendation system using CASE that considers: current stock, sales velocity, lead time, seasonality, and safety stock from products.inventory and sales.order_items.

-- Q7: Create a customer churn prediction model using CASE: analyze order frequency decline, average order value decrease, last purchase date, and return rate from sales.orders, sales.returns, and customers.customers.

-- Q8: Develop a campaign effectiveness matrix categorizing campaigns by ROI tier and engagement level using nested CASE from marketing.campaigns, marketing.ads_spend, and sales.orders.

-- Q9: Design a supplier performance scorecard evaluating quality (return rate), delivery reliability (stock availability), pricing competitiveness, and catalog breadth using CASE from products.suppliers, products.products, sales.returns, and products.inventory.

-- Q10: Build a sales rep commission calculator with tiered structure based on quota achievement, product mix, customer acquisition, and deal size using complex CASE from stores.employees, sales.orders, and sales.order_items.

-- Q11: Create a customer credit limit recommendation using CASE considering: payment history, order frequency, average order value, account age, and return rate from customers.customers, sales.orders, sales.payments, and sales.returns.

-- Q12: Design a markdown optimization model suggesting discount levels based on: inventory age, sales velocity, profit margin, and competitive pricing using nested CASE from products.inventory, sales.order_items, and products.products.

-- Q13: Build a delivery partner evaluation system scoring couriers on: on-time delivery rate, damage rate, cost per delivery, and geographic coverage using CASE from sales.shipments and sales.returns.

-- Q14: Create a product bundling recommendation engine using CASE to identify complementary products based on co-purchase patterns and profit margin optimization from sales.order_items.

-- Q15: Develop a store format recommendation (large/medium/small) for new locations using CASE with analysis of: population density, income levels, competition, and category mix from customers.customers, sales.orders, and stores.stores.

-- Q16: Design a loyalty program tier assignment system using CASE with thresholds for: lifetime spending, order frequency, average order value, and referrals from customers.customers, sales.orders, and customers.loyalty_points.

-- Q17: Build a return fraud detection model using CASE to flag suspicious patterns: high return rate, expensive items, short holding period, and customer behavior from sales.returns, sales.orders, and customers.customers.

-- Q18: Create a promotional calendar optimizer using CASE to suggest promotion timing based on: seasonal patterns, inventory levels, competitive activity, and margin targets from sales.orders, products.inventory, and products.promotions.

-- Q19: Develop a customer win-back strategy classifier using CASE to categorize churned customers by: churn reason (inferred), value potential, reactivation likelihood, and optimal incentive from sales.orders and customers.customers.

-- Q20: Design a product assortment optimization model using CASE to categorize products as: must-stock, conditional, or eliminate based on sales contribution, margin, and space efficiency from sales.order_items, products.products, and products.inventory.

-- Q21: Create a geographic expansion priority matrix using CASE to score potential new locations by: market size, competition intensity, customer demographics, and infrastructure readiness from customers.customers, sales.orders, and stores.stores.

-- Q22: Build a cross-sell propensity model using CASE to identify customers likely to buy specific categories based on purchase history and demographic similarity from sales.order_items, customers.customers, and products.products.

-- Q23: Develop a payment fraud detection system using CASE to flag anomalies: unusual amounts, payment mode patterns, order velocity, and geographic inconsistencies from sales.payments, sales.orders, and customers.customers.

-- Q24: Design a sales forecasting categorization using CASE to classify products by predictability: highly predictable, moderately predictable, or volatile based on historical variance from sales.order_items and sales.orders.

-- Q25: Create a customer complaint risk score using CASE combining: return frequency, delivery delays, product quality issues, and response time from sales.returns, sales.shipments, and customers.reviews.

-- Q26: Build a warehouse location optimizer using CASE to score potential warehouse sites by: proximity to customers, transportation costs, labor availability, and order density from customers.customers, sales.orders, and stores.stores.

-- Q27: Develop a price perception analysis using CASE to categorize products by: customer sensitivity (measured by discount responsiveness), competitive positioning, and value perception from sales.order_items and products.products.

-- Q28: Design a seasonal hiring plan using CASE to calculate staffing needs by: historical sales patterns, customer traffic, and service level targets for each store and period from sales.orders, stores.employees, and stores.stores.

-- Q29: Create a product innovation pipeline classifier using CASE to categorize new product opportunities by: market gap size, margin potential, operational feasibility, and strategic fit from products.products, sales.order_items, and customers.reviews.

-- Q30: Build an omnichannel customer journey mapper using CASE to classify customers by: preferred channel, cross-channel behavior, and channel profitability from sales.orders and customers.customers.

-- Q31: Calculate conditional moving averages: 3-month average for stable products, 1-month for trending items, weighted average for seasonal using CASE from sales.order_items and sales.orders.

-- Q32: Create dynamic safety stock calculation using CASE based on: product category, lead time variability, service level requirement, and demand volatility from products.inventory, sales.order_items, and products.products.

-- Q33: Build a customer lifetime value calculator with CASE handling different customer types: new, regular, VIP with different retention assumptions from customers.customers and sales.orders.

-- Q34: Design a margin protection strategy using CASE to adjust discounts based on: inventory levels, product velocity, margin percentage, and competitive pressure from sales.order_items, products.inventory, and products.products.

-- Q35: Develop a store clustering algorithm using CASE to group stores by: size, location type, customer demographics, and sales patterns for targeted strategies from stores.stores, sales.orders, and customers.customers.

-- Q36: Create a payment terms optimizer using CASE to suggest credit terms based on: customer creditworthiness, order size, payment history, and relationship tenure from customers.customers, sales.orders, and sales.payments.

-- Q37: Build a product substitution recommender using CASE when items are out of stock: suggest alternatives based on category, price range, brand affinity, and customer preferences from products.products, products.inventory, and sales.order_items.

-- Q38: Design a promotional budget allocator using CASE to distribute marketing budget across: channels, campaigns, products, and time periods based on historical ROI from marketing.campaigns, marketing.ads_spend, and sales.orders.

-- Q39: Develop a customer satisfaction predictor using CASE with proxies: delivery time, product quality (return rate), price paid vs market, and review sentiment from sales.orders, sales.shipments, sales.returns, and customers.reviews.

-- Q40: Create a competitive pricing strategy using CASE to position products as: price leader, matcher, or premium based on market position and margin objectives from products.products and sales.order_items.

-- Q41: Build a revenue quality analyzer using CASE to categorize sales by: margin level, payment terms, customer segment, and return risk from sales.orders, sales.order_items, sales.payments, and sales.returns.

-- Q42: Design a talent retention risk model using CASE to flag employees at attrition risk based on: salary vs market, tenure patterns, performance, and store health from stores.employees, sales.orders, and stores.stores.

-- Q43: Develop a category management strategy using CASE to classify categories as: destination, routine, seasonal, or convenience based on shopping patterns from sales.order_items, sales.orders, and products.products.

-- Q44: Create a customer acquisition cost optimizer using CASE to allocate acquisition budget by: channel efficiency, customer lifetime value potential, and market saturation from customers.customers, sales.orders, and marketing.ads_spend.

-- Q45: Build a shrinkage detection system using CASE to identify potential theft or loss based on: inventory variances, transaction patterns, and store-level anomalies from products.inventory, sales.order_items, and stores.stores.

-- Q46: Design a delivery promise engine using CASE to set realistic delivery times based on: distance, courier performance, inventory location, and order complexity from sales.orders, sales.shipments, stores.stores, and products.inventory.

-- Q47: Develop a customer reactivation scoring using CASE to prioritize dormant customers by: past value, churn timing, reactivation likelihood, and campaign cost-effectiveness from customers.customers and sales.orders.

-- Q48: Create a working capital optimizer using CASE to balance: inventory investment, payment terms, and sales forecast across product categories from products.inventory, sales.order_items, and sales.payments.

-- Q49: Build a price elasticity classifier using CASE to segment products by: sensitivity to price changes, cross-elasticity effects, and optimal pricing strategy from sales.order_items and products.products.

-- Q50: Design a location intelligence model using CASE to evaluate store performance by: local demographics match, competitive density, catchment area penetration, and wallet share from stores.stores, customers.customers, and sales.orders.

-- Q51: Create a comprehensive dashboard query showing: order status distribution, revenue by category, customer segment distribution, and inventory health all using CASE statements from multiple tables.

-- Q52: Build a multi-dimensional product performance report with CASE showing: sales tier, margin category, inventory status, and lifecycle stage for each product from products.products, sales.order_items, products.inventory, and sales.orders.

-- Q53: Design a store comparison report using CASE to standardize stores by: size-adjusted revenue, efficiency ratios, customer metrics, and growth trajectories from stores.stores, sales.orders, stores.employees, and customers.customers.

-- Q54: Develop a customer value pyramid using CASE to show: customer count, revenue contribution, and profit margin for each value segment from customers.customers, sales.orders, and sales.order_items.

-- Q55: Create a seasonal planning report using CASE to show: historical patterns, forecast categories, inventory recommendations, and staffing needs by season from sales.orders, products.inventory, and stores.employees.

-- Q56: Build a supplier performance dashboard using CASE showing: quality ratings, delivery performance, pricing competitiveness, and strategic importance from products.suppliers, products.products, sales.returns, and products.inventory.

-- Q57: Design a campaign effectiveness report using CASE to evaluate: ROI tiers, channel performance, customer acquisition quality, and optimization opportunities from marketing.campaigns, marketing.ads_spend, and sales.orders.

-- Q58: Develop a credit management report using CASE to show: customer payment behavior, risk categories, credit utilization, and recommended actions from customers.customers, sales.orders, and sales.payments.

-- Q59: Create a markdown management report using CASE showing: markdown necessity, suggested discount levels, expected sell-through, and margin impact from products.inventory, sales.order_items, and products.products.

-- Q60: Build a customer engagement report using CASE to analyze: activity levels, purchase frequency changes, category preferences, and engagement trends from customers.customers, sales.orders, and sales.order_items.

-- Q61: Design a complex CASE statement that handles NULL values, performs date calculations, applies business rules, and creates multi-tier categorizations all in one query from sales.orders.

-- Q62: Create a CASE expression with multiple nested levels handling: exceptions, edge cases, default values, and conditional aggregations from sales.order_items and products.products.

-- Q63: Build a sophisticated derived column combining: string manipulation, mathematical operations, date functions, and conditional logic using CASE from customers.customers and sales.orders.

-- Q64: Develop a multi-condition CASE that incorporates: subquery results, aggregate comparisons, and cross-table validations from stores.employees, sales.orders, and stores.stores.

-- Q65: Design a CASE statement with complex AND/OR logic handling: multiple threshold checks, range validations, and pattern matching from sales.orders and customers.customers.

-- Q66: Create a computed metric using nested CASE that adjusts calculations based on: time periods, business segments, and exception conditions from sales.order_items and sales.orders.

-- Q67: Build a CASE expression that dynamically selects calculation methods based on: data availability, business context, and quality indicators from products.inventory and sales.order_items.

-- Q68: Develop a conditional aggregation using CASE that handles: varying group structures, weighted calculations, and outlier treatment from sales.orders and sales.order_items.

-- Q69: Design a CASE statement combining: COALESCE for NULL handling, NULLIF for zero-division prevention, and nested conditions from sales.orders and stores.expenses.

-- Q70: Create a complex pivot using CASE that generates: multiple measure types, conditional formatting, and calculated fields from sales.orders and sales.order_items.

-- Q71: Analyze cohort behavior using CASE to compare: new vs returning customers, high vs low value, engaged vs dormant across multiple dimensions from customers.customers and sales.orders.

-- Q72: Build a scenario analysis model using CASE to show: best case, base case, worst case projections for revenue based on different assumptions from sales.orders and sales.order_items.

-- Q73: Create a variance analysis report using CASE to categorize: favorable vs unfavorable variances, material vs immaterial differences, and explanatory factors from sales.orders and stores.expenses.

-- Q74: Design a trend classification system using CASE to identify: growth, stable, or declining patterns with statistical confidence levels from sales.orders and sales.order_items.

-- Q75: Develop a benchmark comparison using CASE to show: above, at, or below performance vs industry standards across multiple KPIs from stores.stores, sales.orders, and stores.employees.

-- Q76: Build a risk matrix using CASE to plot: likelihood and impact of various business risks (inventory, credit, operational) from products.inventory, sales.orders, and customers.customers.

-- Q77: Create a capacity planning model using CASE to calculate: utilization rates, bottlenecks, and expansion requirements by resource type from stores.employees, products.inventory, and sales.orders.

-- Q78: Design a profitability waterfall using CASE to break down: revenue to profit through various cost and efficiency factors from sales.orders, sales.order_items, and stores.expenses.

-- Q79: Develop a customer migration analysis using CASE to track: movement between segments, reasons for migration, and retention strategies from customers.customers and sales.orders.

-- Q80: Build a portfolio optimization model using CASE to balance: growth products, cash cows, question marks, and dogs based on sales and profitability from products.products, sales.order_items, and sales.orders.

-- Q81: Create an exception report using CASE to flag: unusual transactions, data quality issues, process violations, and approval requirements from sales.orders, sales.payments, and sales.returns.

-- Q82: Design a service level compliance report using CASE to measure: on-time delivery, order accuracy, product availability, and customer satisfaction targets from sales.orders, sales.shipments, products.inventory, and customers.reviews.

-- Q83: Develop a price optimization matrix using CASE to suggest: pricing actions based on demand elasticity, competitive position, and margin requirements from products.products, sales.order_items, and sales.orders.

-- Q84: Build a customer health score using CASE combining: engagement metrics, satisfaction indicators, profitability measures, and growth potential from customers.customers, sales.orders, and customers.reviews.

-- Q85: Create a product rationalization analysis using CASE to recommend: keep, monitor, or discontinue decisions based on multiple performance factors from products.products, sales.order_items, products.inventory, and sales.orders.

-- Q86: Design a market basket analysis using CASE to identify: complementary products, substitutes, and cross-sell opportunities with confidence levels from sales.order_items and sales.orders.

-- Q87: Develop a channel performance comparison using CASE to evaluate: productivity, profitability, and strategic value of different sales channels from sales.orders and stores.stores.

-- Q88: Build a quality control dashboard using CASE to monitor: defect rates, return reasons, supplier quality, and corrective actions from sales.returns, products.products, and products.suppliers.

-- Q89: Create a demand sensing model using CASE to adjust: forecasts based on real-time signals, events, and leading indicators from sales.orders, sales.order_items, and products.inventory.

-- Q90: Design a customer feedback analyzer using CASE to categorize: review sentiments, issue types, urgency levels, and recommended actions from customers.reviews and sales.orders.

-- Q91: Develop a comprehensive KPI dashboard using multiple CASE statements showing: sales metrics, operational efficiency, customer metrics, and financial performance from all relevant tables.

-- Q92: Build a balanced scorecard using CASE with four perspectives: financial, customer, internal processes, and learning/growth from sales.orders, customers.customers, stores.employees, and products.inventory.

-- Q93: Create a what-if analysis tool using CASE to model: impact of price changes, cost variations, and volume shifts on profitability from sales.orders, sales.order_items, and stores.expenses.

-- Q94: Design a sales performance attribution model using CASE to distribute: credit across touchpoints, channels, and time periods from sales.orders, marketing.campaigns, and marketing.ads_spend.

-- Q95: Develop a resource allocation optimizer using CASE to recommend: staffing levels, inventory positions, and marketing spend across stores from stores.employees, products.inventory, sales.orders, and marketing.ads_spend.

-- Q96: Build a customer journey analyzer using CASE to map: acquisition, activation, engagement, retention, and advocacy stages from customers.customers, sales.orders, customers.reviews, and customers.loyalty_points.

-- Q97: Create a competitive intelligence report using CASE to infer: market positioning, share trends, and strategic moves based on internal data patterns from sales.orders, sales.order_items, and products.products.

-- Q98: Design a master data quality scorecard using CASE to evaluate: completeness, accuracy, consistency, and timeliness across key entities from all tables.

-- Q99: Develop a simulation model using CASE to test: various business scenarios, strategy alternatives, and risk mitigation approaches from sales.orders, stores.stores, and customers.customers.

-- Q100: Build an executive summary query using advanced CASE logic to present: top-level insights, key trends, critical issues, and strategic recommendations synthesizing data from all schemas.
