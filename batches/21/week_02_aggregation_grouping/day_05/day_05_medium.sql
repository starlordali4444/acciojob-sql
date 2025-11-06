-- ================================================
-- Day 5: Aggregate Functions & Grouping
-- Level: MEDIUM (100 Questions)
-- Topics: GROUP BY, Multiple Aggregates, HAVING
-- ================================================

-- ## MEDIUM

-- Q1: Count the number of customers in each city from customers.customers.

-- Q2: Find the total order amount (total_amount) for each store from sales.orders.

-- Q3: Calculate the average salary for each department in stores.employees.

-- Q4: Count how many products exist in each category from products.products.

-- Q5: Find the total stock quantity (stock_qty) for each store from products.inventory.

-- Q6: Calculate the average rating for each product (prod_id) in customers.reviews.

-- Q7: Count the number of orders placed by each customer from sales.orders.

-- Q8: Find the total payment amount for each payment_mode from sales.payments.

-- Q9: Calculate the average age of customers in each state from customers.customers.

-- Q10: Count how many employees work in each store from stores.employees.

-- Q11: Find the total expense amount for each expense_type from stores.expenses.

-- Q12: Calculate the sum of quantities ordered for each product from sales.order_items.

-- Q13: Find the average product price for each brand in products.products.

-- Q14: Count the number of reviews given by each customer from customers.reviews.

-- Q15: Calculate the total refund amount for each product from sales.returns.

-- Q16: Find the total order amount for each order_status from sales.orders.

-- Q17: Count how many orders were placed in each month of 2024 from sales.orders.

-- Q18: Calculate the total amount spent on each channel from marketing.ads_spend.

-- Q19: Find the average discount for each product from sales.order_items.

-- Q20: Count the number of shipments for each courier_name from sales.shipments.

-- Q21: Calculate the total clicks for each campaign from marketing.ads_spend.

-- Q22: Find the average age by gender from customers.customers.

-- Q23: Count products in each price range: 0-1000, 1001-5000, 5001-10000, 10000+ from products.products.

-- Q24: Calculate the total quantity sold for each category from sales.order_items.

-- Q25: Find the number of employees in each role from stores.employees.

-- Q26: Calculate the average order amount for each customer from sales.orders.

-- Q27: Count the number of addresses for each customer from customers.addresses.

-- Q28: Find the total refund amount by reason from sales.returns.

-- Q29: Calculate the average stock quantity for each product from products.inventory.

-- Q30: Count the number of orders in each quarter from sales.orders.

-- Q31: Find categories with average product price above ₹2000 from products.products.

-- Q32: Show customers with more than 5 orders from sales.orders.

-- Q33: Find stores with total expenses exceeding ₹5 lakh from stores.expenses.

-- Q34: Calculate departments where average salary is above ₹50000 from stores.employees.

-- Q35: Show suppliers with more than 10 products from products.products.

-- Q36: Find payment modes with total amount above ₹10 lakh from sales.payments.

-- Q37: Show states with average customer age above 35 from customers.customers.

-- Q38: Find products ordered more than 100 times (sum of quantity) from sales.order_items.

-- Q39: Show products with total refunds exceeding ₹10000 from sales.returns.

-- Q40: Find stores with more than 20 employees from stores.employees.

-- Q41: Show categories where minimum product price is above ₹1000 from products.products.

-- Q42: Find customers with total order amount exceeding ₹50000 from sales.orders.

-- Q43: Show campaigns with budget above ₹5 lakh from marketing.campaigns.

-- Q44: Find products with average rating above 4.5 from customers.reviews.

-- Q45: Show stores with average order amount below ₹5000 from sales.orders.

-- Q46: Find brands with more than 20 products from products.products.

-- Q47: Show cities with more than 100 customers from customers.customers.

-- Q48: Find months in 2024 with order count less than 50 from sales.orders.

-- Q49: Show departments with total salary expense exceeding ₹10 lakh from stores.employees.

-- Q50: Find products with stock quantity less than 5 in any store from products.inventory.

-- Q51: Count the number of orders and total order amount for each customer from sales.orders.

-- Q52: Find minimum and maximum salary for each department from stores.employees.

-- Q53: Calculate count of products and average price for each category from products.products.

-- Q54: Find total quantity and total revenue (quantity * unit_price) for each product from sales.order_items.

-- Q55: Count employees and average salary for each store from stores.employees.

-- Q56: Calculate order count and average order amount for each order_status from sales.orders.

-- Q57: Find total clicks and conversions for each campaign from marketing.ads_spend.

-- Q58: Count customers and average age for each city from customers.customers.

-- Q59: Calculate min, max, and average price for each brand from products.products.

-- Q60: Count reviews and average rating for each product from customers.reviews.

-- Q61: Find total orders and average order value per customer from sales.orders.

-- Q62: Calculate total expense and count of expenses for each store from stores.expenses.

-- Q63: Find number of products and total inventory value for each store from products.inventory.

-- Q64: Count shipments by status for each courier from sales.shipments.

-- Q65: Calculate total spent and order count for each payment_mode from sales.payments.

-- Q66: Find count of male and female customers in each state from customers.customers.

-- Q67: Calculate total quantity sold for each brand from sales.order_items.

-- Q68: Find number of campaigns and total budget by year from marketing.campaigns.

-- Q69: Count returns and total refund amount for each product from sales.returns.

-- Q70: Calculate average discount for each category from sales.order_items.

-- Q71: Show top 5 stores by total order amount from sales.orders, ordered descending.

-- Q72: Find top 10 customers by total spending from sales.orders, ordered descending.

-- Q73: Show top 5 products by total quantity sold from sales.order_items, ordered descending.

-- Q74: Find top 3 categories by average product price from products.products, ordered descending.

-- Q75: Show top 10 employees by salary from stores.employees, ordered descending.

-- Q76: Find top 5 suppliers by number of products from products.products, ordered descending.

-- Q77: Show top 5 cities by customer count from customers.customers, ordered descending.

-- Q78: Find top 3 payment modes by total amount from sales.payments, ordered descending.

-- Q79: Show top 5 brands by number of products from products.products, ordered descending.

-- Q80: Find top 10 campaigns by total budget from marketing.campaigns, ordered descending.

-- Q81: Find stores with order count greater than 100 and average order amount above ₹5000 from sales.orders.

-- Q82: Show products with rating above 4.0 and at least 20 reviews from customers.reviews.

-- Q83: Find categories with more than 30 products and average price below ₹3000 from products.products.

-- Q84: Show customers with more than 10 orders and total spending above ₹1 lakh from sales.orders.

-- Q85: Find stores with more than 15 employees and average salary above ₹60000 from stores.employees.

-- Q86: Show campaigns with clicks above 1000 from marketing.ads_spend (sum clicks per campaign).

-- Q87: Find products with stock below 10 units in at least 3 stores from products.inventory.

-- Q88: Show departments with employee count between 5 and 20 from stores.employees.

-- Q89: Find cities with customer count between 50 and 200 from customers.customers.

-- Q90: Show brands with product count above 15 and average price above ₹5000 from products.products.

-- Q91: Calculate the total sales for each region from sales.orders and stores.stores.

-- Q92: Find the customer count and total spending for each region from customers.customers and sales.orders.

-- Q93: Calculate customer distribution by age groups: 18-25, 26-35, 36-45, 46+ from customers.customers.

-- Q94: Find total sales and total expenses for each store from sales.orders and stores.expenses.

-- Q95: Calculate the average order value for each day of week (extract from order_date) from sales.orders.

-- Q96: Find suppliers who supply more than one category from products.products.

-- Q97: Calculate total stock quantity and number of products for each category from products.inventory and products.products.

-- Q98: Find the most frequent order status for each store from sales.orders.

-- Q99: Calculate revenue per store per month for 2024 from sales.orders.

-- Q100: Find customers who have ordered every month in 2024 from sales.orders.
