/* ============================================================
   SQL PRACTICE SET - Subqueries Part 1 (CRAZY LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Subqueries Part 1 - production-grade rewrites
   Database:     RetailMart V3

   Scope (CRAZY):
     - Subquery + window function combinations
     - Production query patterns (top-N, percentile, gap)
     - Complex multi-table subquery chains
     - Subquery in DML (UPDATE/DELETE)
     - Subquery in DDL (CREATE TABLE AS, ALTER)
     - Subquery in views / materialized views
     - Recursive subquery thinking

   Structure: 25 Subquery+Window + 25 Multi-source + 25 DML subqueries + 25 Real reports
   ============================================================ */

/* ============================================================
   SECTION A: SUBQUERY + WINDOW (25)
   ------------------------------------------------------------ */
/* Q1.  Top-N per group via DISTINCT ON + subquery. */
/* Q2.  Top-N per group via ROW_NUMBER. */
/* Q3.  Top-3 customers per region. */
/* Q4.  Top-5 products per category. */
/* Q5.  Top-10 stores per region. */
/* Q6.  Top-N + tiebreaker via composite ORDER BY. */
/* Q7.  Per row, percent of group total via window. */
/* Q8.  Per row, percent of grand total via subquery + window. */
/* Q9.  Running total per group. */
/* Q10. Year-over-year growth via window. */
/* Q11. Quarter-over-quarter growth. */
/* Q12. Month-over-month. */
/* Q13. Customer lifetime: window of all orders. */
/* Q14. RFM bucket via NTILE + subquery. */
/* Q15. NTILE quartile of order_total. */
/* Q16. Median per group via percentile_cont. */
/* Q17. Top-3 cheapest per category. */
/* Q18. Top-3 most expensive per category. */
/* Q19. Per region, customer with biggest spend. */
/* Q20. Per category, brand with most products. */
/* Q21. Per store, top employee by tickets resolved. */
/* Q22. Per courier, longest shipment. */
/* Q23. Per warehouse, oldest snapshot. */
/* Q24. Per supplier, latest shipment. */
/* Q25. Per agent, top-rated call. */

/* ============================================================
   SECTION B: MULTI-SOURCE SUBQUERIES (25)
   ------------------------------------------------------------ */
/* Q26. Customer 360deg: orders + reviews + tickets + calls + returns + page_views. */
/* Q27. Product 360deg: sold + reviewed + returned + in inventory. */
/* Q28. Store 360deg: employees + orders + revenue + complaints. */
/* Q29. Region 360deg. */
/* Q30. Campaign 360deg. */
/* Q31. Employee 360deg. */
/* Q32. Brand 360deg. */
/* Q33. Supplier 360deg. */
/* Q34. Tier 360deg. */
/* Q35. Agent 360deg. */
/* Q36. Per customer, union of all touchpoints. */
/* Q37. Per product, union of all events. */
/* Q38. Per region, union of all sales channels. */
/* Q39. Per campaign, union of attribution sources. */
/* Q40. Per warehouse, union of inventory changes. */
/* Q41. Per supplier, union of orders shipped. */
/* Q42. Per courier, union of deliveries + failures. */
/* Q43. Per tier, union of upgrades + downgrades. */
/* Q44. Per agent, union of tickets + calls. */
/* Q45. Per page_view, enrich with customer + product. */
/* Q46. Cross-schema EXISTS chain. */
/* Q47. Cross-schema NOT EXISTS for orphan detection. */
/* Q48. Cross-domain JOIN via subqueries. */
/* Q49. Cross-domain aggregation via UNION ALL of subqueries. */
/* Q50. Cross-domain anti-join via EXCEPT. */

/* ============================================================
   SECTION C: SUBQUERY IN DML (25)
   NOTE: RetailMart is READ-ONLY - run these DML statements in your OWN
   accio_NN database, or preview the affected rows with a SELECT first
   (the answer key shows the SELECT preview against RetailMart).
   ------------------------------------------------------------ */
/* Q51. UPDATE orders SET status = 'reviewed' WHERE order_id IN (subquery). */
/* Q52. UPDATE customers SET tier = (the customer's loyalty tier, via subquery). */
/* Q53. DELETE old_orders WHERE order_id IN (subquery). */
/* Q54. INSERT INTO archive SELECT * FROM ... WHERE ... (subquery filter). */
/* Q55. UPDATE products SET stock = (subquery from inventory). */
/* Q56. UPDATE employees SET salary = salary * 1.1 WHERE dept_id IN (subquery). */
/* Q57. DELETE customers.customers WHERE customer_id NOT IN (subquery). */
/* Q58. INSERT INTO audit_log SELECT order_id FROM sales.orders WHERE ... (subquery filter). */
/* Q59. UPDATE tickets SET status = 'closed' WHERE created_date < (subquery date). */
/* Q60. UPDATE ad_campaigns SET active = false WHERE id IN (subquery low spend). */
/* Q61. CREATE TABLE high_value AS SELECT * FROM sales.orders WHERE net_total > (subq). */
/* Q62. ALTER TABLE ADD COLUMN tier_id DEFAULT (subquery)? Show how (immutable required). */
/* Q63. UPSERT customers using a subquery for the new tier. */
/* Q64. MERGE INTO ... USING (subquery) ... */
/* Q65. Bulk INSERT via subquery (INSERT SELECT). */
/* Q66. Subquery-driven UPDATE setting multiple columns. */
/* Q67. Subquery in WITH for CTE-based DML. */
/* Q68. Subquery in RETURNING. */
/* Q69. UPDATE ... FROM (subquery). */
/* Q70. DELETE ... USING (subquery). */
/* Q71. CTE-DML chain: WITH d AS (DELETE ...) INSERT INTO archive SELECT * FROM d. */
/* Q72. UPDATE with subquery to compute new value per row. */
/* Q73. Conditional UPDATE: WHERE (subquery) IS DISTINCT FROM new_value. */
/* Q74. DELETE with subquery and LIMIT (batched). */
/* Q75. INSERT INTO ... SELECT from JOIN of multiple subqueries. */

/* ============================================================
   SECTION D: REAL REPORTS (25)
   ------------------------------------------------------------ */
/* Q76. "Above average" report per region. */
/* Q77. "Below median" report per category. */
/* Q78. "Top quartile" customers. */
/* Q79. "Bottom quartile" products. */
/* Q80. "Outlier orders" via z-score. */
/* Q81. "Cohort retention" via subquery on signup month. */
/* Q82. "Churn analysis" with subquery on last activity. */
/* Q83. "Win-back targets" - lapsed customers. */
/* Q84. "Tier movers" - upgraded recently. */
/* Q85. "Loyalty new members". */
/* Q86. "Inventory at risk" - subquery on velocity vs stock. */
/* Q87. "Stockout candidates" - qty < forecast. */
/* Q88. "Supplier scorecard" - multi-metric subqueries. */
/* Q89. "Courier scorecard". */
/* Q90. "Campaign ROI". */
/* Q91. "Brand performance vs peers". */
/* Q92. "Top 10% products by revenue". */
/* Q93. "Bottom 10% products by sales velocity". */
/* Q94. "VIP customers" - multi-criteria. */
/* Q95. "Fraud watchlist" - subquery on velocity + amount. */
/* Q96. "SLA breach" - subquery on response time. */
/* Q97. "Stuck tickets" - open for > p95 time. */
/* Q98. "Reactivation candidates" - last_order in 60-180 days. */
/* Q99. "Refund risk" - subquery on customer return rate. */
/* Q100. "Executive 1-pager" - 50 metrics from subqueries in one row. */

/* ============================================================
   END OF Subqueries Part 1 - CRAZY LEVEL (100 QUESTIONS)
============================================================ */
