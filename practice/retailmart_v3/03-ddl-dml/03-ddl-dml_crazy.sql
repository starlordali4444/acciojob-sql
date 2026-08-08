/* ============================================================
   SQL PRACTICE SET - DDL & Data Types (CRAZY LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Schema design at scale
   Database:     YOUR practice DB

   Scope (CRAZY):
     - Sharding-ready table design
     - Multi-level partitioning
     - Schema evolution patterns
     - Type modeling (domains, composites, ENUMs at scale)
     - Index strategy as data grows
     - Read/write splitting at schema level
     - Future-proofing patterns

   Structure: 25 Scale patterns + 25 Multi-level partitioning + 25 Type modeling + 25 Evolution
   ============================================================ */

/* ============================================================
   SECTION A: SHARDING-READY DESIGN (25)
   ------------------------------------------------------------ */
/* Q1.  Design sales.orders with a "tenant_id" column for future sharding. */
/* Q2.  Choose between (tenant_id, order_id) PK vs separate UUID order_id. */
/* Q3.  Make every FK include tenant_id (composite). */
/* Q4.  Avoid auto-increment IDs - use ULID or UUID. */
/* Q5.  Design "fanout-resistant" customer table. */
/* Q6.  Co-locate related tables via tenant_id. */
/* Q7.  Reference table pattern for small dim tables. */
/* Q8.  Add a "sharding hint" column (computed). */
/* Q9.  Build a "shard map" lookup. */
/* Q10. Implement Snowflake IDs (time + node + seq). */
/* Q11. Avoid global sequences - use per-shard. */
/* Q12. Design audit log that survives shard moves. */
/* Q13. Tag every row with created_at + last_modified for replication. */
/* Q14. Avoid SELECT MAX(id) - use a sidecar sequences table. */
/* Q15. Use logical replication-ready primary keys. */
/* Q16. Allow "cross-shard reads" via a coordinator view. */
/* Q17. Use partial indexes to keep hot subsets small per shard. */
/* Q18. Design soft-delete pattern that's idempotent across shards. */
/* Q19. Reference data via materialized views replicated to each shard. */
/* Q20. Plan for "shard split" - even ID ranges. */
/* Q21. Plan for "shard merge" - same. */
/* Q22. Build a shard-aware DML wrapper (function). */
/* Q23. Add CHECK constraint matching shard predicate (CHECK tenant_id = ...). */
/* Q24. Tier customers into "small/medium/large" with different table strategies. */
/* Q25. Implement zero-FK design (FK enforced in app, not DB). */

/* ============================================================
   SECTION B: MULTI-LEVEL PARTITIONING (25)
   ------------------------------------------------------------ */
/* Q26. RANGE(year) -> LIST(month) for pay_slips. */
/* Q27. LIST(tenant_id) -> RANGE(order_date) for sales.orders. */
/* Q28. RANGE(quarter) -> HASH(customer_id) for page_views. */
/* Q29. Create all 24 monthly partitions for 2024-2025 via DO loop. */
/* Q30. Add daily partitions for the current quarter. */
/* Q31. Drop oldest year's partitions. */
/* Q32. ATTACH a foreign table as a partition (S3 cold storage). */
/* Q33. Mix logged + unlogged partitions for hot vs cold. */
/* Q34. Convert flat table to partitioned (PG12+ ALTER TABLE ... DETACH/ATTACH). */
/* Q35. Verify partition pruning with EXPLAIN. */
/* Q36. Use generated column as partition key. */
/* Q37. Use expression partitioning (PARTITION BY RANGE (date_trunc('day', ts))). */
/* Q38. Partition by tenant_id LIST. */
/* Q39. Partition tickets by priority LIST. */
/* Q40. HASH-partitioned big table (16 partitions) for parallel scan. */
/* Q41. Build per-partition indexes. */
/* Q42. Add a "global" UNIQUE constraint when possible. */
/* Q43. Add per-partition CHECK constraints matching range. */
/* Q44. Add a default partition + monitor its size. */
/* Q45. Implement "rolling window" auto-create + auto-drop. */
/* Q46. Sub-partition page_views by device_type. */
/* Q47. Use partition-wise JOIN. */
/* Q48. Test partition-wise aggregation. */
/* Q49. Partition INHERITANCE for legacy tables (rare). */
/* Q50. Detach partition + run pg_dump on it. */

/* ============================================================
   SECTION C: TYPE MODELING AT SCALE (25)
   ------------------------------------------------------------ */
/* Q51. Domain for non-negative numeric. */
/* Q52. Domain for email + regex. */
/* Q53. Domain for phone (E.164). */
/* Q54. Domain for currency (3-letter ISO). */
/* Q55. Composite type for address (street/city/zip/country). */
/* Q56. Composite type for money (amount + currency). */
/* Q57. ENUM for tier - and the cost of adding values. */
/* Q58. ENUM for ticket priority. */
/* Q59. Range type for stock_level. */
/* Q60. Range type for valid_from/valid_to. */
/* Q61. JSONB column with CHECK for shape. */
/* Q62. Use ARRAY type for tags. */
/* Q63. Use ARRAY type with UNNEST in queries. */
/* Q64. Use HSTORE for sparse attributes (vs JSONB). */
/* Q65. Use UUID v4 vs v7 (time-ordered) for primary keys. */
/* Q66. Generated columns for full_name. */
/* Q67. Generated columns for lower(email). */
/* Q68. Generated columns indexed. */
/* Q69. Use citext for case-insensitive email. */
/* Q70. Use tsvector for searchable description. */
/* Q71. Domain for percent (0..100). */
/* Q72. Domain for slug (URL-safe). */
/* Q73. Composite type for delivery coords (lat/long). */
/* Q74. PostGIS geometry types (intro). */
/* Q75. Build a "rich" customer table using 6+ custom types. */

/* ============================================================
   SECTION D: SCHEMA EVOLUTION (25)
   ------------------------------------------------------------ */
/* Q76. Add column with default - pre-PG11 vs PG11+ behavior. */
/* Q77. Drop column on huge table without lock. */
/* Q78. Rename column without breaking app. */
/* Q79. Change column type from INT to BIGINT (online). */
/* Q80. Change column from TEXT to JSONB (online). */
/* Q81. ADD NOT NULL on existing column safely. */
/* Q82. ADD FK on huge table - NOT VALID then VALIDATE. */
/* Q83. ADD UNIQUE on huge table - CREATE INDEX CONCURRENTLY first. */
/* Q84. Split a column into two. */
/* Q85. Merge two columns into one. */
/* Q86. Rename a table (atomic swap with view). */
/* Q87. Move a table to a different schema. */
/* Q88. Move a table to a different tablespace. */
/* Q89. Convert HEAP to UNLOGGED safely. */
/* Q90. Add a generated column to existing huge table. */
/* Q91. Rebuild a primary key online (pg_repack). */
/* Q92. Add a composite index online. */
/* Q93. Replace an index with a more selective one. */
/* Q94. Migrate a partitioned table to a different partition strategy. */
/* Q95. Versioning a table schema via dual-table writes during migration. */
/* Q96. Implement schema migrations as idempotent SQL files. */
/* Q97. Add a CHECK constraint NOT VALID then VALIDATE. */
/* Q98. Convert a single-tenant table to multi-tenant by adding tenant_id. */
/* Q99. Build "shadow table + trigger" pattern for zero-downtime migration. */
/* Q100. Document a 10-step zero-downtime migration plan (any non-trivial change). */

/* ============================================================
   END OF DDL & Data Types - CRAZY LEVEL (100 QUESTIONS)
============================================================ */
