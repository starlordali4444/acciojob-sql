/* ============================================================
   SQL PRACTICE SET - Subqueries Part 1 (HARD LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Subqueries - performance, rewrite, anti-patterns
   Database:     RetailMart V3

   Scope (HARD):
     - Rewrite slow subqueries as JOINs
     - Detect N+1 patterns
     - Planner forensics for subqueries
     - Anti-pattern catalog
     - Semi-join vs anti-join planner decisions
     - Subquery + index interaction

   Structure: 25 Rewrites + 25 Performance + 25 Anti-patterns + 25 Real-world
   ============================================================ */

/* ============================================================
   SECTION A: SUBQUERY REWRITES (25)
   ------------------------------------------------------------ */
/* Q1.  Rewrite IN-subquery as JOIN. */
/* Q2.  Rewrite NOT IN as NOT EXISTS (NULL-safe). */
/* Q3.  Rewrite correlated subquery as LEFT JOIN. */
/* Q4.  Rewrite scalar subquery in SELECT as LEFT JOIN. */
/* Q5.  Rewrite EXISTS as INNER JOIN + DISTINCT. */
/* Q6.  Rewrite multiple scalar subqueries as a single CTE. */
/* Q7.  Rewrite "(SELECT MAX...)" as window function. */
/* Q8.  Rewrite "WHERE x = (subquery)" with DISTINCT ON. */
/* Q9.  Rewrite "WHERE x IN (top-N)" as LATERAL. */
/* Q10. Rewrite HAVING subquery to a WHERE on aggregated CTE. */
/* Q11. Rewrite multi-level nested subquery as flat CTE chain. */
/* Q12. Rewrite "for each row, count related" via window. */
/* Q13. Rewrite correlated MAX subquery as window. */
/* Q14. Rewrite "find rows with same key" via window. */
/* Q15. Rewrite "find latest per group" via DISTINCT ON or ROW_NUMBER. */
/* Q16. Rewrite EXISTS subquery as LEFT JOIN ... IS NOT NULL. */
/* Q17. Rewrite NOT EXISTS as LEFT JOIN ... IS NULL. */
/* Q18. Rewrite OR-subquery as UNION ALL. */
/* Q19. Rewrite AND-of-subqueries as INNER JOIN chain. */
/* Q20. Rewrite "Top-N per group" subquery as LATERAL. */
/* Q21. Rewrite "find duplicates" subquery as window count. */
/* Q22. Rewrite "find gaps" subquery as window LAG. */
/* Q23. Rewrite "find islands" subquery as window. */
/* Q24. Rewrite "find runs" subquery as gaps-and-islands. */
/* Q25. Rewrite percent-of-total subquery using window. */

/* ============================================================
   SECTION B: PERFORMANCE FORENSICS (25)
   ------------------------------------------------------------ */
/* Q26. EXPLAIN ANALYZE a correlated subquery. */
/* Q27. EXPLAIN ANALYZE the same query rewritten as JOIN - compare. */
/* Q28. EXPLAIN IN-subquery vs JOIN - same plan? */
/* Q29. EXPLAIN scalar subquery in SELECT - see the per-row subplan. */
/* Q30. Identify "SubPlan" node in EXPLAIN. */
/* Q31. Identify "InitPlan" node (uncorrelated subquery). */
/* Q32. Identify "Hash Semi Join" for IN-subquery. */
/* Q33. Identify "Hash Anti Join" for NOT EXISTS. */
/* Q34. Add index to speed up correlated subquery. */
/* Q35. Add composite index for two-column correlated subquery. */
/* Q36. Add expression index for subquery filter. */
/* Q37. Pre-aggregate via CTE to reduce subquery cost. */
/* Q38. Materialize CTE explicitly to control plan. */
/* Q39. Use LATERAL to replace expensive correlated subquery. */
/* Q40. Use WINDOW to replace expensive subquery in SELECT. */
/* Q41. Use SET enable_nestloop = off to see hash-based plan. */
/* Q42. Compare plan with and without random_page_cost tuning. */
/* Q43. Tune work_mem to keep hash in memory. */
/* Q44. Diagnose "subquery returns more than one row" error. */
/* Q45. Add LIMIT 1 + ORDER BY for safe scalar subquery. */
/* Q46. Diagnose "subquery used in expression must return single column" error. */
/* Q47. Diagnose "subquery in FROM must have an alias" error. */
/* Q48. Write an IN-subquery query pattern (in prod, pg_stat_statements finds the slow ones). */
/* Q49. Track "N+1" via repeated subqueries from app logs. */
/* Q50. Audit slow queries with subqueries - top 10. */

/* ============================================================
   SECTION C: ANTI-PATTERN CATALOG (25)
   ------------------------------------------------------------ */
/* Q51. ANTIPATTERN: NOT IN with nullable subquery. */
/* Q52. ANTIPATTERN: scalar subquery in SELECT for every row of huge table. */
/* Q53. ANTIPATTERN: correlated subquery instead of JOIN. */
/* Q54. ANTIPATTERN: SELECT (subquery) in app loop (N+1). */
/* Q55. ANTIPATTERN: subquery in WHERE without index. */
/* Q56. ANTIPATTERN: ORDER BY (subquery) - re-evaluated per row. */
/* Q57. ANTIPATTERN: DISTINCT after EXISTS - redundant. */
/* Q58. ANTIPATTERN: EXISTS (SELECT col FROM ...) - col evaluation wasted. */
/* Q59. ANTIPATTERN: IN-subquery with 100k values - slow. */
/* Q60. ANTIPATTERN: WHERE col IN (SELECT col FROM same_table) - likely just need DISTINCT. */
/* Q61. ANTIPATTERN: triple-nested correlated subquery. */
/* Q62. ANTIPATTERN: subquery + ORDER BY without LIMIT - wasted sort. */
/* Q63. ANTIPATTERN: subquery materialized when it should be inlined. */
/* Q64. ANTIPATTERN: NOT EXISTS with FROM cross product. */
/* Q65. ANTIPATTERN: HAVING with full table scan inside. */
/* Q66. ANTIPATTERN: subquery returning entire JSON instead of needed field. */
/* Q67. ANTIPATTERN: hardcoded IN-list when JOIN to table is cleaner. */
/* Q68. ANTIPATTERN: subquery in CASE that fires N times. */
/* Q69. ANTIPATTERN: scalar subquery returning whole row (use composite type). */
/* Q70. ANTIPATTERN: GROUP BY + subquery + window - overcomplicated. */
/* Q71. ANTIPATTERN: subquery using SELECT * (wasted columns). */
/* Q72. ANTIPATTERN: nested derived tables with redundant aliases. */
/* Q73. ANTIPATTERN: WHERE x = ANY(subq) used as anti-join. */
/* Q74. ANTIPATTERN: subquery in DELETE / UPDATE without WHERE. */
/* Q75. ANTIPATTERN: subquery without ORDER BY in LIMIT 1. */

/* ============================================================
   SECTION D: REAL-WORLD PRODUCTION PATTERNS (25)
   ------------------------------------------------------------ */
/* Q76. Build "find duplicate customers by email" - subquery + GROUP BY. */
/* Q77. Build "find orphan order_items" - anti-join. */
/* Q78. Build "find late shipments" - correlated date subquery. */
/* Q79. Build "above-average customers" report. */
/* Q80. Build "below-median orders" report. */
/* Q81. Build "high-LTV customer" segment. */
/* Q82. Build "low-velocity products" report. */
/* Q83. Build "high-priority unresolved tickets" report. */
/* Q84. Build "premium tier upgrade candidates" - multi-criteria subquery. */
/* Q85. Build "stale inventory" report - subquery on snapshot dates. */
/* Q86. Build "churn-risk" report - subquery on last_order. */
/* Q87. Build "high-spending guests" - anti-join on loyalty. */
/* Q88. Build "fraud watchlist" - subquery on velocity + amount. */
/* Q89. Build "agent leaderboard" - subquery on tickets resolved. */
/* Q90. Build "supplier compliance" - anti-join on shipments missed. */
/* Q91. Build "campaign effectiveness" - subquery on attributions. */
/* Q92. Build "warehouse health" - subquery on snapshot age. */
/* Q93. Build "courier reliability" - subquery on late deliveries. */
/* Q94. Build "category trend" - month-over-month subquery. */
/* Q95. Build "brand growth" - subquery comparing periods. */
/* Q96. Build "tier migration" - subquery on prior tier. */
/* Q97. Build "loyalty churn" - anti-join on member activity. */
/* Q98. Build "executive scorecard" - 20 metric subqueries in 1 row. */
/* Q99. Build "data quality" - subquery on NULL counts per table. */
/* Q100. Build "anomaly detection" - subquery on z-score. */

/* ============================================================
   END OF Subqueries Part 1 - HARD LEVEL (100 QUESTIONS)
============================================================ */
