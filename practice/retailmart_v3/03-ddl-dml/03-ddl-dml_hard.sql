/* ============================================================
   SQL PRACTICE SET - DDL & Data Types (HARD LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Advanced DDL - partitioning, generated cols, constraints
   Database:     YOUR practice DB

   Scope (HARD = real DBA design patterns):
     - Generated columns + expression indexes
     - Partitioned tables (RANGE / LIST / HASH)
     - Inheritance vs partitioning
     - Domains, composite types, ENUM types
     - CHECK constraint patterns (regex, ranges, multi-col)
     - Exclusion constraints (overlap prevention)
     - Foreign keys with ON DELETE / ON UPDATE actions
     - Deferrable constraints

   Structure: 25 Conceptual + 25 Partitioning + 25 Custom types + 25 Constraint patterns
   ============================================================ */

/* ============================================================
   SECTION A: ADVANCED DDL - CONCEPTUAL (25)
   ------------------------------------------------------------ */
/* Q1.  What is a GENERATED ALWAYS AS column - give 3 use cases. */
/* Q2.  Compare STORED vs VIRTUAL generated columns (Postgres only supports one). */
/* Q3.  Why is PARTITION BY RANGE on order_date the standard pattern for time-series? */
/* Q4.  When do you choose PARTITION BY LIST vs RANGE vs HASH? */
/* Q5.  What is "partition pruning" - and why does it require the planner to see the partition key in WHERE? */
/* Q6.  Compare table INHERITANCE (legacy) vs declarative PARTITIONING. */
/* Q7.  What is a DOMAIN type - and when is it cleaner than a CHECK constraint? */
/* Q8.  What is a COMPOSITE type - give a use case (address: street/city/zip). */
/* Q9.  When do you use ENUM types vs a lookup table? */
/* Q10. Why is ENUM hard to extend in production (ADD VALUE limitations)? */
/* Q11. Walk through CHECK with regex (e.g., email format) - and when to NOT do this in DDL. */
/* Q12. What is an EXCLUSION constraint - give a booking-overlap example. */
/* Q13. ON DELETE CASCADE vs ON DELETE SET NULL vs ON DELETE RESTRICT - when each. */
/* Q14. What is a DEFERRABLE constraint - when is INITIALLY DEFERRED useful? */
/* Q15. Why does Postgres require UNIQUE constraints on the partition key for partitioned tables? */
/* Q16. Walk through how attach/detach partition works without downtime. */
/* Q17. What is sub-partitioning - and why do most setups avoid it? */
/* Q18. Compare GENERATED column vs trigger-based computed column - tradeoffs. */
/* Q19. What is a "default partition" - what happens when a row matches no defined partition? */
/* Q20. Why is HASH partitioning bad for time-range queries? */
/* Q21. Explain how foreign keys interact with partitioned parents (PG12+). */
/* Q22. What is "constraint exclusion" (legacy) vs "partition pruning"? */
/* Q23. Walk through schema-only DDL (CREATE TABLE ... LIKE) - what's copied? */
/* Q24. What is CREATE TABLE AS vs CREATE TABLE + INSERT - when does each preserve constraints? */
/* Q25. Explain why ALTER TYPE ... ADD VALUE cannot run in a transaction. */

/* ============================================================
   SECTION B: PARTITIONED TABLES (25)
   ------------------------------------------------------------ */
/* Q26. Create a partitioned table orders_p PARTITION BY RANGE(order_date) with 24 monthly partitions for 2024-2025. */
/* Q27. Create a default partition for any row outside defined ranges. */
/* Q28. Create monthly partitions using a DO loop in PL/pgSQL. */
/* Q29. ATTACH an existing table as a partition of orders_p. */
/* Q30. DETACH a partition - show how data is preserved. */
/* Q31. Create a HASH-partitioned customer_events with 8 partitions on customer_id. */
/* Q32. Create LIST-partitioned regional_orders by region_id (one partition per region). */
/* Q33. INSERT 100 rows into orders_p across multiple months - verify auto-routing. */
/* Q34. Query a single partition directly (FROM ONLY orders_p_2025_03). */
/* Q35. Verify partition pruning with EXPLAIN on WHERE order_date BETWEEN x AND y. */
/* Q36. Add an index on each partition (per-partition indexing). */
/* Q37. Add a global-ish index by creating an index on the parent (PG11+ propagates). */
/* Q38. Drop an old partition cheaply (DROP TABLE orders_p_2024_01). */
/* Q39. Archive a partition by DETACH + COPY out + DROP. */
/* Q40. Use pg_partitions or pg_inherits to list children of orders_p. */
/* Q41. Show how DELETE WHERE order_date < ... can be replaced by DROP PARTITION. */
/* Q42. Create a CHECK constraint that mirrors the partition key for safety. */
/* Q43. Add a NEW monthly partition for next month (CREATE TABLE ... PARTITION OF). */
/* Q44. Show what happens when you INSERT a row with order_date outside any partition (no default). */
/* Q45. Use a default partition + run a job to move rows into proper partitions. */
/* Q46. Verify that UPDATE on a row that crosses partitions works in PG11+ (row moves to right partition). */
/* Q47. Show the storage size per partition (pg_total_relation_size). */
/* Q48. Build a partitioned page_views table HASH(customer_id) with 16 partitions. */
/* Q49. Build a LIST-partitioned tickets table by priority. */
/* Q50. Build a RANGE-partitioned pay_slips table by salary_year + sub-partition by salary_month using LIST. */

/* ============================================================
   SECTION C: CUSTOM TYPES (DOMAINS, ENUMS, COMPOSITES) (25)
   ------------------------------------------------------------ */
/* Q51. Create a DOMAIN positive_money AS numeric(10,2) CHECK (VALUE > 0). */
/* Q52. Create a DOMAIN us_state AS char(2) CHECK (VALUE ~ '^[A-Z]{2}$'). */
/* Q53. Create a DOMAIN email_address AS text CHECK (VALUE ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'). */
/* Q54. Use the email domain in a customers_strict table. */
/* Q55. Create a COMPOSITE TYPE address (street text, city text, state char(2), zip varchar(10)). */
/* Q56. Use the address composite type as a column in a customers_with_addr table. */
/* Q57. Insert a row with address as ROW(...) literal - INSERT INTO customers_with_addr VALUES (..., ROW('123 Main','LA','CA','90001')). */
/* Q58. Access composite fields with (addr).city syntax. */
/* Q59. Create an ENUM order_status AS ENUM ('Placed','Paid','Shipped','Delivered','Cancelled'). */
/* Q60. Use the ENUM in a strict_orders table. */
/* Q61. Add a value to the ENUM with ALTER TYPE ADD VALUE 'Returned'. */
/* Q62. Reorder ENUM with ALTER TYPE ... ADD VALUE 'X' BEFORE 'Y'. */
/* Q63. Compare ENUM column storage vs varchar storage. */
/* Q64. Drop a DOMAIN and discuss why it requires no dependents. */
/* Q65. Build a hierarchy: domain -> composite -> table column. */
/* Q66. Show error message when INSERT violates the DOMAIN check. */
/* Q67. Create RANGE TYPE int4range for stock_levels (low, high). */
/* Q68. Create a CITEXT (case-insensitive text) column for emails. */
/* Q69. Use UUID type with DEFAULT gen_random_uuid() (requires pgcrypto). */
/* Q70. Create a JSONB column with a CHECK that value is an object (jsonb_typeof). */
/* Q71. Build a SERIAL vs BIGSERIAL vs IDENTITY comparison. */
/* Q72. Show how dropping a domain cascades to columns. */
/* Q73. ALTER COLUMN to use a domain instead of base type. */
/* Q74. Build a composite type product_dimensions (length, width, height numerics). */
/* Q75. Add a CHECK on a composite type: ((dim).length > 0 AND (dim).width > 0). */

/* ============================================================
   SECTION D: CONSTRAINT PATTERNS (25)
   ------------------------------------------------------------ */
/* Q76. CHECK (price > 0 AND discount_pct BETWEEN 0 AND 100) on products_strict. */
/* Q77. CHECK that end_date >= start_date in a campaigns_strict table. */
/* Q78. CHECK that email matches regex (in CREATE TABLE, then test insert). */
/* Q79. EXCLUDE USING gist (room WITH =, during WITH &&) - bookings overlap prevention. */
/* Q80. EXCLUDE USING gist on shifts table - no overlapping shifts per employee. */
/* Q81. UNIQUE (customer_id, product_id, review_date) - one review per customer-product-day. */
/* Q82. UNIQUE NULLS NOT DISTINCT (PG15+) - treat multiple NULLs as duplicate. */
/* Q83. CHECK with regex on phone_number column. */
/* Q84. ON DELETE CASCADE chain: customer -> orders -> order_items. */
/* Q85. ON DELETE SET NULL on reviews.customer_id when customer is deleted. */
/* Q86. ON UPDATE CASCADE when product_id changes. */
/* Q87. DEFERRABLE INITIALLY DEFERRED on a circular FK between two tables. */
/* Q88. NOT VALID FK - add a constraint without checking existing data, then VALIDATE later. */
/* Q89. NOT NULL with DEFAULT - show how to add to a huge table without rewrite (PG11+). */
/* Q90. ADD COLUMN with GENERATED ALWAYS expression - used for full_name = first_name || ' ' || last_name. */
/* Q91. ADD COLUMN with STORED GENERATED + index on the generated column. */
/* Q92. CHECK constraint on a partitioned table - must be repeated on each partition. */
/* Q93. PRIMARY KEY must include partition key on partitioned tables - show why. */
/* Q94. FOREIGN KEY pointing to a partitioned table (PG12+) - show declaration. */
/* Q95. SELF-REFERENCING FK (manager_id -> employee_id) - show CASCADE/SET NULL choice. */
/* Q96. MULTI-COLUMN FK matching composite primary key. */
/* Q97. UNIQUE INDEX vs UNIQUE CONSTRAINT - show difference using partial unique. */
/* Q98. Partial unique: UNIQUE(email) WHERE deleted_at IS NULL - soft delete safety. */
/* Q99. CHECK with subquery? Show why it's NOT allowed - and the workaround (trigger). */
/* Q100. Build a "rich" employees table with: identity PK, email domain, FK to dim_department, CHECK age >= 18, CHECK salary > 0, UNIQUE(email), generated full_name, audit timestamps with DEFAULT now(). */

/* ============================================================
   END OF DDL & Data Types - HARD LEVEL (100 QUESTIONS)
============================================================ */
