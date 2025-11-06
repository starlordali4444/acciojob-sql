-- ================================================
-- Day 7: Joins (Foundations & Advanced)
-- Level: MEDIUM (100 Questions)
-- Topics: Multi-table Joins, Aggregations with Joins, Complex Join Conditions
-- ================================================

-- ## MEDIUM

-- Q1: Find customers who have placed orders, showing customer name, total orders, and total spending from customers.customers and sales.orders.

-- Q2: Display products with their total quantity sold and revenue generated from products.products and sales.order_items.

-- Q3: Show stores with employee count and total sales from stores.stores, stores.employees, and sales.orders.

-- Q4: List suppliers with product count and total revenue from their products from products.suppliers, products.products, and sales.order_items.

-- Q5: Find customers with their average order value and total loyalty points from customers.customers, sales.orders, and customers.loyalty_points.

-- Q6: Display departments with employee count, total salary expense, and average salary from stores.departments and stores.employees.

-- Q7: Show campaigns with total spend, total clicks, and conversion rate from marketing.campaigns and marketing.ads_spend.

-- Q8: List products with their average rating, review count, and total quantity sold from products.products, customers.reviews, and sales.order_items.

-- Q9: Find stores with total revenue, total expenses, and net profit from stores.stores, sales.orders, and stores.expenses.

-- Q10: Display customers with order count, return count, and return rate from customers.customers, sales.orders, and sales.returns.

-- Q11: Show all customers including those who haven't ordered, with their order count (0 for non-buyers) from customers.customers and sales.orders.

-- Q12: List all products including those never sold, with their total quantity sold (0 for unsold) from products.products and sales.order_items.

-- Q13: Display all stores including those with no employees, showing employee count from stores.stores and stores.employees.

-- Q14: Find all suppliers including those with no products, with their product count from products.suppliers and products.products.

-- Q15: Show all campaigns including those with no ad spend, with total spend amount from marketing.campaigns and marketing.ads_spend.

-- Q16: List all products including those with no inventory, showing stock quantity from products.products and products.inventory.

-- Q17: Display all customers including those with no reviews, with review count from customers.customers and customers.reviews.

-- Q18: Find all orders including those with no payments, showing payment amount from sales.orders and sales.payments.

-- Q19: Show all employees including those with no attendance records, with attendance count from stores.employees and hr.attendance.

-- Q20: List all products including those with no reviews, with average rating (NULL for no reviews) from products.products and customers.reviews.

-- Q21: Find customers who have ordered but never returned any product from customers.customers, sales.orders, and sales.returns using LEFT JOIN.

-- Q22: Display products that exist in inventory but have never been ordered from products.products, products.inventory, and sales.order_items.

-- Q23: Show employees who work in stores but have no attendance records from stores.employees and hr.attendance.

-- Q24: List campaigns that have ad spend but generated no email clicks from marketing.campaigns, marketing.ads_spend, and marketing.email_clicks.

-- Q25: Find products that have reviews but have never been sold from products.products, customers.reviews, and sales.order_items.

-- Q26: Display stores that have employees but no recorded sales from stores.stores, stores.employees, and sales.orders.

-- Q27: Show suppliers who have products but none in current inventory from products.suppliers, products.products, and products.inventory.

-- Q28: List customers who have loyalty points but never placed an order from customers.customers, customers.loyalty_points, and sales.orders.

-- Q29: Find orders that have been paid for but not yet shipped from sales.orders, sales.payments, and sales.shipments.

-- Q30: Display products in multiple categories using their category name from products.products and core.dim_category.

-- Q31: Join customers, orders, order_items, and products to show customer purchase details with product names from customers.customers, sales.orders, sales.order_items, and products.products.

-- Q32: Display complete order information: customer name, order date, product names, quantities, and store location from customers.customers, sales.orders, sales.order_items, products.products, and stores.stores.

-- Q33: Show employee details with department, store location, and store total sales from stores.employees, stores.departments, stores.stores, and sales.orders.

-- Q34: List products with supplier name, category name, brand name, and total sales from products.products, products.suppliers, core.dim_category, core.dim_brand, and sales.order_items.

-- Q35: Display campaign performance: campaign name, channel, clicks, conversions, and customer engagement from marketing.campaigns, marketing.ads_spend, and marketing.email_clicks.

-- Q36: Show customer journey: customer name, order dates, product categories purchased, and payment modes from customers.customers, sales.orders, sales.order_items, products.products, and sales.payments.

-- Q37: List order fulfillment details: order ID, customer name, products, shipment status, and delivery time from sales.orders, customers.customers, sales.order_items, products.products, and sales.shipments.

-- Q38: Display inventory status: product name, supplier, store location, stock quantity, and sales velocity from products.products, products.suppliers, products.inventory, stores.stores, and sales.order_items.

-- Q39: Show comprehensive customer profile: demographics, order history, loyalty points, reviews, and returns from customers.customers, sales.orders, customers.loyalty_points, customers.reviews, and sales.returns.

-- Q40: List store performance: store details, employee count, total sales, expenses, and profit margin from stores.stores, stores.employees, sales.orders, and stores.expenses.

-- Q41: Find customers from Mumbai who have placed orders worth more than ₹50000 total from customers.customers and sales.orders.

-- Q42: Display products priced above ₹5000 that have been ordered more than 50 times from products.products and sales.order_items.

-- Q43: Show employees earning above ₹60000 working in stores with sales above ₹20 lakh from stores.employees, stores.stores, and sales.orders.

-- Q44: List orders placed in 2024 with order value exceeding ₹10000 from sales.orders.

-- Q45: Find products in Electronics category with average rating above 4.0 from products.products, core.dim_category, and customers.reviews.

-- Q46: Display campaigns with budget above ₹5 lakh that generated more than 1000 clicks from marketing.campaigns and marketing.ads_spend.

-- Q47: Show stores in Maharashtra with more than 15 employees from stores.stores and stores.employees.

-- Q48: List customers aged above 40 who have placed more than 10 orders from customers.customers and sales.orders.

-- Q49: Find suppliers whose products have return rate less than 5% from products.suppliers, products.products, sales.order_items, and sales.returns.

-- Q50: Display orders with payment mode 'Credit Card' and order amount above ₹15000 from sales.orders and sales.payments.

-- Q51: Calculate total revenue by product category for each store from stores.stores, sales.orders, sales.order_items, and products.products.

-- Q52: Find average order value by customer city and gender from customers.customers and sales.orders.

-- Q53: Show total expenses by expense type for each store from stores.stores and stores.expenses.

-- Q54: Calculate conversion rate (orders/clicks) for each marketing channel from marketing.ads_spend and sales.orders.

-- Q55: Find customer retention rate: customers who ordered in both 2023 and 2024 from customers.customers and sales.orders.

-- Q56: Display product performance: sales quantity, revenue, and profit margin by brand from products.products, core.dim_brand, and sales.order_items.

-- Q57: Show employee productivity: total sales per employee by department from stores.employees, stores.departments, stores.stores, and sales.orders.

-- Q58: Calculate inventory turnover ratio: sales/average stock by product category from products.products, products.inventory, and sales.order_items.

-- Q59: Find customer lifetime value: total spending and order frequency by customer segment from customers.customers and sales.orders.

-- Q60: Display supplier performance: product count, total sales, and average rating from products.suppliers, products.products, sales.order_items, and customers.reviews.

-- Q61: Join customers and orders where order_date matches customer join_date (same day registration and purchase) from customers.customers and sales.orders.

-- Q62: Find products where unit_price in orders differs from product price by more than 10% from products.products and sales.order_items.

-- Q63: Show employees whose salary is above their department's average salary from stores.employees and stores.departments.

-- Q64: List orders where total_amount is less than the sum of order_items (data integrity check) from sales.orders and sales.order_items.

-- Q65: Find customers whose total spending exceeds 2x their city's average spending from customers.customers and sales.orders.

-- Q66: Display products that are in stock in store A but out of stock in store B from products.inventory and stores.stores.

-- Q67: Show campaigns where ad spend exceeded the campaign budget from marketing.campaigns and marketing.ads_spend.

-- Q68: Find stores where total expenses exceed total revenue (loss-making stores) from stores.stores, sales.orders, and stores.expenses.

-- Q69: List employees working in stores outside their home state from stores.employees, stores.stores, and customers.customers.

-- Q70: Display orders where delivery took more than 7 days from sales.orders and sales.shipments.

-- Q71: Find the top 10 customers by total spending with their order count and average order value from customers.customers and sales.orders.

-- Q72: Display top 5 products by revenue with supplier name and category from products.products, products.suppliers, core.dim_category, and sales.order_items.

-- Q73: Show top 10 stores by profitability (revenue - expenses) with location details from stores.stores, sales.orders, and stores.expenses.

-- Q74: List top 5 employees by store sales contribution with their department from stores.employees, stores.departments, stores.stores, and sales.orders.

-- Q75: Find top 10 campaigns by ROI (revenue/spend) with channel information from marketing.campaigns, marketing.ads_spend, and sales.orders.

-- Q76: Display top 5 suppliers by total revenue from their products from products.suppliers, products.products, and sales.order_items.

-- Q77: Show top 10 product categories by sales volume from products.products, core.dim_category, and sales.order_items.

-- Q78: List top 5 cities by total customer spending from customers.customers and sales.orders.

-- Q79: Find top 10 most reviewed products with average rating from products.products and customers.reviews.

-- Q80: Display top 5 departments by average employee salary from stores.departments and stores.employees.

-- Q81: Find customers who ordered from multiple stores, showing customer name and store count from customers.customers, sales.orders, and stores.stores.

-- Q82: Display products sold in multiple stores with store count from products.products, sales.order_items, sales.orders, and stores.stores.

-- Q83: Show employees who have worked in multiple departments (if they changed) from stores.employees and stores.departments.

-- Q84: List campaigns that ran ads on multiple channels with channel count from marketing.campaigns and marketing.ads_spend.

-- Q85: Find suppliers who supply to multiple product categories with category count from products.suppliers, products.products, and core.dim_category.

-- Q86: Display customers who used multiple payment modes with payment mode count from customers.customers, sales.orders, and sales.payments.

-- Q87: Show products that have been returned for multiple reasons with reason count from products.products, sales.returns.

-- Q88: List stores that sell products from multiple suppliers with supplier count from stores.stores, sales.orders, sales.order_items, products.products, and products.suppliers.

-- Q89: Find customers who ordered products from multiple categories with category count from customers.customers, sales.orders, sales.order_items, and products.products.

-- Q90: Display orders with items from multiple brands with brand count from sales.orders, sales.order_items, and products.products.

-- Q91: Create a sales report showing monthly revenue by store and product category from sales.orders, sales.order_items, products.products, and stores.stores.

-- Q92: Generate customer segmentation report: demographics, purchase behavior, and value tier from customers.customers and sales.orders.

-- Q93: Build inventory health report: stock levels, sales velocity, and reorder recommendations from products.inventory, sales.order_items, and products.products.

-- Q94: Create employee performance dashboard: sales metrics, customer ratings, and attendance from stores.employees, sales.orders, customers.reviews, and hr.attendance.

-- Q95: Generate supplier scorecard: quality metrics, delivery performance, and sales contribution from products.suppliers, products.products, sales.order_items, and sales.returns.

-- Q96: Build campaign effectiveness report: spend, reach, engagement, and conversions from marketing.campaigns, marketing.ads_spend, marketing.email_clicks, and sales.orders.

-- Q97: Create product lifecycle report: introduction date, sales trend, and current status from products.products, sales.order_items, and sales.orders.

-- Q98: Generate store comparison report: size, performance, profitability, and rankings from stores.stores, stores.employees, sales.orders, and stores.expenses.

-- Q99: Build customer journey analysis: touchpoints, conversion path, and value realization from customers.customers, sales.orders, customers.reviews, and marketing.email_clicks.

-- Q100: Create comprehensive business dashboard: sales, customers, products, and operational metrics from all relevant tables across schemas.
