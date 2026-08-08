/* ============================================================
   SQL PRACTICE SET - Installation & RetailMart Onboarding (HARD LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Setup, Catalogs & Schema Introspection - deeper
   Database:     RetailMart V3

   Scope (HARD = real DBA-style introspection):
     - pg_catalog vs information_schema crossovers
     - Index/constraint/dependency walking
     - Detecting bloat, dead tuples, unused indexes
     - Storage size, TOAST, partition introspection
     - Privilege & ownership audits
     - Sequence/identity introspection
     - Catalog-driven documentation queries

   Structure: 25 Catalog conceptual + 25 Schema audit + 25 Storage/size + 25 Diagnostic queries
   ============================================================ */

/* ============================================================
   SECTION A: CATALOG INTROSPECTION DEEP-DIVE (25)
   ------------------------------------------------------------ */
/* Q1.  What's the difference between pg_class.relkind values 'r', 'i', 'S', 'v', 'm', 'p', 't', 'f'? */
/* Q2.  Explain why pg_class.relnamespace is an OID - and how to resolve it to a schema name. */
/* Q3.  How would you list every table in RetailMart V3 with its schema name (skip system schemas)? */
/* Q4.  Why does pg_attribute.attnum < 0 for system columns? */
/* Q5.  What is pg_index.indkey - and how do you decode a "1 3 2" key list? */
/* Q6.  How do you tell from pg_constraint whether a constraint is PK, FK, UNIQUE, CHECK, or EXCLUSION? */
/* Q7.  Explain pg_depend - what is it used for during DROP CASCADE? */
/* Q8.  Why is pg_proc joined to pg_namespace to find functions in a specific schema? */
/* Q9.  What's stored in pg_type - and how does it model composite/array/range/domain types? */
/* Q10. How would you find all extensions installed and their version (pg_extension)? */
/* Q11. Explain pg_authid vs pg_roles - why are they different views? */
/* Q12. How do you list every sequence in RetailMart V3 with its last_value? */
/* Q13. Walk through how an IDENTITY column appears in pg_attribute (attidentity column). */
/* Q14. Compare information_schema.tables vs pg_class for portability. */
/* Q15. What's in pg_stat_user_tables that pg_stat_all_tables hides? */
/* Q16. How would you find all foreign-key relationships across all RetailMart schemas? */
/* Q17. What does pg_stat_user_indexes.idx_scan = 0 indicate - and how do you act on it? */
/* Q18. Explain pg_locks columns: locktype, mode, granted - what does waiting look like? */
/* Q19. How would you find the longest-running transaction right now (pg_stat_activity)? */
/* Q20. Explain pg_stat_database - what's the cache hit ratio formula? */
/* Q21. What does pg_stat_bgwriter tell you about checkpoint pressure? */
/* Q22. Walk through pg_settings - how do you find which GUC values were set by the user vs default? */
/* Q23. What does pg_tablespace store - and what's the default tablespace OID? */
/* Q24. How would you list all roles and their attributes (CREATEDB, SUPERUSER, etc.)? */
/* Q25. What is pg_publication / pg_subscription - when do you query them? */

/* ============================================================
   SECTION B: SCHEMA AUDIT QUERIES (25)
   ------------------------------------------------------------ */
/* Q26. List every table in RetailMart V3 with row count estimate (pg_class.reltuples). */
/* Q27. List every table with PK column name(s) (join pg_constraint + pg_attribute). */
/* Q28. List every foreign key with source/target tables and columns. */
/* Q29. Find tables WITHOUT a primary key. */
/* Q30. Find every column with a NOT NULL constraint in customers schema. */
/* Q31. List every CHECK constraint in sales schema and its expression text. */
/* Q32. List every UNIQUE constraint (not PK) across all schemas. */
/* Q33. Find tables with > 5 indexes (potential over-indexing). */
/* Q34. List every index along with the columns indexed (use pg_get_indexdef). */
/* Q35. Find duplicate indexes (same columns, same order, on the same table). */
/* Q36. List columns whose data type is TEXT but could be CHAR/VARCHAR with a length limit. */
/* Q37. Find every table with a column named 'id' that is NOT a primary key. */
/* Q38. Find every table that has both 'created_at' and 'updated_at' timestamp columns. */
/* Q39. List every NUMERIC/DECIMAL column with its precision and scale. */
/* Q40. Find columns of type JSON (legacy) vs JSONB - should any be migrated? */
/* Q41. List every column with a DEFAULT value across the products schema. */
/* Q42. List every generated column (GENERATED ALWAYS AS ...) in V3. */
/* Q43. Find tables that have no foreign key references pointing INTO them (isolated tables). */
/* Q44. Find tables referenced by 5+ other tables (highly central tables). */
/* Q45. List every view across V3 with its underlying SELECT (pg_views). */
/* Q46. List every materialized view with its definition + ispopulated flag. */
/* Q47. Find every column in V3 named like '%email%' across all schemas. */
/* Q48. List every trigger across V3 with target table and trigger function. */
/* Q49. List every function in RetailMart V3 with its return type and argument types. */
/* Q50. List every schema in V3 with the count of tables, views, and functions. */

/* ============================================================
   SECTION C: STORAGE, SIZE & PARTITION AUDIT (25)
   ------------------------------------------------------------ */
/* Q51. List every table with its total size (heap + indexes + TOAST) using pg_total_relation_size. */
/* Q52. List every table with heap size, index size, TOAST size separately. */
/* Q53. List the top 10 largest tables in RetailMart V3 by total size. */
/* Q54. List the top 10 largest indexes in RetailMart V3. */
/* Q55. Compute the index-to-heap ratio per table and flag ratios > 1.0. */
/* Q56. Find tables with significant n_dead_tup (potential bloat). */
/* Q57. Compare reltuples (catalog estimate) vs actual COUNT(*) for sales.orders - how big is the drift? */
/* Q58. List every table with its last_vacuum, last_autovacuum, last_analyze timestamp. */
/* Q59. Find tables that have NEVER been analyzed (last_analyze IS NULL). */
/* Q60. List every partitioned table in V3 with its partition strategy (LIST/RANGE/HASH). */
/* Q61. List the child partitions of any partitioned table in V3 (pg_inherits + pg_class). */
/* Q62. For each partition, show its partition bound expression (pg_get_expr). */
/* Q63. Compute total size of each partition group (parent + children sum). */
/* Q64. Find every table with a TOAST table (pg_class.reltoastrelid <> 0) and its TOAST size. */
/* Q65. Find columns with EXTENDED storage that might benefit from EXTERNAL (already-compressed content). */
/* Q66. List every tablespace with the count of objects stored in it. */
/* Q67. Find the relation with the highest pg_relation_filenode churn (proxy: many VACUUM FULL runs). */
/* Q68. Compute total V3 database size - sum of all schemas + per-schema breakdown. */
/* Q69. Find every table with FILLFACTOR != 100 (custom storage parameter). */
/* Q70. List every index that is invalid (pg_index.indisvalid = false). */
/* Q71. List every index that is unique (pg_index.indisunique = true) - and confirm count matches PK + UNIQUE constraints. */
/* Q72. Find every duplicate row-count estimate (reltuples) > 1M across V3 - production-scale tables. */
/* Q73. List every sequence in V3 with its last_value and is_cycled. */
/* Q74. Find tables where reltuples is more than 20% off from actual count(*) - stats stale. */
/* Q75. List every relation with an unusual relpersistence (TEMP or UNLOGGED). */

/* ============================================================
   SECTION D: DIAGNOSTIC & HEALTH-CHECK QUERIES (25)
   ------------------------------------------------------------ */
/* Q76. Show cache hit ratio for the entire database (heap_blks_hit / heap_blks_hit + heap_blks_read). */
/* Q77. Show per-table cache hit ratio - rank worst 10 tables. */
/* Q78. Show per-index cache hit ratio - find indexes living entirely on disk. */
/* Q79. List unused indexes (idx_scan = 0 AND not part of unique constraint) - candidates to drop. */
/* Q80. List most-scanned indexes (top 10 by idx_scan). */
/* Q81. List most-accessed tables (top 10 by seq_scan + idx_scan combined). */
/* Q82. List tables with high seq_scan + large size (missing index suspects). */
/* Q83. Show current activity: pid, user, state, query - sorted by query_start (oldest first). */
/* Q84. Show backends in 'idle in transaction' state - and how long they've been idle. */
/* Q85. Show current locks with blocking pid (use pg_blocking_pids). */
/* Q86. Compute index hit rate per index from pg_statio_user_indexes. */
/* Q87. Show TOP 10 queries by total_exec_time from pg_stat_statements. */
/* Q88. Show TOP 10 queries by mean_exec_time from pg_stat_statements. */
/* Q89. Show TOP 10 queries by calls (most frequently executed). */
/* Q90. Show queries that have spilled to disk (temp_blks_read > 0) - work_mem may be too low. */
/* Q91. List all replication slots and their lag (pg_replication_slots). */
/* Q92. Show pg_stat_replication - current state of all connected replicas. */
/* Q93. Compute checkpoint statistics: checkpoints_timed vs checkpoints_req from pg_stat_bgwriter. */
/* Q94. Find the most bloated index by approximate bloat ratio (pgstattuple if installed). */
/* Q95. List databases ranked by size (pg_database_size). */
/* Q96. Find the count of WAL files on disk (pg_ls_waldir if PG10+). */
/* Q97. Show user privileges on schemas (has_schema_privilege checks across roles). */
/* Q98. Find every role that has SUPERUSER and warn (security audit). */
/* Q99. List every table where REFERENCES grant has been issued - and to whom. */
/* Q100. Build a "health summary" single-row query: total tables, total indexes, DB size, cache hit ratio, longest active query duration. */

/* ============================================================
   END OF Installation & RetailMart Onboarding - HARD LEVEL (100 QUESTIONS)
============================================================ */
