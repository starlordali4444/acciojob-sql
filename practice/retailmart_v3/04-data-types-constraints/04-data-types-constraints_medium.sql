/* ============================================================
   SQL PRACTICE SET - Constraints & DML (MEDIUM LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Constraints & DML - deeper patterns
   Database:     YOUR practice DB - NOT RetailMart V3

   Scope:
     - Complex constraint behavior (cascade, deferred, partial UNIQUE)
     - Multi-constraint composite scenarios
     - Bulk DML: INSERT ... SELECT, UPDATE FROM, multi-row patterns
     - Transactions with SAVEPOINT and rollback patterns
     - Upsert (INSERT ... ON CONFLICT), RETURNING clause

   Structure: 25 Conceptual + 25 Advanced Constraints + 25 Bulk DML + 25 Transactional CRUD
   ============================================================ */

/* ============================================================
   SECTION A: CONSTRAINTS & DML DEEPER CONCEPTUAL (25)
   ------------------------------------------------------------ */
/* Q1.  Compare ON DELETE CASCADE vs ON DELETE SET NULL vs ON DELETE RESTRICT - give a real-world example where each is correct. */
/* Q2.  What does "DEFERRABLE INITIALLY DEFERRED" mean on a FK - when do you need it? */
/* Q3.  Difference between a UNIQUE constraint and a UNIQUE INDEX - which is more flexible? */
/* Q4.  What is a PARTIAL UNIQUE index - give a use case from a multi-tenant SaaS. */
/* Q5.  Why can't a CHECK constraint reference ANOTHER table? What do you use instead? */
/* Q6.  Explain how PostgreSQL validates CHECK constraints when you ALTER TABLE ADD CHECK on existing data. */
/* Q7.  What is INSERT ... ON CONFLICT (upsert) - and what TWO patterns does it support? */
/* Q8.  What does the RETURNING clause do - give a use case where it saves a round trip. */
/* Q9.  Compare DELETE vs TRUNCATE vs DROP TABLE - when is each appropriate? */
/* Q10. Why does PostgreSQL allow you to UPDATE multiple tables in one transaction but NOT in one UPDATE statement? */
/* Q11. Explain the "lost update" problem and how SELECT FOR UPDATE solves it. */
/* Q12. Compare optimistic vs pessimistic locking - which is which and when do you use each? */
/* Q13. What is a SAVEPOINT - and when is it more useful than just COMMIT/ROLLBACK? */
/* Q14. Why is INSERT ... SELECT often used in ETL pipelines? */
/* Q15. Compare UPDATE ... SET col = (SELECT ...) (correlated) vs UPDATE ... FROM (joined). Which is generally faster? */
/* Q16. Explain what "tuple visibility" means in PostgreSQL - and why DELETE doesn't actually free disk space. */
/* Q17. Why is VACUUM needed in PostgreSQL - what does it actually do? */
/* Q18. What is autovacuum - and when does it run? */
/* Q19. Compare INSERT INTO ... VALUES (...) vs prepared statements - when does each win? */
/* Q20. What happens if you INSERT 1000 rows in a single INSERT vs 1000 separate INSERT statements (no transaction)? */
/* Q21. Why do experienced engineers wrap bulk DML in transactions even for INSERTs? */
/* Q22. Explain what "phantom reads" are and which isolation level prevents them. */
/* Q23. Compare READ COMMITTED vs SERIALIZABLE isolation levels - which is the PostgreSQL default? */
/* Q24. What is a TRIGGER - give one example of when it's the right tool vs when it's an anti-pattern. */
/* Q25. Why do many teams BAN triggers in production code - even though PostgreSQL supports them? */

/* ============================================================
   SECTION B: ADVANCED CONSTRAINT SCENARIOS (25)
   ------------------------------------------------------------ */
/* Q26. Add a multi-column UNIQUE on day_03_practice.transactions: (from_account, to_account, txn_time) - prevent exact-duplicate transfers at the same moment. */
/* Q27. Add a CHECK on day_03_practice.bank_accounts that balance must be either 0 OR positive when account_type is 'Savings'. */
/* Q28. Add a DEFERRABLE FK between two tables so you can insert children before parents in a single transaction. */
/* Q29. Add a PARTIAL UNIQUE INDEX to day_03_practice.addresses ensuring only ONE is_default = TRUE per customer. */
/* Q30. Add a CHECK to day_03_practice.subscriptions ensuring ends > starts. */
/* Q31. Add a CHECK to day_03_practice.products ensuring discount_percent BETWEEN 0 AND 100. */
/* Q32. Add a CHECK on day_03_practice.employees ensuring joining_date <= CURRENT_DATE (no future-dated joins). */
/* Q33. Add a CHECK on day_03_practice.product_reviews ensuring rating BETWEEN 1 AND 5 AND comment IS NOT NULL when rating <= 2 (force feedback on low ratings). */
/* Q34. Add a CHECK on day_03_practice.feedback ensuring (rating = 5 AND freeform IS NOT NULL) OR rating < 5 (i.e., 5-star reviews must have a comment). */
/* Q35. Add a composite CHECK on day_03_practice.coupons (if you created it from Day 3): valid_until > CURRENT_DATE OR uses_count >= max_uses. */
/* Q36. Add an ON DELETE SET NULL between day_03_practice.employees_with_fk(tier_id) and day_03_practice.tier_master(tier_id). */
/* Q37. Add an ON DELETE CASCADE between day_03_practice.transactions(from_account) and day_03_practice.bank_accounts(account_id) - what's the risk? */
/* Q38. Drop a CHECK constraint by looking it up in pg_constraint first. */
/* Q39. Add a CHECK using a complex expression: ON day_03_practice.products, expensive products (price > 10000) must have a sku_code. */
/* Q40. Add an EXCLUSION constraint on day_03_practice.subscriptions preventing two overlapping date ranges for the same user_id (advanced - needs btree_gist). */
/* Q41. Add a NOT NULL on day_03_practice.customers.created_at with a DEFAULT NOW() in one statement. */
/* Q42. Drop the NOT NULL on day_03_practice.customers.is_active (allow NULL again). */
/* Q43. Set the DEFAULT of day_03_practice.products.in_stock to FALSE - without affecting existing rows. */
/* Q44. Use NOT VALID to add a constraint that only checks new rows, then VALIDATE later. */
/* Q45. Add a UNIQUE constraint on (LOWER(email)) using a unique index expression. */
/* Q46. Create a constraint that ensures email contains '@' - use a CHECK with the regex operator. */
/* Q47. Create a constraint that ensures phone is exactly 10 digits if not NULL (use CHECK with LENGTH). */
/* Q48. Add a CHECK ensuring pincode is a 6-digit number stored as VARCHAR. */
/* Q49. Add a CHECK ensuring discount_percent < tax_rate doesn't lead to negative net (cross-column CHECK). */
/* Q50. List all constraints on day_03_practice.products using pg_constraint. */

/* ============================================================
   SECTION C: BULK DML PATTERNS (25)
   ------------------------------------------------------------ */
/* Q51. INSERT 1000 rows into day_03_practice.notifications using INSERT ... SELECT from generate_series(1, 1000). */
/* Q52. INSERT INTO day_03_practice.archive_orders SELECT * FROM day_03_practice.orders_demo WHERE order_date < '2024-01-01'. */
/* Q53. UPDATE all products in day_03_practice.products that have NULL discount_percent -> SET to 0. */
/* Q54. UPDATE day_03_practice.products SET price = price * 1.10 WHERE brand_id IN (1, 2, 3). */
/* Q55. UPDATE FROM pattern: update day_03_practice.customers SET tier = m.tier_id FROM day_03_practice.tier_master m WHERE m.tier_id = day_03_practice.customers.tier_id. */
/* Q56. DELETE FROM day_03_practice.notifications USING day_03_practice.customers WHERE notifications.user_id = customers.cust_id AND customers.is_active = FALSE. */
/* Q57. INSERT INTO day_03_practice.products (name, price, in_stock) VALUES (...), (...), (...) - 10 rows in one statement. */
/* Q58. Upsert: INSERT INTO day_03_practice.tier_master VALUES (4, 'Diamond', 1000) ON CONFLICT (tier_id) DO UPDATE SET tier_name = EXCLUDED.tier_name. */
/* Q59. Upsert with DO NOTHING: INSERT INTO day_03_practice.customers (email) VALUES ('priya@example.com') ON CONFLICT (email) DO NOTHING. */
/* Q60. Use RETURNING to get the newly inserted customer's auto-generated cust_id. */
/* Q61. INSERT INTO day_03_practice.orders_demo (cust_id, total, order_date) VALUES (1, 5000, CURRENT_DATE) RETURNING order_id. */
/* Q62. UPDATE ... RETURNING: update a customer's phone and return the OLD AND NEW values. */
/* Q63. DELETE ... RETURNING: delete an inactive customer and return the deleted row for an audit log. */
/* Q64. Use INSERT ... SELECT to copy 100 rows from day_03_practice.products to day_03_practice.products_v2. */
/* Q65. UPDATE with CASE: SET day_03_practice.products.status = CASE WHEN price > 1000 THEN 'premium' ELSE 'standard' END. */
/* Q66. UPDATE ... SET multiple columns at once: SET price = price * 1.05, updated_at = NOW(). */
/* Q67. DELETE rows older than 90 days from day_03_practice.notifications. */
/* Q68. DELETE in batches: DELETE FROM ... WHERE id IN (SELECT id FROM ... LIMIT 1000) - repeat. */
/* Q69. INSERT ... SELECT with WHERE: only copy rows that meet a condition. */
/* Q70. INSERT into a partitioned table - PostgreSQL routes to the right partition automatically. */
/* Q71. TRUNCATE multiple tables in one statement: TRUNCATE day_03_practice.notifications, day_03_practice.events_log. */
/* Q72. TRUNCATE with RESTART IDENTITY to reset the SERIAL counter. */
/* Q73. UPDATE with subquery in SET: update each customer's total_spend = (SELECT SUM ... ). */
/* Q74. Use UPDATE FROM with multi-table join. */
/* Q75. DELETE with USING + multi-table join. */

/* ============================================================
   SECTION D: TRANSACTIONAL CRUD PATTERNS (25)
   ------------------------------------------------------------ */
/* Q76. Wrap an UPDATE in a transaction; SELECT to verify; ROLLBACK if wrong. */
/* Q77. Wrap a DELETE in a transaction; SELECT count(*) before COMMIT to verify scope. */
/* Q78. Multi-step transaction: INSERT into orders, INSERT into order_items, COMMIT. If items fail, ROLLBACK leaves orders untouched. */
/* Q79. Use SAVEPOINT inside a transaction: complete step 1, SAVEPOINT s1, attempt step 2, ROLLBACK TO s1 on error. */
/* Q80. Demonstrate how SELECT FOR UPDATE prevents two sessions from updating the same row simultaneously. */
/* Q81. Use a transaction to safely transfer money between two bank_accounts (debit + credit + log = all-or-nothing). */
/* Q82. Wrap a multi-INSERT in a transaction so a single failure rolls everything back. */
/* Q83. Use BEGIN ... ROLLBACK to TEST an UPDATE without committing (sanity check). */
/* Q84. Verify with SELECT before and after an UPDATE inside a transaction. */
/* Q85. Inside a transaction, use SELECT count(*) BEFORE and AFTER a DELETE for verification. */
/* Q86. Demonstrate a transaction that adds a customer, fails on FK violation, ROLLBACKs cleanly. */
/* Q87. Use SET LOCAL inside a transaction (e.g., SET LOCAL statement_timeout = '5s') - what does LOCAL mean? */
/* Q88. Use a deferred FK to insert child rows before parent in one transaction (Q28 setup required). */
/* Q89. Use SELECT FOR UPDATE NOWAIT to fail immediately if the row is locked (don't wait). */
/* Q90. Use SELECT FOR UPDATE SKIP LOCKED - useful for queue-style workers. */
/* Q91. Demonstrate isolation: in session A, BEGIN + UPDATE without commit; in session B, SELECT - what does B see? */
/* Q92. Use a transaction to rename a column safely (multi-step: rename -> verify -> COMMIT, OR ROLLBACK). */
/* Q93. Run a transaction that creates a table, inserts data, then ROLLBACK - verify the table never persists. */
/* Q94. Show that DDL inside a transaction is rolled back in PostgreSQL (unlike some other databases). */
/* Q95. Use SAVEPOINT in a long ETL transaction so a single bad row doesn't kill the whole load. */
/* Q96. Combine INSERT ... ON CONFLICT inside a transaction. */
/* Q97. Use a transaction with two UPDATEs that depend on each other; verify net effect with SELECT after. */
/* Q98. Inside a transaction, DELETE rows + INSERT replacements - atomic data refresh. */
/* Q99. Show how a transaction that's been open for 1 hour can cause bloat (long-running transactions block VACUUM). */
/* Q100. Use BEGIN READ ONLY to start a read-only transaction (helpful for analyst safety). */

/* ============================================================
   END OF Constraints & DML - MEDIUM LEVEL (100 QUESTIONS)
============================================================ */
