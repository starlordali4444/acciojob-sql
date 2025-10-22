/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 2 (CRAZY HARD LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Data Types & Table Design — Expert Track
   Day Scope Rules (Strict):
     - Focus ONLY on PostgreSQL data types, casting, table design, column evolution, and catalogs.
     - DO NOT use constraints/keys/defaults (NOT NULL, UNIQUE, CHECK, PK/FK, DEFAULT) — Day 3 topic.
     - Usage:
         • DDL/DML → acciojob.daily
         • SELECT (read-only) → retailmart or system catalogs (information_schema/pg_catalog)
   Question Plan: 25 Conceptual + 35 Advanced Commands + 100 Practical = 160 total
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (25)
   ------------------------------------------------------------ */
/* Q1. Explain how TOAST storage works for large TEXT/JSONB/BYTEA values. */
/* Q2. Describe how varlena headers impact variable-length data types. */
/* Q3. Compare page layout implications of wide vs narrow columns on heap. */
/* Q4. Discuss pros/cons of MONEY vs NUMERIC for financial analytics pipelines. */
/* Q5. What are alignment and padding considerations for fixed-width types? */
/* Q6. How do encodings (UTF-8 vs LATIN1) affect TEXT column storage? */
/* Q7. When would you prefer TIMESTAMPTZ over TIMESTAMP in global apps? */
/* Q8. How does PostgreSQL represent INTERVAL internally (months/days/microseconds)? */
/* Q9. What are the trade-offs of storing semi-structured attributes in JSONB vs columns? */
/* Q10. Explain implicit cast chains and how PostgreSQL resolves ambiguous casts. */
/* Q11. Why are long VARCHAR(n) limits often unnecessary in PostgreSQL? */
/* Q12. How does casting failure behave inside a transaction vs autocommit? */
/* Q13. Why can frequent ALTER TYPE operations be risky on large tables? */
/* Q14. Describe how POINT/INET/UUID types are physically stored. */
/* Q15. What is typmod in PostgreSQL and how does it relate to VARCHAR(n)? */
/* Q16. Explain binary vs textual I/O for BYTEA and implications for client tools. */
/* Q17. How can collation influence equality and ordering of TEXT values? */
/* Q18. Why might ARRAY-of-JSONB be chosen over separate child tables? */
/* Q19. What are the pitfalls of storing dates as TEXT? */
/* Q20. How does NOW() differ from CURRENT_TIMESTAMP semantically? */
/* Q21. Explain composite types vs tables — when and why to avoid composites. */
/* Q22. How does search_path affect type and table name resolution? */
/* Q23. What happens during ALTER TABLE ... TYPE when USING is omitted? */
/* Q24. Why can changing NUMERIC scale lead to rounding vs errors? Provide cases. */
/* Q25. Outline a strategy to evolve a busy production table’s column type with near-zero downtime. */

/* ============================================================
   💻 SECTION B: ADVANCED COMMANDS (35)
   (All in acciojob.daily; no constraints/defaults.)
   ------------------------------------------------------------ */
/* Q26. Ensure schema daily exists; create if missing. */
/* Q27. Create table ch_profiles(uid UUID, name TEXT, joined_at TIMESTAMPTZ, tags TEXT[], meta JSONB). */
/* Q28. Insert 5 rows with generated UUIDs and mixed arrays/JSON. */
/* Q29. Add column bio TEXT to ch_profiles. */
/* Q30. Rename column bio to about. */
/* Q31. Change column name type from TEXT to VARCHAR(120) (demonstrate typmod). */
/* Q32. Change column joined_at type from TIMESTAMPTZ to TIMESTAMP USING CAST. */
/* Q33. Revert joined_at to TIMESTAMPTZ USING time zone conversion. */
/* Q34. Add column prefs JSON (text JSON) and then change it to JSONB USING CAST. */
/* Q35. Drop column prefs. */
/* Q36. Create table ch_blobs(fname TEXT, fdata BYTEA). */
/* Q37. Insert 2 rows using bytea hex literals. */
/* Q38. Alter ch_blobs add column uploaded_at TIMESTAMP. */
/* Q39. Rename table ch_blobs to ch_files. */
/* Q40. Drop ch_files. */
/* Q41. Create table ch_times(ev TEXT, ts TIMESTAMP, tz TIMESTAMPTZ, dur INTERVAL). */
/* Q42. Insert 3 rows with NOW() and '3 hours' intervals. */
/* Q43. Change column ts type to TIMESTAMPTZ USING ts AT TIME ZONE 'UTC'. */
/* Q44. Add column occur_date DATE and populate by casting tz. */
/* Q45. Drop column occur_date. */
/* Q46. Create table ch_geo(city TEXT, loc POINT). */
/* Q47. Insert 3 cities with POINTs. */
/* Q48. Drop ch_geo. */
/* Q49. Show column data types for ch_profiles via information_schema.columns. */
/* Q50. Show all user tables in daily via information_schema.tables. */
/* Q51. Show PostgreSQL version via SELECT version(). */
/* Q52. Show server_encoding, LC_COLLATE, LC_CTYPE via SHOW commands. */
/* Q53. List distinct data types used in acciojob.daily via information_schema. */
/* Q54. Estimate size of acciojob database via pg_database_size(). */
/* Q55. List all columns that are of type JSON/JSONB in daily. */
/* Q56. List all ARRAY-typed columns in daily. */
/* Q57. List all BYTEA-typed columns in daily. */
/* Q58. List all TIMESTAMP/TIMESTAMPTZ columns in daily. */
/* Q59. Count number of tables created today using pg_stat_all_tables (approx). */
/* Q60. Retrieve current schema using current_schema(). */

/* ============================================================
   🧩 SECTION C: PRACTICAL TYPE EVOLUTION & DESIGN CHALLENGES (100)
   (All tasks are multi-step but remain inside Day 2 scope.)
   ------------------------------------------------------------ */
/* Q61. Create table ch_products(code TEXT, name TEXT, attrs JSONB, price NUMERIC(10,2)). */
/* Q62. Insert 10 products with attrs JSONB containing nested keys. */
/* Q63. Add column gallery TEXT[] and insert arrays for 5 products. */
/* Q64. Change price type to NUMERIC(12,4) and update one row with 4 decimals. */
/* Q65. Rename column name to product_name. */
/* Q66. Drop column gallery. */
/* Q67. Create table ch_customers(id UUID, full_name TEXT, phones TEXT[], created TIMESTAMPTZ). */
/* Q68. Insert 8 customers with multiple phone numbers. */
/* Q69. Add column profile JSON; then cast it to JSONB using USING. */
/* Q70. Drop column profile. */
/* Q71. Create table ch_orders(order_ref TEXT, ordered_at TIMESTAMP, amount NUMERIC(10,2)). */
/* Q72. Insert 10 orders with NOW()::timestamp. */
/* Q73. Change ordered_at to TIMESTAMPTZ USING AT TIME ZONE 'UTC'. */
/* Q74. Add column note TEXT then drop it. */
/* Q75. Create table ch_inventory(sku TEXT, qty BIGINT, updated_at TIMESTAMPTZ). */
/* Q76. Insert 6 inventory rows. */
/* Q77. Change qty type to NUMERIC(12,0) USING CAST; verify with SELECT. */
/* Q78. Create table ch_sessions(session_id UUID, start_ts TIMESTAMPTZ, duration INTERVAL). */
/* Q79. Insert 5 sessions. */
/* Q80. Change duration to INTERVAL MINUTE precision (conceptual via documentation). */
/* Q81. Create table ch_media(name TEXT, data BYTEA). */
/* Q82. Insert 2 rows with bytea literals. */
/* Q83. Add column kind TEXT then drop it. */
/* Q84. Drop ch_media. */
/* Q85. Create table ch_shipments(ref TEXT, shipped_on DATE, eta TIMESTAMP). */
/* Q86. Insert 5 shipments with DATE + TIMESTAMP combo. */
/* Q87. Change shipped_on to TIMESTAMPTZ USING shipped_on::timestamp AT TIME ZONE 'Asia/Kolkata'. */
/* Q88. Create table ch_catalog(uid UUID, title TEXT, attributes JSONB). */
/* Q89. Insert 5 rows with attributes containing arrays inside JSONB. */
/* Q90. Create table ch_colors(name TEXT, rgb INT[]). */
/* Q91. Insert 5 colors including {0,128,255}. */
/* Q92. Create table ch_points(label TEXT, path POINT[]). */
/* Q93. Insert 3 polyline-like arrays of POINTs. */
/* Q94. Create table ch_pairs(a TEXT, b TEXT). */
/* Q95. Change column a type to VARCHAR(30) and b to TEXT. */
/* Q96. Create table ch_exchange(ccy TEXT, rate NUMERIC(10,6), asof TIMESTAMPTZ). */
/* Q97. Insert 6 currency rows, then widen rate to NUMERIC(14,6). */
/* Q98. Create table ch_logs(id TEXT, message TEXT, created TIMESTAMPTZ). */
/* Q99. Insert 10 logs with NOW(). */
/* Q100. Change message type to VARCHAR(500). */
/* Q101. Create table ch_variants(code TEXT, spec JSONB). */
/* Q102. Insert 5 variants with nested JSONB structures. */
/* Q103. Create table ch_urls(site TEXT, url TEXT). */
/* Q104. Insert 5 sites and URLs. */
/* Q105. Create table ch_files2(fname TEXT, f BYTEA). */
/* Q106. Insert one file literal; then drop the table. */
/* Q107. Create table ch_tztests(label TEXT, ts TIMESTAMP, tz TIMESTAMPTZ). */
/* Q108. Insert 3 rows; later cast ts to TIMESTAMPTZ using AT TIME ZONE 'UTC'. */
/* Q109. Create table ch_arrays(mix TEXT[], nums INT[]). */
/* Q110. Insert 3 rows, then drop column mix. */
/* Q111. Create table ch_readings(sensor TEXT, reading NUMERIC(10,3), read_at TIMESTAMPTZ). */
/* Q112. Insert 6 readings. */
/* Q113. Change reading type to NUMERIC(12,5). */
/* Q114. Create table ch_profiles2(id UUID, name TEXT, extras JSON). */
/* Q115. Alter extras to JSONB using USING. */
/* Q116. Create table ch_choices(label TEXT, flags BOOLEAN[], meta JSONB). */
/* Q117. Insert 3 rows with boolean arrays. */
/* Q118. Create table ch_schedules(task TEXT, start TIMESTAMP, span INTERVAL). */
/* Q119. Insert 5 schedules. */
/* Q120. Create table ch_coords(lat NUMERIC(9,6), lon NUMERIC(9,6)). */
/* Q121. Insert 3 coordinate pairs. */
/* Q122. Create table ch_names(first TEXT, last TEXT). */
/* Q123. Alter first to VARCHAR(40) and last to VARCHAR(40). */
/* Q124. Create table ch_storage(note TEXT, payload BYTEA). */
/* Q125. Insert 2 payloads. */
/* Q126. Create table ch_events(ev TEXT, occured TIMESTAMPTZ, details JSONB). */
/* Q127. Insert 5 events with JSONB. */
/* Q128. Create table ch_iplist(host TEXT, ip INET). */
/* Q129. Insert 3 host/IP pairs. */
/* Q130. Create table ch_calendar(d DATE, t TIME). */
/* Q131. Insert 7 day/time rows. */
/* Q132. Create table ch_prices(item TEXT, amount NUMERIC(10,2)). */
/* Q133. Insert 5 prices then widen to NUMERIC(12,3). */
/* Q134. Create table ch_doc(title TEXT, content TEXT). */
/* Q135. Insert 3 docs; rename content to body. */
/* Q136. Create table ch_arrays2(words TEXT[], flags BOOLEAN[]). */
/* Q137. Insert 3 rows with mixed arrays. */
/* Q138. Create table ch_metrics(metric TEXT, val NUMERIC(12,4), at TIMESTAMPTZ). */
/* Q139. Insert 6 metrics; change val to NUMERIC(14,6). */
/* Q140. Create table ch_json_lines(j JSON). */
/* Q141. Insert 3 JSON lines then cast column j to JSONB. */
/* Q142. Create table ch_phonebook(name TEXT, phones TEXT[]). */
/* Q143. Insert 5 contacts with multiple phones. */
/* Q144. Create table ch_moneybook(label TEXT, amount MONEY). */
/* Q145. Insert 3 rows; then drop ch_moneybook. */
/* Q146. Create table ch_textwide(txt TEXT). */
/* Q147. Insert a very long TEXT value; observe storage (no command). */
/* Q148. Create table ch_versions(app TEXT, ver TEXT). */
/* Q149. Insert 5 version strings. */
/* Q150. Create table ch_paths(path TEXT, is_abs BOOLEAN). */
/* Q151. Insert 4 paths; flip booleans. */
/* Q152. Create table ch_notes(id TEXT, note TEXT, created TIMESTAMPTZ). */
/* Q153. Insert 5 notes. */
/* Q154. Create table ch_pairs2(k TEXT, v TEXT). */
/* Q155. Insert 5 key/value pairs. */
/* Q156. Use information_schema.columns to list all columns in daily schema. */
/* Q157. Use pg_type to list all built-in types referenced by daily tables. */
/* Q158. Use pg_collation to show available collations. */
/* Q159. Use pg_stat_all_tables to approximate relsize trends (conceptual). */
/* Q160. Use pg_database_size() to show acciojob DB size in MB. */

/* ============================================================
   ✅ END OF DAY 2 — CRAZY HARD LEVEL PRACTICE FILE (160 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Expert-level type evolution, casting, and catalog usage — no constraints.
   - Keep all DDL/DML inside acciojob.daily; read retailmart/system catalogs only.
============================================================ */
