-- ================================================
-- Day 5: Aggregate Functions & Grouping
-- Level: EASY (100 Questions)
-- Topics: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING
-- ================================================

-- ## EASY

-- Q1: What is an aggregate function in SQL? Explain with examples.

-- Q2: What is the difference between COUNT(*) and COUNT(column_name)?

-- Q3: Explain the purpose of the SUM() function.

-- Q4: What does the AVG() function calculate?

-- Q5: Explain the difference between MIN() and MAX() functions.

-- Q6: What is the purpose of the GROUP BY clause?

-- Q7: Can we use aggregate functions without GROUP BY? Explain with an example.

-- Q8: What is the difference between WHERE and HAVING clause?

-- Q9: Explain why we cannot use WHERE clause to filter aggregated results.

-- Q10: What is the order of execution: GROUP BY or HAVING?

-- Q11: Can we use multiple aggregate functions in a single query? Give an example.

-- Q12: What does COUNT(DISTINCT column_name) do?

-- Q13: Explain how NULL values are handled in aggregate functions.

-- Q14: What is the purpose of using aliases with aggregate functions?

-- Q15: Can we use ORDER BY with aggregate functions? Explain.

-- Q16: What happens when you use GROUP BY with multiple columns?

-- Q17: Explain the syntax of the HAVING clause.

-- Q18: Can we use column aliases in GROUP BY clause?

-- Q19: What is the difference between SUM() and COUNT()?

-- Q20: Explain why AVG() might give different results than SUM()/COUNT().

-- Q21: What does GROUP BY do to duplicate values in a column?

-- Q22: Can we use aggregate functions in the SELECT clause without grouping all non-aggregated columns?

-- Q23: Explain how to find the total count of rows in a table.

-- Q24: What is the result of SUM() on a column with all NULL values?

-- Q25: Can HAVING clause be used without GROUP BY?

-- Q26: What is the purpose of using ROUND() with AVG() function?

-- Q27: Explain the order of clauses: SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY.

-- Q28: What happens if you use an aggregate function on an empty table?

-- Q29: Can we use WHERE and HAVING together in the same query?

-- Q30: Explain how to count only non-null values in a column.

-- Q31: What is the difference between grouping by one column vs multiple columns?

-- Q32: Can we use aggregate functions in WHERE clause? Why or why not?

-- Q33: Explain the purpose of COUNT(*) vs COUNT(1).

-- Q34: What does it mean when AVG() returns a decimal value?

-- Q35: How do aggregate functions handle text/string columns?

-- Q36: Can we apply multiple conditions in HAVING clause?

-- Q37: What is the result of MAX() on a date column?

-- Q38: Explain how MIN() works on string/text columns.

-- Q39: What happens when we GROUP BY a column with NULL values?

-- Q40: Can we use DISTINCT inside aggregate functions? Give examples.

-- Q41: What is the purpose of using CAST or ROUND with aggregate functions?

-- Q42: Explain the difference between filtering with WHERE before vs HAVING after aggregation.

-- Q43: Can we sort results by an aggregated column that's not in SELECT?

-- Q44: What does SUM(DISTINCT column_name) do?

-- Q45: Explain how to find minimum and maximum values in the same query.

-- Q46: What is the result of COUNT() on a column with empty strings vs NULL?

-- Q47: Can we use LIMIT with GROUP BY queries?

-- Q48: Explain how to calculate percentage using aggregate functions.

-- Q49: What is the difference between COUNT(column) and SUM(1)?

-- Q50: Can we nest aggregate functions like SUM(AVG(column))?

-- Q51: Count the total number of customers in the customers.customers table.

-- Q52: Find the total number of products in products.products table.

-- Q53: Count how many orders exist in sales.orders table.

-- Q54: How many employees work at RetailMart (stores.employees table)?

-- Q55: Count the total number of stores in stores.stores table.

-- Q56: Find the total number of suppliers in products.suppliers table.

-- Q57: Count how many departments exist in stores.departments.

-- Q58: How many reviews are there in customers.reviews table?

-- Q59: Count the total number of campaigns in marketing.campaigns.

-- Q60: Find the total count of shipments in sales.shipments.

-- Q61: Calculate the sum of all order amounts from sales.orders table (total_amount column).

-- Q62: Find the total of all salaries in stores.employees table.

-- Q63: What is the sum of all stock quantities in products.inventory (stock_qty column)?

-- Q64: Calculate the total refund amount from sales.returns (refund_amount column).

-- Q65: Find the sum of all loyalty points from customers.loyalty_points (total_points column).

-- Q66: Calculate the total budget from marketing.campaigns (budget column).

-- Q67: What is the sum of all payment amounts in sales.payments (amount column)?

-- Q68: Find the total expense amount from finance.expenses (amount column).

-- Q69: Calculate the sum of all quantities from sales.order_items (quantity column).

-- Q70: What is the total amount spent in marketing.ads_spend (amount column)?

-- Q71: Calculate the average age of all customers in customers.customers.

-- Q72: Find the average salary of employees in stores.employees.

-- Q73: What is the average price of products in products.products?

-- Q74: Calculate the average order amount from sales.orders.

-- Q75: Find the average rating from customers.reviews.

-- Q76: What is the average stock quantity in products.inventory?

-- Q77: Calculate the average discount from sales.order_items (discount column).

-- Q78: Find the average refund amount from sales.returns.

-- Q79: What is the average budget per campaign in marketing.campaigns?

-- Q80: Calculate the average clicks per ad spend in marketing.ads_spend.

-- Q81: Find the minimum age of customers in customers.customers.

-- Q82: What is the lowest salary in stores.employees?

-- Q83: Find the minimum product price in products.products.

-- Q84: What is the smallest order amount in sales.orders?

-- Q85: Find the earliest order_date in sales.orders.

-- Q86: What is the minimum rating given in customers.reviews?

-- Q87: Find the lowest stock quantity in products.inventory.

-- Q88: What is the minimum discount in sales.order_items?

-- Q89: Find the earliest join_date in customers.customers.

-- Q90: What is the minimum expense amount in finance.expenses?

-- Q91: Find the maximum age of customers in customers.customers.

-- Q92: What is the highest salary in stores.employees?

-- Q93: Find the maximum product price in products.products.

-- Q94: What is the largest order amount in sales.orders?

-- Q95: Find the latest order_date in sales.orders.

-- Q96: What is the maximum rating in customers.reviews?

-- Q97: Find the highest stock quantity in products.inventory.

-- Q98: What is the maximum discount in sales.order_items?

-- Q99: Find the latest join_date in customers.customers.

-- Q100: What is the maximum budget in marketing.campaigns?
