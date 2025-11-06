-- ================================================
-- Day 7: Joins (Foundations & Advanced)
-- Level: EASY (100 Questions)
-- Topics: INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN, CROSS JOIN
-- ================================================

-- ## EASY

-- Q1: What is a JOIN in SQL? Explain its purpose.

-- Q2: What is the difference between INNER JOIN and OUTER JOIN?

-- Q3: Explain the syntax of INNER JOIN with an example.

-- Q4: What does INNER JOIN return?

-- Q5: What is a LEFT JOIN (LEFT OUTER JOIN)?

-- Q6: What is the difference between LEFT JOIN and RIGHT JOIN?

-- Q7: What does a RIGHT JOIN return?

-- Q8: What is a FULL JOIN (FULL OUTER JOIN)?

-- Q9: What is a CROSS JOIN? When would you use it?

-- Q10: What is the difference between INNER JOIN and CROSS JOIN?

-- Q11: What is a join condition? Give an example.

-- Q12: What happens if you don't specify a join condition in INNER JOIN?

-- Q13: Explain the ON clause in JOIN statements.

-- Q14: Can we use WHERE clause with JOIN? What's the difference between ON and WHERE?

-- Q15: What are the common columns used for joining tables?

-- Q16: What is a primary key and foreign key relationship in joins?

-- Q17: Can we join more than two tables? Explain.

-- Q18: What is the order of execution when joining multiple tables?

-- Q19: How do LEFT JOIN handle NULL values?

-- Q20: How do RIGHT JOIN handle NULL values?

-- Q21: What does FULL JOIN return when there's no match?

-- Q22: Can we join a table to itself? What is it called?

-- Q23: What is table aliasing in joins? Why is it useful?

-- Q24: What is the difference between JOIN and INNER JOIN keywords?

-- Q25: Can we use multiple conditions in the ON clause?

-- Q26: What is a natural join?

-- Q27: What happens when join columns have NULL values?

-- Q28: Can we join tables from different schemas?

-- Q29: What is the difference between equi-join and non-equi-join?

-- Q30: What is a Cartesian product in context of joins?

-- Q31: How do you avoid Cartesian products?

-- Q32: Can we use aggregate functions with joins?

-- Q33: Can we use GROUP BY with joins?

-- Q34: What is the impact of join order on performance?

-- Q35: What is a multi-table join?

-- Q36: Can we combine different types of joins in one query?

-- Q37: What is the difference between implicit and explicit join syntax?

-- Q38: How do you join tables with composite keys?

-- Q39: Can we use subqueries in join conditions?

-- Q40: What is an anti-join pattern?

-- Q41: What is a semi-join pattern?

-- Q42: How do LEFT JOIN differ from LEFT OUTER JOIN?

-- Q43: What is the result of joining two empty tables?

-- Q44: Can we join tables without a common column?

-- Q45: What happens when multiple rows match in a join?

-- Q46: How do you count records after a join?

-- Q47: What is the difference between joining on equality vs inequality?

-- Q48: Can we use CASE WHEN in join conditions?

-- Q49: How do you handle many-to-many relationships in joins?

-- Q50: What are the best practices for writing efficient joins?

-- Q51: Join customers and orders to show customer names with their order IDs from customers.customers and sales.orders.

-- Q52: Display product names with their supplier names using INNER JOIN from products.products and products.suppliers.

-- Q53: Show employee names with their department names from stores.employees and stores.departments.

-- Q54: List all orders with their store names from sales.orders and stores.stores.

-- Q55: Display customer names with their review ratings from customers.customers and customers.reviews.

-- Q56: Show order items with product names from sales.order_items and products.products.

-- Q57: List employees with their store locations (city, state) from stores.employees and stores.stores.

-- Q58: Display orders with customer city information from sales.orders and customers.customers.

-- Q59: Show products with their category names from products.products and core.dim_category.

-- Q60: List campaigns with their total ad spend from marketing.campaigns and marketing.ads_spend.

-- Q61: Use LEFT JOIN to show all customers and their orders (including customers with no orders) from customers.customers and sales.orders.

-- Q62: Display all products and their reviews (including products with no reviews) from products.products and customers.reviews.

-- Q63: Show all stores and their employees (including stores with no employees) from stores.stores and stores.employees.

-- Q64: List all customers and their loyalty points (including customers with no loyalty points) from customers.customers and customers.loyalty_points.

-- Q65: Display all orders and their payments (including orders with no payments) from sales.orders and sales.payments.

-- Q66: Show all products and their inventory status (including products not in inventory) from products.products and products.inventory.

-- Q67: List all campaigns and their email clicks (including campaigns with no clicks) from marketing.campaigns and marketing.email_clicks.

-- Q68: Display all orders and their shipment details (including orders not yet shipped) from sales.orders and sales.shipments.

-- Q69: Show all suppliers and their products (including suppliers with no products) from products.suppliers and products.products.

-- Q70: List all customers and their addresses (including customers with no addresses) from customers.customers and customers.addresses.

-- Q71: Use RIGHT JOIN to show all orders and customer details (including orders without customer info) from customers.customers and sales.orders.

-- Q72: Display all reviews with customer names (including orphaned reviews) from customers.customers and customers.reviews.

-- Q73: Show all departments with employee count (including empty departments) from stores.departments and stores.employees.

-- Q74: List all products with order quantities (including unordered products) from products.products and sales.order_items.

-- Q75: Display all stores with their total expenses (including stores with no expense records) from stores.stores and stores.expenses.

-- Q76: Use FULL JOIN to show all customers and orders (including unmatched records) from customers.customers and sales.orders.

-- Q77: Display all products and inventory (showing both unordered products and orphaned inventory) from products.products and products.inventory.

-- Q78: Show all employees and attendance records (including employees with no attendance and attendance without employees) from stores.employees and hr.attendance.

-- Q79: List all campaigns and ads spend (including campaigns with no spend and spend without campaigns) from marketing.campaigns and marketing.ads_spend.

-- Q80: Display all orders and returns (including non-returned orders and returns without orders) from sales.orders and sales.returns.

-- Q81: Join three tables: customers, orders, and order_items to show customer names with product quantities from customers.customers, sales.orders, and sales.order_items.

-- Q82: Display employee names, department names, and store names from stores.employees, stores.departments, and stores.stores.

-- Q83: Show product names, category names, and brand names from products.products, core.dim_category, and core.dim_brand.

-- Q84: List customer names, order dates, and payment modes from customers.customers, sales.orders, and sales.payments.

-- Q85: Display order IDs, product names, and shipment status from sales.orders, sales.order_items, products.products, and sales.shipments.

-- Q86: Join customers, orders, and stores to show customer names with store locations from customers.customers, sales.orders, and stores.stores.

-- Q87: Show campaign names, channels, and customer emails from marketing.campaigns, marketing.ads_spend, and marketing.email_clicks.

-- Q88: Display product names, supplier names, and inventory quantities from products.products, products.suppliers, and products.inventory.

-- Q89: List employee names, departments, and their store's total sales from stores.employees, stores.departments, and sales.orders.

-- Q90: Show customer names, review ratings, and product names from customers.customers, customers.reviews, and products.products.

-- Q91: Count how many orders each customer has placed using JOIN and GROUP BY from customers.customers and sales.orders.

-- Q92: Calculate total sales amount for each store using JOIN from sales.orders and stores.stores.

-- Q93: Find average product price by category using JOIN from products.products and core.dim_category.

-- Q94: Count reviews per product using JOIN from products.products and customers.reviews.

-- Q95: Calculate total quantity sold per supplier using JOIN from products.suppliers, products.products, and sales.order_items.

-- Q96: Find total expenses by store using JOIN from stores.stores and stores.expenses.

-- Q97: Count employees per department using JOIN from stores.departments and stores.employees.

-- Q98: Calculate average order value per customer using JOIN from customers.customers and sales.orders.

-- Q99: Find total loyalty points by customer region using JOIN from customers.customers and customers.loyalty_points.

-- Q100: Calculate total campaign clicks by channel using JOIN from marketing.campaigns and marketing.ads_spend.
