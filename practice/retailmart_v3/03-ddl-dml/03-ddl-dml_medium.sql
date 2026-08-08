/* ============================================================
   SQL PRACTICE SET - DDL & Data Types (MEDIUM LEVEL)
   Curriculum:   RetailMart V3
   Topic:        DDL & Data Types - design tradeoffs and richer CREATEs
   Database:     YOUR practice DB - NOT RetailMart V3

   Scope (deeper than Easy):
     - Composite keys at creation
     - FK-on-CREATE syntax
     - Multi-column ALTER patterns, type migrations
     - Indexed columns, generated columns
     - Design tradeoff scenarios

   Structure: 25 Conceptual + 25 Advanced CREATE + 25 Complex ALTER + 25 Design Exercises
   ============================================================ */

/* ============================================================
   SECTION A: DDL & DATA-TYPE DEEPER CONCEPTUAL (25)
   ------------------------------------------------------------ */
/* Q1.  Compare NUMERIC(10,2), NUMERIC, and FLOAT - when do you pick each? */
/* Q2.  Defend why a 4-byte INT is enough for most SERIAL columns but not for high-volume events. */
/* Q3.  What is a GENERATED COLUMN in PostgreSQL - give a real RetailMart-like use case. */
/* Q4.  Compare CHAR(64) vs VARCHAR(64) vs TEXT for storing a SHA-256 hex hash. Which is best? */
/* Q5.  When does TIMESTAMPTZ matter MORE than TIMESTAMP - give a concrete example. */
/* Q6.  Why is INTERVAL its own type? When have you actually needed it? */
/* Q7.  Compare TEXT[] (array of text) vs a separate child table. Defend each design with one use case. */
/* Q8.  When would you use ENUM in PostgreSQL - and what's the migration tax? */
/* Q9.  Defend the choice of UUID vs SERIAL for a "tracking event" primary key. */
/* Q10. What's the difference between SMALLINT, INT, BIGINT - and how much disk do they each use? */
/* Q11. Why do experienced engineers ALMOST NEVER use FLOAT/REAL columns? */
/* Q12. Compare DOUBLE PRECISION vs NUMERIC(20,4) for a "GPS latitude" column. */
/* Q13. What's the difference between DEFAULT NOW() and DEFAULT CURRENT_TIMESTAMP? */
/* Q14. Why is "ON UPDATE CURRENT_TIMESTAMP" not native to PostgreSQL - what alternative do PG users use? */
/* Q15. Defend the choice to use BOOLEAN vs a 1-character CHAR(1) for a yes/no flag. */
/* Q16. What is BYTEA used for - and when would you NOT store binary in the database? */
/* Q17. Compare TIMESTAMP(3) vs TIMESTAMP - what does the (3) mean? */
/* Q18. A junior types JSONB-everything. Argue when JSONB is OVERKILL vs RIGHT. */
/* Q19. Why is "INET" type useful for storing IP addresses (over VARCHAR)? */
/* Q20. Compare GENERATED ALWAYS AS IDENTITY vs SERIAL - which does modern PostgreSQL prefer and why? */
/* Q21. Why is choosing the SMALLEST appropriate integer type still important even with cheap disk? */
/* Q22. Defend the use of CITEXT for case-insensitive comparisons over LOWER()-everywhere. */
/* Q23. Explain the design tradeoff between storing a calculated field vs computing on-the-fly. */
/* Q24. When designing a new table, what FIVE columns should almost every business table have? */
/* Q25. Compare schema-per-tenant vs row-per-tenant (multi-tenant SaaS) - when do you pick each? */

/* ============================================================
   SECTION B: ADVANCED CREATE TABLE (25)
   ------------------------------------------------------------ */
/* Q26. Create day_03_practice.audit_logs with composite PK (table_name, record_id, changed_at), columns user_id INT, action VARCHAR(20). */
/* Q27. Create day_03_practice.order_items with FK to a (hypothetical) day_03_practice.orders table - on CREATE. */
/* Q28. Create a table with a generated column: full_name = first_name || ' ' || last_name. */
/* Q29. Create a table that uses GENERATED ALWAYS AS IDENTITY for the primary key (instead of SERIAL). */
/* Q30. Create a table with an inline UNIQUE constraint on (email, tenant_id). */
/* Q31. Create a table with three CHECK constraints inline: price > 0, quantity >= 0, name NOT NULL. */
/* Q32. Create a table that uses TEXT[] for a 'tags' column. */
/* Q33. Create a table that uses JSONB for 'metadata' with a CHECK that requires 'source' key (use jsonb_exists). */
/* Q34. Create a table that uses NUMERIC(20,4) for a 'exchange_rate' column. */
/* Q35. Create a table with a DEFAULT NOW() on created_at AND a separate updated_at with DEFAULT NOW(). */
/* Q36. Create a table with a CHECK that validates email contains '@' (regex check). */
/* Q37. Create a table partitioned by RANGE on created_at by month - for events. */
/* Q38. Create a table that has BOTH a SERIAL surrogate PK and a UNIQUE business key (e.g., sku_code). */
/* Q39. Create a self-referencing FK table: categories(category_id PK, parent_category_id INT REFERENCES same table). */
/* Q40. Create a table with a multi-column FK: order_line(order_id INT, line_no INT, product_id INT) -> orders(order_id) AND constraint on (order_id, line_no) being unique. */
/* Q41. Create a junction table for products and tags with composite PK (product_id, tag_id) and both FKs. */
/* Q42. Create a table with column-level COMMENTS using COMMENT ON COLUMN. */
/* Q43. Create a table with a CHECK using BETWEEN and IN combined. */
/* Q44. Create a table that uses INET for an IP address column. */
/* Q45. Create a table using CITEXT for case-insensitive email column (must enable citext extension first). */
/* Q46. Create a table where one column is generated stored: total = quantity * unit_price (STORED). */
/* Q47. Create a table with TWO surrogate keys (one INT SERIAL for legacy, one UUID for new system). */
/* Q48. Create a table with a DEFERRABLE INITIALLY DEFERRED FK (advanced - for chicken-and-egg insert order). */
/* Q49. Create a temporary table using CREATE TEMP TABLE - what's the lifetime? */
/* Q50. Create an UNLOGGED table - when is this appropriate and what do you give up? */

/* ============================================================
   SECTION C: COMPLEX ALTER PATTERNS (25)
   ------------------------------------------------------------ */
/* Q51. Add THREE columns to day_03_practice.products in a single ALTER TABLE statement. */
/* Q52. Drop TWO columns from day_03_practice.products in a single ALTER. */
/* Q53. Add a column with a DEFAULT and NOT NULL in one shot - what's the migration risk? */
/* Q54. Change the data type of products.price from NUMERIC(12,2) to NUMERIC(14,2) USING a cast. */
/* Q55. Migrate an INT column 'status_id' to a VARCHAR 'status' - show the multi-step migration. */
/* Q56. Rename a table AND its index in two statements. */
/* Q57. ALTER TABLE to add a CHECK constraint on existing data - what if some rows violate? */
/* Q58. Add a NOT NULL to a column that has existing NULLs - what's the safe two-step approach? */
/* Q59. Use ALTER TABLE ... ATTACH PARTITION to add a partition to a partitioned table. */
/* Q60. Use ALTER TABLE ... SET TABLESPACE to move a table to a different tablespace. */
/* Q61. Add a UNIQUE constraint to an existing column with duplicate values - what happens? */
/* Q62. Combine ADD COLUMN + ALTER TYPE + SET NOT NULL in one ALTER statement. */
/* Q63. Use ALTER TABLE ... DISABLE TRIGGER to temporarily silence a trigger during bulk load. */
/* Q64. Use ALTER TABLE ... INHERIT to make one table inherit from a parent (legacy partitioning). */
/* Q65. Drop a column that's referenced by a view - what error do you get and how do you resolve? */
/* Q66. Rename a column referenced by an FK constraint - does the FK still work? */
/* Q67. ALTER COLUMN to change a column's collation. */
/* Q68. ALTER COLUMN ... SET STATISTICS to increase planner accuracy on a heavily-queried column. */
/* Q69. ALTER COLUMN ... SET STORAGE EXTENDED - what is column storage and when does it matter? */
/* Q70. Add an INDEX to an existing column via CREATE INDEX (not ALTER TABLE). */
/* Q71. Add a PARTIAL INDEX (WHERE clause-bound) on an active rows only. */
/* Q72. Add a UNIQUE INDEX (not a UNIQUE constraint) - what's the difference? */
/* Q73. Drop an existing index that's no longer used. */
/* Q74. Rename an index. */
/* Q75. Use CREATE INDEX CONCURRENTLY to add an index without locking the table. */

/* ============================================================
   SECTION D: DESIGN EXERCISES (25)
   ------------------------------------------------------------ */
/* Q76. Design a 'feature_flags' table for a SaaS app: feature_name, percent_rollout, active_from. List columns + types + constraints. */
/* Q77. Design a 'user_sessions' table that tracks login activity. List columns + types + indexes. */
/* Q78. Design a 'price_history' table - every time a product's price changes, log a row. */
/* Q79. Design a 'subscription' table for monthly billing - list columns including next_billing_date. */
/* Q80. Design a 'product_categories_tree' table that can store a hierarchy of unlimited depth. */
/* Q81. Design a 'two-factor_auth_codes' table - temporary codes with expiry. */
/* Q82. Design a 'cron_jobs' table that schedules background tasks. */
/* Q83. Design a 'webhook_deliveries' table that tracks attempt/retry/success. */
/* Q84. Design a 'shopping_cart_items' table (cart_id, product_id, qty, price_at_add). */
/* Q85. Design a 'addresses' table that supports MULTIPLE addresses per customer with one default. */
/* Q86. Design a 'coupons' table with code, discount_pct, max_uses, valid_until. */
/* Q87. Design a 'banking_transactions' table with idempotency_key + ACID guarantees. */
/* Q88. Design a 'audit_record_changes' table that logs every UPDATE on a target table. */
/* Q89. Design a 'inventory_movements' table that tracks every stock-in / stock-out event. */
/* Q90. Design a 'kyc_documents' table for storing customer document uploads. */
/* Q91. Design a 'leaderboard' table for a game (user_id, score, season_id). */
/* Q92. Design a 'support_ticket_messages' table - many messages per ticket. */
/* Q93. Design an 'email_outbox' table that the application reads to send emails. */
/* Q94. Design a 'rate_limit_buckets' table for an API rate limiter. */
/* Q95. Design a 'tenants' table for multi-tenant SaaS. */
/* Q96. Design a 'product_variants' table (one product, many variants like size/color). */
/* Q97. Design a 'survey_responses' table where each survey has dynamic questions (JSONB or normalized?). */
/* Q98. Design a 'gdpr_data_requests' table - track delete-my-data requests with status. */
/* Q99. Design a 'ml_predictions' table to store model output: input_id, prediction, confidence, model_version, timestamp. */
/* Q100. Design a 'a_b_experiments' table to track which user got which variant. */

/* ============================================================
   END OF DDL & Data Types - MEDIUM LEVEL (100 QUESTIONS)
============================================================ */
