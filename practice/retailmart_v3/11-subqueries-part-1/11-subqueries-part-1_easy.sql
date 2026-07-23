/* ============================================================
   SQL PRACTICE SET - Subqueries Part 1 (EASY LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Subqueries Part 1 - scalar, IN, EXISTS, ANY/ALL
   Database:     RetailMart V3

   Scope:
     - Scalar subqueries (in SELECT, WHERE)
     - IN (subquery) / NOT IN
     - EXISTS / NOT EXISTS
     - ANY / SOME / ALL
     - Single-value subqueries
     - Subquery placement (FROM/SELECT/WHERE/HAVING)

   Structure: 25 Conceptual + 25 IN/EXISTS + 25 ANY/ALL + 25 Scalar subqueries
   ============================================================ */

/* ============================================================
   SECTION A: SUBQUERIES - CONCEPTUAL (25)
   ------------------------------------------------------------ */
/* Q1.  What is a subquery - and how is it different from a CTE? */
/* Q2.  What does "scalar subquery" mean - single row + single column. */
/* Q3.  Compare IN (subquery) vs EXISTS (subquery). */
/* Q4.  Why does NOT IN break when the subquery returns NULL? */
/* Q5.  What is a "correlated subquery"? */
/* Q6.  Compare = ANY(subquery) vs IN (subquery). */
/* Q7.  Compare > ALL(subquery) vs > (SELECT MAX...). */
/* Q8.  Can a subquery in SELECT return multiple rows? */
/* Q9.  Can a subquery in WHERE return multiple rows? */
/* Q10. Compare WHERE col = (subquery) vs WHERE col IN (subquery). */
/* Q11. What does (SELECT MAX(net_total) FROM ...) return - type? */
/* Q12. When is a subquery in FROM (derived table) required? */
/* Q13. Why must a subquery in FROM have an alias? */
/* Q14. Compare scalar subquery in SELECT vs JOIN - same result, different style. */
/* Q15. What is "semi-join" - and how does EXISTS implement it? */
/* Q16. What is "anti-join" - and how does NOT EXISTS implement it? */
/* Q17. Why does NOT EXISTS NOT have the NULL problem of NOT IN? */
/* Q18. Compare HAVING subquery vs WHERE subquery. */
/* Q19. Can a subquery reference its outer query's columns? (Yes if correlated.) */
/* Q20. Compare correlated subquery vs LEFT JOIN. */
/* Q21. Performance: when does the planner rewrite a subquery to a join? */
/* Q22. What is the "subquery cache" in some engines (not in Postgres). */
/* Q23. Compare uncorrelated subquery (executes once) vs correlated (executes per row). */
/* Q24. Why is "subquery returns more than one row" a common error? */
/* Q25. Compare subquery in SELECT vs subquery in WHERE for performance. */

/* ============================================================
   SECTION B: IN / NOT IN / EXISTS / NOT EXISTS (25)
   ------------------------------------------------------------ */
/* Q26. Find orders with cust_id IN (top 10 customers by spend). */
/* Q27. Find customers WHERE customer_id IN (SELECT cust_id FROM sales.orders). */
/* Q28. Find customers WHERE customer_id NOT IN (loyalty.members). */
/* Q29. Find products WHERE product_id IN (sales.order_items). */
/* Q30. Find tickets WHERE cust_id IN (high-spend customers). */
/* Q31. Find employees WHERE store_id IN (stores in 'Mumbai'). */
/* Q32. Find orders WHERE order_status IN ('Delivered','Cancelled','Returned'). */
/* Q33. Find products WHERE brand_id IN (brands of category 'Electronics'). */
/* Q34. Find shipments WHERE order_id IN (orders by Gold-tier customers). */
/* Q35. Find pay_slips WHERE employee_id IN (employees in 'Sales' dept). */
/* Q36. EXISTS: customers who placed orders. */
/* Q37. EXISTS: products with reviews. */
/* Q38. EXISTS: stores with employees. */
/* Q39. EXISTS: warehouses with snapshots. */
/* Q40. EXISTS: campaigns with spend. */
/* Q41. NOT EXISTS: customers without orders. */
/* Q42. NOT EXISTS: products without reviews. */
/* Q43. NOT EXISTS: brands without products. */
/* Q44. NOT EXISTS: employees without pay_slips. */
/* Q45. NOT EXISTS: orders without shipments. */
/* Q46. Combine EXISTS + filter: customers who placed > 5 orders. */
/* Q47. Combine NOT EXISTS + filter: products with no 5-star reviews. */
/* Q48. Compare LEFT JOIN IS NULL vs NOT EXISTS for anti-join. */
/* Q49. Use EXISTS inside SELECT (as boolean column). */
/* Q50. Use EXISTS in CASE expression. */

/* ============================================================
   SECTION C: ANY / SOME / ALL (25)
   ------------------------------------------------------------ */
/* Q51. Find products WHERE price > ANY(SELECT price FROM 'electronics'). */
/* Q52. Find orders WHERE net_total > ALL(SELECT net_total FROM orders WHERE store_id = 1). */
/* Q53. Find customers WHERE tier_id = ANY(SELECT tier_id FROM loyalty.tiers WHERE points > 1000). */
/* Q54. Find employees WHERE salary > ALL(SELECT salary FROM stores.employees WHERE role = 'Sales'). */
/* Q55. Find reviews WHERE rating < ANY(SELECT rating FROM customers.reviews WHERE product_id = 1). */
/* Q56. Find tickets WHERE priority = ANY(ARRAY['Critical','High']). */
/* Q57. Find products WHERE brand_id <> ALL(SELECT brand_id FROM dim_brand WHERE category_id = 1). */
/* Q58. Find orders WHERE net_total = (SELECT MAX(net_total) FROM sales.orders). */
/* Q59. Find products WHERE price = (SELECT MIN(price) FROM products.products). */
/* Q60. Find employees WHERE salary = (SELECT MAX(salary) FROM stores.employees WHERE dept_id = 1). */
/* Q61. Find orders WHERE net_total > (SELECT AVG(net_total) FROM sales.orders). */
/* Q62. Find loyalty members WHERE tier_id > (SELECT MIN(tier_id) FROM loyalty.members). */
/* Q63. Find pay_slips WHERE gross_salary > (SELECT AVG(gross_salary) FROM payroll.pay_slips). */
/* Q64. Find shipments WHERE delivered_date IS NULL AND shipped_date < (SELECT MIN(shipped_date) + INTERVAL '7 days' FROM ...). */
/* Q65. Find products WHERE supplier_id = ANY(SELECT supplier_id FROM products.suppliers WHERE city = 'Mumbai'). */
/* Q66. Compare = ANY vs IN - same result. */
/* Q67. Compare <> ALL vs NOT IN - same result. */
/* Q68. > ANY = greater than at least one. */
/* Q69. > ALL = greater than every. */
/* Q70. < ANY = less than at least one. */
/* Q71. < ALL = less than every. */
/* Q72. = SOME = synonym for = ANY. */
/* Q73. Combine ANY with array literal: x = ANY(ARRAY[1,2,3]). */
/* Q74. ANY with subquery returning 0 rows - what happens. */
/* Q75. ALL with subquery returning 0 rows - what happens (TRUE!). */

/* ============================================================
   SECTION D: SCALAR SUBQUERIES IN SELECT (25)
   ------------------------------------------------------------ */
/* Q76. For each order, show net_total + (SELECT AVG(net_total) FROM sales.orders) AS overall_avg. */
/* Q77. For each customer, show (SELECT COUNT(*) FROM sales.orders WHERE cust_id = c.customer_id) AS orders. */
/* Q78. For each product, show (SELECT AVG(rating) FROM customers.reviews WHERE product_id = p.product_id) AS avg_rating. */
/* Q79. For each store, show (SELECT COUNT(*) FROM stores.employees WHERE store_id = s.store_id) AS emp_count. */
/* Q80. For each campaign, show (SELECT SUM(amount) FROM marketing.ads_spend WHERE campaign_id = c.campaign_id) AS total_spend. */
/* Q81. For each region, show count of stores via scalar subquery. */
/* Q82. For each customer, show last order date. */
/* Q83. For each product, show last review date. */
/* Q84. For each employee, show last pay_slip month. */
/* Q85. For each ticket, show count of comments via scalar subquery. */
/* Q86. For each customer, show their tier_name via scalar subquery JOIN. */
/* Q87. For each order, show the customer's full_name. */
/* Q88. For each order, show the store's region_name. */
/* Q89. For each ticket, show the agent's full_name. */
/* Q90. For each shipment, show the order's customer email. */
/* Q91. Use scalar subquery in WHERE: WHERE net_total > (subq). */
/* Q92. Use scalar subquery in HAVING: HAVING SUM(amt) > (subq). */
/* Q93. Use scalar subquery in ORDER BY: ORDER BY (SELECT ...). */
/* Q94. Use scalar subquery in CASE: CASE WHEN x > (subq) THEN ... END. */
/* Q95. Multiple scalar subqueries in one SELECT (5 columns). */
/* Q96. Show "% of total revenue" per region using scalar denominator. */
/* Q97. Show "rank among peers" via correlated scalar subquery. */
/* Q98. Show "is_above_average" boolean column. */
/* Q99. Show "how far from max" - (max - this). */
/* Q100. Show "10 customer KPIs" all as scalar subqueries in one SELECT. */

/* ============================================================
   END OF Subqueries Part 1 - EASY LEVEL (100 QUESTIONS)
============================================================ */
