/* ============================================================
   SQL PRACTICE SET - JOINs Part 2 (Advanced) (HARD LEVEL)
   Curriculum:   RetailMart V3
   Topic:        JOINs Part 2 - advanced (SELF/FULL/CROSS/Set ops/LATERAL)
   Database:     RetailMart V3

   Scope (HARD):
     - LATERAL: deep patterns (top-N per group, exploding, JOIN-LATERAL chains)
     - Self-join "previous/next" before window functions
     - Self-join + grouping for hierarchy-style summaries
     - FULL OUTER reconciliation at scale
     - CROSS JOIN + generate_series for grids
     - UNION ALL "stack" patterns for cross-source dashboards
     - Set ops + correlated logic

   Structure: 25 Conceptual + 25 LATERAL deep + 25 SELF-JOIN advanced + 25 Set ops
   ============================================================ */

/* ============================================================
   SECTION A: ADVANCED JOIN PART 2 - CONCEPTUAL (25)
   ------------------------------------------------------------ */
/* Q1.  Walk through how LATERAL is planned: re-evaluated per outer row. */
/* Q2.  Compare LATERAL LIMIT 1 vs DISTINCT ON for "latest per group". */
/* Q3.  When is FULL OUTER JOIN's COALESCE(left.k, right.k) required vs optional? */
/* Q4.  How does CROSS JOIN LATERAL generate_series produce "N rows per outer row" - explosion pattern. */
/* Q5.  Compare self-join with window function performance (preview Day 16). */
/* Q6.  Explain how UNION ALL is a "stack vertically" while JOIN is "merge horizontally". */
/* Q7.  When does INTERSECT use a Hash Aggregate vs Sort + Merge? */
/* Q8.  Why is EXCEPT sometimes a better choice than NOT EXISTS for whole-row diffs? */
/* Q9.  Explain "relational division" - every X who has ALL Ys - give a SQL recipe. */
/* Q10. Why are FULL OUTER JOINs the backbone of reconciliation (find rows missing on either side)? */
/* Q11. Walk through a 4-bucket reconciliation: both / only-left / only-right / neither. */
/* Q12. Compare a multi-condition self-join (a.x=b.x AND a.y<b.y) with a correlated subquery. */
/* Q13. Why does UNION ALL preserve duplicates while UNION removes them - and the cost difference. */
/* Q14. How do you build a "next event per row" with a self-join + NOT EXISTS gap check. */
/* Q15. Why do CROSS JOIN reports use ARRAY_AGG to build grids? */
/* Q16. Compare CROSS JOIN small x small x small vs CROSS JOIN huge x huge - performance cliff. */
/* Q17. Walk through "dense reporting" pattern: CROSS JOIN time x dim LEFT JOIN facts COALESCE 0. */
/* Q18. Why is LATERAL essential for "for each parent, get a subset of children with ORDER BY/LIMIT"? */
/* Q19. When does a SELF JOIN with composite key match patterns (a.x=b.x AND a.y<b.y)? */
/* Q20. Why does UNION drop information vs UNION ALL - and when is that desirable? */
/* Q21. Explain how INTERSECT can replace INNER JOIN + DISTINCT on all columns. */
/* Q22. Compare CROSS JOIN unnest(array) vs unnest in SELECT. */
/* Q23. What is "PIVOT" - how do you simulate it with FILTER + GROUP BY? */
/* Q24. What is "UNPIVOT" - how do you simulate it with UNION ALL? */
/* Q25. Walk through a "session attribution" query that requires LATERAL + set ops. */

/* ============================================================
   SECTION B: LATERAL DEEP (25)
   ------------------------------------------------------------ */
/* Q26. LATERAL: per customer, latest 5 orders. */
/* Q27. LATERAL: per product, latest 3 reviews (with rating). */
/* Q28. LATERAL: per region, top 5 stores by revenue. */
/* Q29. LATERAL: per category, top 3 products by units sold. */
/* Q30. LATERAL: per agent, latest 5 tickets resolved. */
/* Q31. LATERAL: per platform, top 3 campaigns by spend. */
/* Q32. LATERAL: per warehouse, oldest snapshot (product + date). */
/* Q33. LATERAL: per supplier, 3 most-recent shipments. */
/* Q34. LATERAL: per call_reason, longest call. */
/* Q35. LATERAL: per dept, highest-paid employee. */
/* Q36. LATERAL: explode order into installments (generate_series 1..3). */
/* Q37. LATERAL: explode shipment into "shipped -> in-transit -> delivered" steps. */
/* Q38. LATERAL: per customer, derive 12 monthly buckets (generate_series + LATERAL). */
/* Q39. LATERAL: per product, count of distinct buyers. */
/* Q40. LATERAL: per ticket, the same customer's PREVIOUS ticket. */
/* Q41. LATERAL + aggregation: per customer, JSON of all orders. */
/* Q42. LATERAL: per session, the page clicked just before checkout. */
/* Q43. LATERAL chain: per customer, last order -> that order's first item -> that item's product. */
/* Q44. LATERAL with WHERE that references outer row. */
/* Q45. LEFT JOIN LATERAL - keep outer row when subquery is empty. */
/* Q46. LATERAL + LIMIT 0 (no rows) - INNER excludes; LEFT keeps with NULLs. */
/* Q47. LATERAL with EXISTS - short-circuit detect. */
/* Q48. LATERAL with generate_series + interval - date-bucket per parent. */
/* Q49. LATERAL on a materialized view: top 3 products per category. */
/* Q50. LATERAL: per order, its top 3 line items by net_amount. */

/* ============================================================
   SECTION C: SELF-JOIN ADVANCED (25)
   ------------------------------------------------------------ */
/* Q51. Self-join: prev/next order per customer (and gap days). */
/* Q52. Self-join: detect 2+ same-day orders per customer. */
/* Q53. Self-join: "repeat-buyer pattern" - same product, same customer, > 30 days apart. */
/* Q54. Self-join: each ticket to the same customer's NEXT ticket. */
/* Q55. Self-join: inventory "shortage pair" - same product low-stock at two warehouses within 7 days. */
/* Q56. Self-join: customer signup -> first purchase delay (anchor + first event). */
/* Q57. Self-join: same-brand product pairs by price (cheaper vs pricier). */
/* Q58. Self-join: campaign overlap - two campaigns running same dates. */
/* Q59. Self-join: returns following purchases within 7 days. */
/* Q60. Self-join: customers with 2+ open tickets. */
/* Q61. Self-join: employee pairs working at the same store. */
/* Q62. Multi-join: product pairs in the same category. */
/* Q63. Self-join: employees at one store who joined within 30 days of each other. */
/* Q64. Self-join: multiple returns against the same order. */
/* Q65. Set-based: new customers per registration month (cumulative idea). */
/* Q66. Set-based: page-view path length per session. */
/* Q67. Aggregation: warehouses and how many products they track. */
/* Q68. Aggregation: suppliers and their shipment counts. */
/* Q69. Aggregation: headcount per role per store. */
/* Q70. Co-purchase self-join: customers who bought the same products as customer 1. */
/* Q71. Self-join: rank orders by value WITHIN each customer (before window functions). */
/* Q72. Use SELF JOIN to detect duplicate emails. */
/* Q73. Use SELF JOIN to detect ticket subject duplicates. */
/* Q74. Use SELF JOIN to detect inventory mismatches across warehouses. */
/* Q75. Use SELF JOIN to find "twin orders" - same cust, same amount, same day. */

/* ============================================================
   SECTION D: SET OPS + RECONCILIATION (25)
   ------------------------------------------------------------ */
/* Q76. FULL OUTER reconciliation: orders.cust_id vs customers.customer_id. */
/* Q77. FULL OUTER: products in inventory vs products ever sold - find drift. */
/* Q78. UNION ALL stacked: events from orders + tickets + reviews + calls. */
/* Q79. INTERSECT: customers in BOTH high-spend + active-reviewer cohorts. */
/* Q80. EXCEPT: customers who ordered but never reviewed. */
/* Q81. UNION ALL: "customer churn analysis" - combine multiple definitions of churn. */
/* Q82. UNION ALL + grand total (ROLLUP-like). */
/* Q83. INTERSECT: customers with a Delivered order AND a 2025 order. */
/* Q84. EXCEPT ALL: rows in old set but not new (with multiplicity). */
/* Q85. Set-op + CTE: differences between two computed reports. */
/* Q86. Full reconciliation report: 4-bucket layout (both / only-orders / only-reviews / neither). */
/* Q87. Multi-source dashboard: monthly revenue + ad cost in one UNION ALL output. */
/* Q88. UNION ALL + DENSE_RANK (preview Day 16). */
/* Q89. Detect drift: customers with 2025 orders but none in 2024 (EXCEPT). */
/* Q90. Verify overlap: customers present in BOTH orders and payments (INTERSECT). */
/* Q91. Catch unmatched rows: customers who never placed an order (EXCEPT). */
/* Q92. PIVOT customers by tier using FILTER. */
/* Q93. UNPIVOT order item amount columns into rows. */
/* Q94. INTERSECT: customers who ordered from BOTH store 1 and store 2. */
/* Q95. INTERSECT three lifecycle stages. */
/* Q96. EXCEPT to find new-only campaigns vs last month. */
/* Q97. Build a "delta": customers (id <= 100) with no orders. */
/* Q98. Build a "diff": products in inventory but never sold. */
/* Q99. Combine LATERAL + UNION ALL: per customer, top 1 from each of 4 sources. */
/* Q100. Customer 360deg "all interactions" feed: UNION ALL across schemas, ordered by timestamp. */

/* ============================================================
   END OF JOINs Part 2 (Advanced) - HARD LEVEL (100 QUESTIONS)
============================================================ */
