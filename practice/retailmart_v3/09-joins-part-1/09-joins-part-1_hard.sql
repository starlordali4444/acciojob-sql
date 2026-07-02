/* ============================================================
   SQL PRACTICE SET - JOINs Part 1 (Foundations) (HARD LEVEL)
   Curriculum:   RetailMart V3
   Topic:        JOINs Part 1 - advanced patterns
   Database:     RetailMart V3

   Scope (HARD):
     - JOIN planner choices (hash/merge/nested loop)
     - Non-equi JOINs (range, BETWEEN)
     - Multi-column JOINs
     - JOIN with subqueries / LATERAL preview
     - Anti-join variations (LEFT-NULL, NOT EXISTS, EXCEPT)
     - SEMI-JOIN patterns
     - Fan-out detection + COUNT correction
     - JOIN + GROUP BY pitfalls
     - Self-anti-join

   Structure: 25 Conceptual + 25 Non-equi/multi-col + 25 Anti-/semi-join + 25 Multi-table chains
   ============================================================ */

/* ============================================================
   SECTION A: JOINs - CONCEPTUAL DEEP (25)
   ------------------------------------------------------------ */
/* Q1.  When does the planner pick Hash Join vs Merge Join vs Nested Loop? */
/* Q2.  Why does adding ORDER BY join_key encourage Merge Join? */
/* Q3.  Compare hash join build/probe phases - which side is hashed. */
/* Q4.  What is a "broadcast join" - and does Postgres do it? */
/* Q5.  Why is INNER JOIN ON a.x = b.y faster than CROSS JOIN + WHERE? (Hint: same plan in modern engines.) */
/* Q6.  Why is JOIN ON a.x = b.y AND a.z = b.z faster with a composite index (x, z)? */
/* Q7.  Non-equi join: WHERE a.range_start <= b.event_date <= a.range_end - give a RetailMart case. */
/* Q8.  Range join in Postgres - what indexes help (GIST on tsrange)? */
/* Q9.  Compare LATERAL JOIN vs correlated subquery - same idea, different syntax. */
/* Q10. Anti-join three ways: LEFT JOIN IS NULL vs NOT EXISTS vs EXCEPT. */
/* Q11. SEMI-JOIN: when does Postgres convert EXISTS to a semi-join? */
/* Q12. Fan-out: how does it create row multiplication in aggregations? */
/* Q13. How do you detect fan-out (compare COUNT(*) vs expected)? */
/* Q14. Why does GROUP BY after a fan-out join over-count SUM? */
/* Q15. Why is JOIN order irrelevant for INNER but critical for OUTER? */
/* Q16. How does the planner decide JOIN order (join_collapse_limit)? */
/* Q17. What is "estimated rows mismatch" - and why bad row estimates kill performance? */
/* Q18. Walk through a triangle inequality JOIN: a.x + b.y > c.z. */
/* Q19. Why is JOIN through a many-to-many bridge table called a "fan-out fan-in"? */
/* Q20. Compare JOIN ON (a.x, a.y) = (b.x, b.y) vs separate AND. */
/* Q21. Explain how OUTER JOIN's qualifying-side filter pushed into ON differs from WHERE. */
/* Q22. What is "join reordering" - and how does the planner explore options? */
/* Q23. Why does adding indexes BOTH sides of a JOIN help? */
/* Q24. Why is `WHERE a.x = b.x` (comma syntax) equivalent to INNER JOIN but missing the OUTER semantics? */
/* Q25. Walk through Postgres's "implicit JOIN" rewriting. */

/* ============================================================
   SECTION B: NON-EQUI / MULTI-COL JOINS (25)
   ------------------------------------------------------------ */
/* Q26. Range join: orders to campaigns running on the order_date (order_date BETWEEN start/end). */
/* Q27. Range join: orders to promotions active on the order_date. */
/* Q28. Range join: page_views to campaigns running during the view. */
/* Q29. Range join: pay_slip to its tax bracket (gross_salary BETWEEN min_salary AND max_salary). */
/* Q30. Range join: employee salary to its tax bracket. */
/* Q31. Multi-col join: order_items (via their order's store) to products.inventory on (store_id, product_id). */
/* Q32. Multi-col join: pay_slip to attendance on (employee_id, year). */
/* Q33. Multi-col join: inventory_snapshot to supply_chain.shipment on (warehouse_id, product_id, date). */
/* Q34. Multi-col join: order_items to returns on (order_id, prod_id). */
/* Q35. Join + filter: orders to the customer's DEFAULT address (customer_id AND is_default). */
/* Q36. INNER JOIN with a > predicate: line items priced above the product's list price. */
/* Q37. Triangle JOIN: three products whose two cheaper prices exceed the third (bundle pricing). */
/* Q38. JOIN where order_date is within 7 days of a campaign's start_date. */
/* Q39. JOIN where the customer's default-address city = store's city (proxy for "local order"). */
/* Q40. JOIN with a composite key derived in a CTE (clean city from addresses). */
/* Q41. Range JOIN: gaps-and-islands warmup (each order to the customer's NEXT order). */
/* Q42. JOIN orders to their shipment, keeping only Delivered shipments. */
/* Q43. JOIN orders to the customer's loyalty tier ("tier at order time" proxy). */
/* Q44. JOIN with date_trunc to align granularity (month). */
/* Q45. JOIN ON expression: orders bucketed into seasons (CASE-based). */
/* Q46. Self-equality on derived key: orders sharing the first 4 digits of order_id. */
/* Q47. Prefix self-join: products sharing the first 3 letters of product_name. */
/* Q48. Same-brand product pairs (self-join on brand_id). */
/* Q49. Chain join: product -> brand -> category. */
/* Q50. Join reviews to the product and the reviewing customer. */

/* ============================================================
   SECTION C: ANTI-JOIN & SEMI-JOIN PATTERNS (25)
   ------------------------------------------------------------ */
/* Q51. Anti-join 3 ways: customers never ordered (LEFT IS NULL, NOT EXISTS, EXCEPT). */
/* Q52. Anti-join: products with no reviews. */
/* Q53. Anti-join: employees never assigned a ticket as agent. */
/* Q54. Anti-join: customers with orders but no loyalty membership. */
/* Q55. Anti-join: orders with no shipment. */
/* Q56. Anti-join: ad spend rows with no matching campaign. */
/* Q57. Anti-join: inventory_snapshot rows where product no longer exists. */
/* Q58. Anti-join: pay_slips for employees no longer in stores.employees. */
/* Q59. Anti-join: tickets created by deleted customers (orphans). */
/* Q60. Anti-join: warehouses with no shipments in last 90 days. */
/* Q61. Anti-join: customers who never wrote a review for products they bought. */
/* Q62. Semi-join: customers who placed AT LEAST one order (EXISTS). */
/* Q63. Semi-join: products with ANY review. */
/* Q64. Semi-join: stores with employees AND orders AND inventory. */
/* Q65. Semi-join: agents who handled BOTH tickets AND calls. */
/* Q66. Find products sold in MULTIPLE regions (semi-join with HAVING COUNT > 1). */
/* Q67. Find customers with returns AND no follow-up order. */
/* Q68. Find suppliers who ship to ALL warehouses (relational division). */
/* Q69. Find brands present in EVERY region (relational division). */
/* Q70. Find customers who placed orders in BOTH 2024 AND 2025. */
/* Q71. Find products in inventory with no order_items linkage. */
/* Q72. Find pay_slips with no matching attendance record (same employee + year). */
/* Q73. Find campaigns with no spend rows. */
/* Q74. Find employees (agents) with NO calls handled in the last 30 days. */
/* Q75. Find shipments referencing deleted orders (FK enforce check). */

/* ============================================================
   SECTION D: MULTI-TABLE CHAINS (3+ TABLES)
   ------------------------------------------------------------ */
/* Q76. 6-table chain: order -> order_item -> product -> brand -> category -> supplier. */
/* Q77. 5-table customer 360deg: customer -> order -> order_item -> product (+ review). */
/* Q78. Workforce chain: employee -> pay_slip + department + store. */
/* Q79. Marketing chain: campaign + ad spend + email engagement (clicks). */
/* Q80. Inventory chain: snapshot -> warehouse + product + supplier (+ shipment). */
/* Q81. Support chain: ticket -> customer + handling agent. */
/* Q82. Detect fan-out: COUNT(*) of orders JOIN order_items vs distinct orders. */
/* Q83. Subquery aggregation to avoid fan-out: pre-aggregate order_items into a CTE, then JOIN. */
/* Q84. Fan-in: DISTINCT cust_id COUNT among multi-unit order lines. */
/* Q85. 5-table count: customer -> order -> item -> product -> brand (line items per customer). */
/* Q86. Items per order (orders x order_items, grouped). */
/* Q87. Revenue by region: region -> store -> order. */
/* Q88. Lifetime revenue per customer (customer -> order). */
/* Q89. Order value from its items (order -> order_items). */
/* Q90. Products per category: category -> brand -> product. */
/* Q91. Re-write a JOIN as EXISTS (semi-join): customers with at least one order. */
/* Q92. Convert a correlated subquery to a LEFT JOIN against a derived table. */
/* Q93. Products per supplier (supplier -> product). */
/* Q94. Use a MATERIALIZED CTE to pre-compute item totals, then join. */
/* Q95. Returns with their order and customer. */
/* Q96. Calls with their customer and handling agent. */
/* Q97. Payments with their order and customer. */
/* Q98. Orders since 2025 by store (store -> order, grouped). */
/* Q99. Build a "BI report" query: region -> store -> order, aggregated. */
/* Q100. Audit query: a customer table with metrics across multiple schemas (correlated subqueries). */

/* ============================================================
   END OF JOINs Part 1 (Foundations) - HARD LEVEL (100 QUESTIONS)
============================================================ */
