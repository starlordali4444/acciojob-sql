-- ================================================
-- Day 6: Conditional Logic & Derived Columns
-- Level: EASY (100 Questions)
-- Topics: CASE WHEN, COALESCE, NULLIF, Derived Columns, Aliases
-- ================================================

-- ## EASY

-- Q1: What is a CASE WHEN statement in SQL? Explain its purpose.

-- Q2: What is the syntax of a simple CASE statement?

-- Q3: Explain the difference between simple CASE and searched CASE.

-- Q4: What does the ELSE clause do in a CASE statement?

-- Q5: What happens if ELSE is not specified in CASE WHEN and no conditions match?

-- Q6: What is COALESCE function and why is it used?

-- Q7: Explain the syntax of COALESCE with an example.

-- Q8: What is the difference between COALESCE and CASE WHEN for handling NULLs?

-- Q9: What does NULLIF function do?

-- Q10: Explain the syntax of NULLIF with an example.

-- Q11: What is a derived column? Give an example.

-- Q12: What is a computed column? How is it different from an existing column?

-- Q13: What is the purpose of using aliases (AS) with derived columns?

-- Q14: Can we use aggregate functions inside CASE WHEN? Explain.

-- Q15: Can we nest CASE statements? Give an example scenario.

-- Q16: What is the order of evaluation in a CASE WHEN statement?

-- Q17: Explain how CASE WHEN can be used for data categorization.

-- Q18: What data types can CASE WHEN return?

-- Q19: Can we use CASE WHEN in WHERE clause? Explain.

-- Q20: Can we use CASE WHEN in ORDER BY clause?

-- Q21: What is the difference between COALESCE and ISNULL?

-- Q22: Can COALESCE accept more than 2 arguments?

-- Q23: What does NULLIF return if both arguments are equal?

-- Q24: What does NULLIF return if arguments are different?

-- Q25: Can we use CASE WHEN with GROUP BY?

-- Q26: Explain how to create conditional aggregations using CASE.

-- Q27: What is the purpose of using aliases for tables?

-- Q28: Can we use column aliases in WHERE clause? Why or why not?

-- Q29: Can we use column aliases in ORDER BY clause?

-- Q30: What is the difference between column alias and table alias?

-- Q31: Can we perform mathematical operations to create derived columns?

-- Q32: How do we concatenate strings to create derived columns?

-- Q33: Can we use CASE WHEN to handle division by zero errors?

-- Q34: Explain how COALESCE handles multiple NULL values.

-- Q35: What is the result of COALESCE(NULL, NULL, 'Default')?

-- Q36: Can we use CASE WHEN in INSERT statements?

-- Q37: Can we use CASE WHEN in UPDATE statements?

-- Q38: What is nested CASE? Give a simple example.

-- Q39: How do we create flag columns (0/1 or Yes/No) using CASE?

-- Q40: Can CASE WHEN return different data types in different branches?

-- Q41: What is the maximum number of WHEN conditions we can have in CASE?

-- Q42: How do we handle multiple conditions in a single WHEN clause?

-- Q43: Can we use subqueries inside CASE WHEN?

-- Q44: What is conditional aggregation? Give an example.

-- Q45: How do we count rows based on conditions using CASE?

-- Q46: Can we use CASE WHEN with DISTINCT?

-- Q47: What is the difference between CASE WHEN and IF statement?

-- Q48: How do we create age groups using CASE WHEN?

-- Q49: How do we create price ranges using CASE WHEN?

-- Q50: Can we use LIKE operator inside CASE WHEN?

-- Q51: Display all customer names with their ages from customers.customers.

-- Q52: Create a derived column showing full address by concatenating city and state from customers.customers.

-- Q53: Calculate the discounted price (price - 10%) for all products from products.products.

-- Q54: Show order_id and calculated total with tax (total_amount * 1.18) from sales.orders.

-- Q55: Create a column showing 'Male' or 'Female' instead of 'M' or 'F' from customers.customers using CASE.

-- Q56: Display product names with 'Expensive' if price > 10000, else 'Affordable' from products.products.

-- Q57: Show employee names with 'High Earner' if salary > 80000, else 'Regular' from stores.employees.

-- Q58: Create age groups: 'Young' (age < 30), 'Middle' (30-50), 'Senior' (>50) from customers.customers.

-- Q59: Categorize orders as 'Small' (< 5000), 'Medium' (5000-20000), 'Large' (>20000) from sales.orders.

-- Q60: Show products with 'Low Stock' if stock_qty < 10, else 'Available' from products.inventory.

-- Q61: Use COALESCE to replace NULL region_name with 'Unknown' from customers.customers.

-- Q62: Use COALESCE to show rating or 0 if rating is NULL from customers.reviews.

-- Q63: Replace NULL discount with 0 from sales.order_items using COALESCE.

-- Q64: Show employee name with department name, or 'No Department' if NULL from stores.employees.

-- Q65: Use COALESCE to show refund_amount or 0 from sales.returns.

-- Q66: Use NULLIF to return NULL if order_status is 'Cancelled' from sales.orders.

-- Q67: Use NULLIF to return NULL when discount is 0 from sales.order_items.

-- Q68: Apply NULLIF to prevent division by zero: show sales per employee from sales.orders and stores.employees.

-- Q69: Use NULLIF to return NULL if stock_qty is 0 from products.inventory.

-- Q70: Show customer name with NULLIF returning NULL if city is 'Unknown' from customers.customers.

-- Q71: Create a column 'order_value_category' showing 'High', 'Medium', 'Low' based on total_amount from sales.orders.

-- Q72: Show product brand with 'Top Brand' or 'Regular Brand' based on price from products.products.

-- Q73: Categorize employees by salary range with CASE WHEN from stores.employees.

-- Q74: Show review sentiment: 'Positive' (rating >= 4), 'Neutral' (3), 'Negative' (<3) from customers.reviews.

-- Q75: Create shipping status: 'Fast' if delivered in 3 days, else 'Standard' from sales.shipments.

-- Q76: Calculate profit margin (unit_price - discount) for each order item from sales.order_items.

-- Q77: Show customer loyalty tier based on total_points from customers.loyalty_points.

-- Q78: Categorize campaigns by budget: 'Premium', 'Standard', 'Basic' from marketing.campaigns.

-- Q79: Show order priority: 'Urgent' if order_date is recent, else 'Normal' from sales.orders.

-- Q80: Create expense category flags from stores.expenses.

-- Q81: Calculate total revenue (quantity * unit_price) for each order item from sales.order_items.

-- Q82: Show net amount after discount (unit_price - discount) * quantity from sales.order_items.

-- Q83: Calculate customer age from join_date (assuming current year 2024) from customers.customers.

-- Q84: Show days since last order for each customer from sales.orders.

-- Q85: Calculate average rating per customer from customers.reviews.

-- Q86: Show salary increment (salary * 1.10) for all employees from stores.employees.

-- Q87: Calculate stock value (stock_qty * price) from products.inventory and products.products.

-- Q88: Show campaign duration in days (end_date - start_date) from marketing.campaigns.

-- Q89: Calculate expense percentage of budget from stores.expenses.

-- Q90: Show order fulfillment time (delivered_date - order_date) from sales.orders and sales.shipments.

-- Q91: Use CASE to show 'Active' if join_date > '2023-01-01', else 'Old' customer from customers.customers.

-- Q92: Categorize stores by region using CASE from stores.stores.

-- Q93: Show payment status based on amount using CASE from sales.payments.

-- Q94: Create product availability status from products.inventory.

-- Q95: Show campaign performance based on clicks from marketing.ads_spend.

-- Q96: Use COALESCE to handle NULL values in review_text from customers.reviews.

-- Q97: Show supplier name or 'Direct' if NULL from products.products.

-- Q98: Use CASE to show quarter from order_date from sales.orders.

-- Q99: Categorize delivery time as 'On-Time' or 'Delayed' from sales.shipments.

-- Q100: Create customer segment based on age and gender from customers.customers.
