-- ================================================
-- Day 6: Conditional Logic & Derived Columns
-- Level: MEDIUM (100 Questions)
-- Topics: Complex CASE WHEN, Conditional Aggregations, Nested Logic
-- ================================================

-- ## MEDIUM

-- Q1: Count how many products are in each price category: Budget (<1000), Mid-range (1000-5000), Premium (>5000) from products.products.

-- Q2: Calculate total sales for 'Completed' orders and 'Pending' orders separately using conditional aggregation from sales.orders.

-- Q3: Show count of male and female customers in each city using CASE and GROUP BY from customers.customers.

-- Q4: Calculate average salary for employees categorized as Junior (<50000), Mid (50000-80000), Senior (>80000) from stores.employees.

-- Q5: Count orders by size: Small (<5000), Medium (5000-20000), Large (>20000) for each store from sales.orders.

-- Q6: Show total quantity sold for each product category status: High Stock (>100), Medium (50-100), Low (<50) from sales.order_items and products.inventory.

-- Q7: Calculate revenue from different customer segments: New (joined in 2024) vs Existing customers from sales.orders and customers.customers.

-- Q8: Count 5-star, 4-star, 3-star, and below-3-star reviews for each product from customers.reviews.

-- Q9: Show total refund amount for 'Damaged' vs 'Other' reasons from sales.returns.

-- Q10: Calculate sum of clicks from 'Social Media' vs 'Other' channels for each campaign from marketing.ads_spend.

-- Q11: Show count of orders by payment preference: Digital (UPI, Card) vs Cash from sales.payments and sales.orders.

-- Q12: Calculate total expenses categorized as 'Fixed' (Rent, Salary) vs 'Variable' from stores.expenses.

-- Q13: Count shipments by delivery speed: Fast (<3 days), Normal (3-7 days), Slow (>7 days) from sales.shipments.

-- Q14: Show total loyalty points for Active (>1000 points) vs Inactive customers from customers.loyalty_points.

-- Q15: Calculate revenue from High-discount (>10%) vs Low-discount orders from sales.order_items.

-- Q16: Count employees by performance tier based on their store's sales from stores.employees and sales.orders.

-- Q17: Show total budget for Ongoing vs Completed campaigns from marketing.campaigns.

-- Q18: Calculate average rating for products in each price segment from customers.reviews and products.products.

-- Q19: Count customers by lifecycle stage: New (<6 months), Regular (6-24 months), Loyal (>24 months) from customers.customers.

-- Q20: Show total stock value categorized by movement: Fast, Medium, Slow from products.inventory and sales.order_items.

-- Q21: Create a report showing count and percentage of each order status from sales.orders.

-- Q22: Calculate total revenue and average order value for weekdays vs weekends from sales.orders.

-- Q23: Show count of products and average price by brand tier (Premium, Standard, Budget) from products.products.

-- Q24: Count employees and total salary by experience level: Entry (<50k), Mid (50-80k), Senior (>80k) from stores.employees.

-- Q25: Calculate conversion rate: orders with reviews vs without reviews from sales.orders and customers.reviews.

-- Q26: Show total quantity and revenue for seasonal products (sold mainly in specific quarters) from sales.order_items and sales.orders.

-- Q27: Count stores by performance: Top (sales > 50 lakh), Medium (20-50 lakh), Low (<20 lakh) from sales.orders and stores.stores.

-- Q28: Calculate total refunds by product quality perception (price-based) from sales.returns and products.products.

-- Q29: Show customer distribution by spending habit: Big Spenders, Moderate, Occasional from sales.orders and customers.customers.

-- Q30: Count campaigns by ROI category: Profitable, Break-even, Loss-making from marketing.campaigns and marketing.ads_spend.

-- Q31: Use CASE to pivot order statuses: show count of Completed, Pending, Cancelled as separate columns for each store from sales.orders.

-- Q32: Create a pivot showing male and female customer counts as separate columns for each state from customers.customers.

-- Q33: Show total sales for Q1, Q2, Q3, Q4 as separate columns for each store from sales.orders.

-- Q34: Pivot review ratings: show count of 1-star, 2-star, 3-star, 4-star, 5-star as columns from customers.reviews.

-- Q35: Display total quantity for each product category as separate columns from sales.order_items.

-- Q36: Show payment mode distribution: Cash, Card, UPI, Wallet as separate columns per store from sales.payments and sales.orders.

-- Q37: Pivot age groups: count of 18-30, 31-45, 46-60, 60+ as columns by city from customers.customers.

-- Q38: Show expense types: Rent, Utilities, Marketing as separate columns for each store from stores.expenses.

-- Q39: Pivot delivery status: Delivered, In-Transit, Pending as columns by courier from sales.shipments.

-- Q40: Display seasonal sales: Summer, Monsoon, Winter, Spring as columns for each category from sales.orders and sales.order_items.

-- Q41: Show products with 'Requires Restock' flag if stock < 10 and 'Overstocked' if stock > 500 from products.inventory.

-- Q42: Create customer risk flag: 'High Risk' if return rate > 20%, 'Medium' if 10-20%, else 'Low' from sales.orders and sales.returns.

-- Q43: Flag campaigns as 'Successful' if conversions > 100, 'Moderate' if 50-100, else 'Failed' from marketing.ads_spend.

-- Q44: Show employees with 'Promotion Due' flag if salary < department average from stores.employees.

-- Q45: Create store health indicator: 'Healthy', 'Warning', 'Critical' based on sales trends from sales.orders.

-- Q46: Flag products as 'Trending' if sales increased 50% quarter-over-quarter from sales.order_items and sales.orders.

-- Q47: Mark customers as 'VIP' if total spending > 1 lakh and orders > 20 from sales.orders.

-- Q48: Create quality flag for suppliers based on return rates of their products from products.suppliers, products.products, and sales.returns.

-- Q49: Flag orders as 'Fraud Risk' if amount > 50000 and customer age < 25 from sales.orders and customers.customers.

-- Q50: Show inventory alert: 'Critical' if days of stock < 7, 'Warning' if < 15, else 'OK' from products.inventory and sales.order_items.

-- Q51: Calculate total sales with 10% commission for completed orders, 5% for pending from sales.orders.

-- Q52: Show employee bonus: 15% of salary if in top store, 10% if in medium, 5% otherwise from stores.employees and sales.orders.

-- Q53: Calculate dynamic discount: 20% for orders > 50000, 10% for >20000, 5% otherwise from sales.orders.

-- Q54: Show loyalty points earned: 10 points per ₹100 for VIP, 5 points for regular customers from sales.orders and customers.loyalty_points.

-- Q55: Calculate variable shipping cost: ₹100 if amount > 10000, ₹200 if >5000, ₹300 otherwise from sales.orders.

-- Q56: Show product markup: 50% for premium brands, 30% for standard from products.products.

-- Q57: Calculate seasonal pricing: +20% during festival months, regular otherwise from products.products.

-- Q58: Show rental cost adjustment: +10% for top-performing stores, -10% for low performers from stores.expenses and sales.orders.

-- Q59: Calculate performance bonus pool by store tier from stores.employees and sales.orders.

-- Q60: Show dynamic tax rate: 18% for luxury items (>10000), 12% for standard, 5% for essentials from products.products.

-- Q61: Use nested CASE to categorize customers by age group and spending level from customers.customers and sales.orders.

-- Q62: Create multi-tier product classification: category, price range, and stock level from products.products and products.inventory.

-- Q63: Nested logic for employee classification: department, salary tier, and performance from stores.employees and sales.orders.

-- Q64: Complex order categorization: status, value, and delivery speed from sales.orders and sales.shipments.

-- Q65: Multi-level customer segmentation: geography, demographics, and purchase behavior from customers.customers and sales.orders.

-- Q66: Nested CASE for campaign effectiveness: channel, budget tier, and performance from marketing.campaigns and marketing.ads_spend.

-- Q67: Product recommendation logic: category preference, price sensitivity, and purchase history from sales.order_items and customers.customers.

-- Q68: Store classification: region, size (by employees), and performance from stores.stores, stores.employees, and sales.orders.

-- Q69: Supplier evaluation: quality (return rate), reliability (stock), and pricing from products.suppliers, products.products, and sales.returns.

-- Q70: Customer lifetime value prediction: tenure, frequency, and average order value from customers.customers and sales.orders.

-- Q71: Show each customer with their total spending and spending category (High/Medium/Low) from customers.customers and sales.orders.

-- Q72: Display products with current stock, reorder point flag, and stock status from products.inventory.

-- Q73: Show employees with their salary, department average, and above/below average flag from stores.employees.

-- Q74: Display stores with total revenue, regional average, and performance rating from sales.orders and stores.stores.

-- Q75: Show campaigns with total cost, conversion count, and cost per conversion from marketing.campaigns and marketing.ads_spend.

-- Q76: Display customers with order count, average order value, and customer tier from sales.orders and customers.customers.

-- Q77: Show products with total quantity sold, stock level, and inventory status from sales.order_items and products.inventory.

-- Q78: Display orders with payment amount, payment mode, and payment category from sales.payments and sales.orders.

-- Q79: Show stores with employee count, average salary, and cost efficiency rating from stores.employees and sales.orders.

-- Q80: Display suppliers with product count, category diversity, and supplier rating from products.suppliers and products.products.

-- Q81: Use COALESCE to handle NULLs in multi-column scenarios: show best available contact info from customers.addresses.

-- Q82: Handle missing review text with COALESCE showing rating-based default message from customers.reviews.

-- Q83: Use COALESCE to show actual or estimated delivery date from sales.shipments.

-- Q84: Handle NULL discount with COALESCE and calculate final price from sales.order_items.

-- Q85: Show employee location info with COALESCE handling NULL cities from stores.employees and stores.stores.

-- Q86: Use COALESCE for campaign performance metrics with default values from marketing.ads_spend.

-- Q87: Handle NULL regions with COALESCE showing state-based defaults from customers.customers.

-- Q88: Show product supplier info with COALESCE for missing supplier names from products.products.

-- Q89: Use COALESCE to show actual or budgeted expense amounts from stores.expenses.

-- Q90: Handle NULL loyalty points with COALESCE showing 0 as default from customers.loyalty_points.

-- Q91: Calculate customer lifetime with derived columns from join_date and last order date from customers.customers and sales.orders.

-- Q92: Show product performance index combining price, sales, and ratings from products.products, sales.order_items, and customers.reviews.

-- Q93: Calculate employee efficiency ratio: store revenue per employee from stores.employees and sales.orders.

-- Q94: Show store profitability: revenue minus expenses with profit margin percentage from sales.orders and stores.expenses.

-- Q95: Calculate campaign ROI: (revenue - cost) / cost * 100 from marketing.campaigns, marketing.ads_spend, and sales.orders.

-- Q96: Show customer value score combining spending, frequency, and loyalty points from sales.orders and customers.loyalty_points.

-- Q97: Calculate inventory health score using stock, sales velocity, and days of stock from products.inventory and sales.order_items.

-- Q98: Show product competitiveness index using price, rating, and market position from products.products and customers.reviews.

-- Q99: Calculate store attractiveness score using location, sales, and customer base from stores.stores, sales.orders, and customers.customers.

-- Q100: Show supplier reliability score combining delivery, quality, and pricing from products.suppliers, products.products, and sales.returns.
