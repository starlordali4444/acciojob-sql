/* ============================================================
   SQL PRACTICE SET - Constraints & DML (HARD LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Advanced DML - UPSERT, MERGE, CTE-DML, RETURNING
   Database:     YOUR practice DB

   Scope (HARD = production patterns):
     - INSERT ... ON CONFLICT (UPSERT) deep
     - MERGE (PG15+) - three-way operations
     - Writeable CTEs (DML inside WITH)
     - RETURNING for atomic chain
     - Bulk loads (COPY, INSERT SELECT)
     - Concurrent UPDATE patterns (SELECT FOR UPDATE, SKIP LOCKED)
     - Triggers (BEFORE/AFTER/INSTEAD OF)

   Structure: 25 Conceptual + 25 Upsert/Merge + 25 CTE-DML + RETURNING + 25 Bulk/Concurrency/Triggers
   ============================================================ */

/* ============================================================
   SECTION A: ADVANCED DML - CONCEPTUAL (25)
   ------------------------------------------------------------ */
/* Q1.  What is "UPSERT" - how does INSERT ... ON CONFLICT implement it? */
/* Q2.  Compare ON CONFLICT DO NOTHING vs DO UPDATE - when each? */
/* Q3.  Explain EXCLUDED pseudo-table in ON CONFLICT DO UPDATE. */
/* Q4.  What is MERGE (PG15+) - and what does INSERT/UPDATE/DELETE in one statement enable? */
/* Q5.  Compare MERGE vs INSERT ON CONFLICT - when does MERGE win? */
/* Q6.  What is a writeable CTE - and what's a real RetailMart use case? */
/* Q7.  Why does INSERT ... RETURNING + WITH let you chain a write into another query atomically? */
/* Q8.  Explain the visibility rules of CTE-DML - when does the SECOND CTE see the FIRST's changes? */
/* Q9.  Compare COPY vs INSERT for bulk loading - speed, transactionality. */
/* Q10. What is "WITH (NULL '')" in COPY - and other handy COPY options? */
/* Q11. How does SELECT FOR UPDATE differ from SELECT FOR UPDATE SKIP LOCKED? */
/* Q12. Explain how UPDATE locks work - and why ORDER BY id can prevent deadlocks. */
/* Q13. What is a "queue table pattern" - how does SKIP LOCKED build a parallel-safe queue? */
/* Q14. Walk through how INSERT inside a BEFORE INSERT trigger can recurse infinitely. */
/* Q15. Compare BEFORE INSERT trigger that returns NEW vs that returns NULL. */
/* Q16. What is INSTEAD OF trigger - and what's the only relation type it applies to? */
/* Q17. Explain when AFTER triggers run vs BEFORE triggers. */
/* Q18. Why is STATEMENT-level trigger different from ROW-level - when do you use each? */
/* Q19. What is a transition table (REFERENCING NEW TABLE AS) in a trigger? */
/* Q20. How does ON CONFLICT (key1, key2) WHERE pred - partial UPSERT - work? */
/* Q21. Compare TRUNCATE vs DELETE WHERE 1=1 - performance, transactional behavior. */
/* Q22. What does the RESTART IDENTITY clause of TRUNCATE do? */
/* Q23. Explain why DELETE inside a writeable CTE can return rows for further processing. */
/* Q24. What is a "soft delete" pattern - set deleted_at instead of DELETE - pros/cons. */
/* Q25. Walk through transactional boundaries: when does a DML inside a function actually commit? */

/* ============================================================
   SECTION B: UPSERT, MERGE, ADVANCED CONFLICTS (25)
   ------------------------------------------------------------ */
/* Q26. INSERT ON CONFLICT on customer email - DO UPDATE SET full_name = EXCLUDED.full_name. */
/* Q27. INSERT ON CONFLICT (email) DO NOTHING. */
/* Q28. INSERT ON CONFLICT WHERE deleted_at IS NULL - partial-unique conflict target. */
/* Q29. Build inventory_snapshot upsert by (warehouse_id, product_id, snapshot_date). */
/* Q30. UPSERT loyalty.members points balance - add new points to existing balance. */
/* Q31. UPSERT ad_campaign daily spend - sum into running total. */
/* Q32. UPSERT page_view session - increment view count. */
/* Q33. UPSERT ticket - set last_updated to now() on conflict. */
/* Q34. UPSERT supplier - only update if supplier_status changed (WHERE EXCLUDED.status <> existing.status). */
/* Q35. Build a "counter table" upsert that increments a counter atomically. */
/* Q36. MERGE INTO customers USING staging_customers - INSERT new, UPDATE changed, DELETE removed. */
/* Q37. MERGE INTO products USING price_updates - only WHEN MATCHED THEN UPDATE price. */
/* Q38. MERGE INTO inventory USING delta - UPDATE quantity = quantity + delta. */
/* Q39. MERGE INTO loyalty.members WHEN NOT MATCHED INSERT ELSE UPDATE. */
/* Q40. MERGE INTO sales.orders USING refund_set - UPDATE order_status = 'Refunded' WHEN MATCHED. */
/* Q41. RETURNING * from INSERT - capture the auto-generated id. */
/* Q42. RETURNING cust_id, order_id from a multi-row INSERT. */
/* Q43. RETURNING old.* from UPDATE - show old values vs new. */
/* Q44. WITH inserted AS (INSERT ... RETURNING *) SELECT * FROM inserted. */
/* Q45. WITH deleted AS (DELETE ... RETURNING *) INSERT INTO archive SELECT * FROM deleted. */
/* Q46. UPSERT batch: 100 customers from a staging table in a single INSERT ... ON CONFLICT statement. */
/* Q47. UPSERT with COALESCE: only overwrite NULL fields, keep existing non-NULL. */
/* Q48. Conditional UPSERT: UPDATE only if EXCLUDED.last_seen > existing.last_seen (idempotency). */
/* Q49. INSERT ... ON CONFLICT (email) DO UPDATE SET tier_id = GREATEST(EXCLUDED.tier_id, existing.tier_id). */
/* Q50. MERGE with a DO NOTHING source - show that MERGE can be a no-op. */

/* ============================================================
   SECTION C: WRITEABLE CTE + RETURNING (25)
   ------------------------------------------------------------ */
/* Q51. WITH archived AS (DELETE FROM old_orders RETURNING *) INSERT INTO orders_archive SELECT * FROM archived. */
/* Q52. WITH new_c AS (INSERT INTO customers ... RETURNING customer_id) INSERT INTO loyalty.members SELECT customer_id, 1, 0 FROM new_c. */
/* Q53. WITH up AS (UPDATE inventory SET qty = qty - 1 WHERE ... RETURNING product_id) INSERT INTO audit_log SELECT product_id, now() FROM up. */
/* Q54. Two-step write: WITH ins AS (INSERT ...) UPDATE other SET counter = counter + 1 WHERE id IN (SELECT ... FROM ins). */
/* Q55. CTE-DELETE with RETURNING that joins back to log table. */
/* Q56. WITH split AS (INSERT INTO a ... RETURNING *), split2 AS (INSERT INTO b ...) SELECT 1; - multi-target write. */
/* Q57. Insert order + N order_items in single statement using WITH ... RETURNING. */
/* Q58. Move "old" rows from active to history in one CTE-chained transaction. */
/* Q59. UPDATE customers + RETURNING old_tier, new_tier - log changes to audit. */
/* Q60. DELETE soft-deleted customers (where deleted_at < now() - 90 days) RETURNING to backup. */
/* Q61. WITH stats AS (UPDATE products SET stock = stock - 5 RETURNING product_id, stock) SELECT * FROM stats WHERE stock < 10. */
/* Q62. INSERT ... RETURNING then LATERAL join to compute derived values per inserted row. */
/* Q63. UPSERT + RETURNING to detect whether row was INSERTed or UPDATEd (xmax = 0 trick). */
/* Q64. Bulk DELETE with batching: DELETE LIMIT 1000 in a loop until no more rows. */
/* Q65. Atomic counter increment with RETURNING new_value. */
/* Q66. WITH old AS (SELECT FOR UPDATE ...) UPDATE ... - pattern for serialized writes. */
/* Q67. WITH new AS (INSERT ... RETURNING id) DELETE FROM staging WHERE id IN (SELECT id FROM new). */
/* Q68. Insert into 3 tables (transactionally) using one statement with CTEs. */
/* Q69. Move records from staging to live with deduplication: WITH dedup AS (SELECT DISTINCT ON ...) INSERT INTO live SELECT * FROM dedup. */
/* Q70. UPDATE with self-reference via CTE: WITH ranks AS (SELECT ...) UPDATE t SET rank = ranks.rank FROM ranks WHERE t.id = ranks.id. */
/* Q71. Insert + LOG audit row with NOW() - atomic. */
/* Q72. Implement "move row to archive" with WITH d AS (DELETE ... RETURNING *) INSERT INTO archive. */
/* Q73. Implement "shift IDs" - DELETE+INSERT under one transaction (controversial pattern). */
/* Q74. Implement "batch reassign" - UPDATE 100 customers' tier in single statement. */
/* Q75. Implement "rebuild" pattern: TRUNCATE child; INSERT child FROM parent; - all in one transaction. */

/* ============================================================
   SECTION D: BULK LOAD, CONCURRENCY, TRIGGERS (25)
   ------------------------------------------------------------ */
/* Q76. COPY products_staging FROM '/tmp/products.csv' WITH (FORMAT csv, HEADER true). */
/* Q77. COPY with FREEZE - when can you use it (only on empty table in same transaction). */
/* Q78. INSERT INTO ... SELECT FROM ... LIMIT 10000 - batched migration. */
/* Q79. SELECT ... FOR UPDATE SKIP LOCKED LIMIT 100 - worker grabbing jobs. */
/* Q80. SELECT ... FOR NO KEY UPDATE - when this weaker lock is correct. */
/* Q81. UPDATE ... ORDER BY id - avoid deadlocks across concurrent UPDATEs. */
/* Q82. Detect deadlock: two transactions update rows in opposite order. */
/* Q83. Build a job queue: INSERT job -> worker SELECT FOR UPDATE SKIP LOCKED -> UPDATE status='done'. */
/* Q84. Build a BEFORE INSERT trigger that auto-fills created_at. */
/* Q85. Build an AFTER INSERT trigger that logs to an audit table. */
/* Q86. Build a BEFORE UPDATE trigger that prevents changing immutable columns. */
/* Q87. Build an AFTER DELETE trigger that copies the row to deleted_archive. */
/* Q88. Build an INSTEAD OF INSERT trigger on a view that distributes to underlying tables. */
/* Q89. Build a STATEMENT-level trigger that fires once per INSERT, regardless of row count. */
/* Q90. Use REFERENCING NEW TABLE AS to inspect all inserted rows in a statement trigger. */
/* Q91. Build a trigger that prevents UPDATE of more than 1 row per statement (safety guard). */
/* Q92. Build a trigger that auto-updates updated_at on every UPDATE. */
/* Q93. Build a trigger that recomputes a denormalized total in a parent table. */
/* Q94. Build a constraint trigger (DEFERRABLE) that checks at COMMIT. */
/* Q95. Build a trigger that maintains a materialized count column. */
/* Q96. Bulk load with concurrent inserts: how to safely COPY into a hot table. */
/* Q97. UNLOGGED TABLE for staging - show speed difference vs LOGGED. */
/* Q98. INSERT 1 million rows efficiently: COPY > INSERT-many-values > 1M single-row INSERTs. */
/* Q99. INSERT INTO staging SELECT generate_series - useful for test data. */
/* Q100. Build a complete "ETL stage -> upsert" pattern: COPY staging -> MERGE into target -> DROP staging. */

/* ============================================================
   END OF Constraints & DML - HARD LEVEL (100 QUESTIONS)
============================================================ */
