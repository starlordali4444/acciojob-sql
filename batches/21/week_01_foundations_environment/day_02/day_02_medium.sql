/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 2 (MEDIUM LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Data Types & Table Design
   Day Scope Rules:
     - Focus: PostgreSQL Data Types, Type Casting, Table Design, and ALTER operations.
     - Avoid: Constraints/Keys/Defaults (covered on Day 3).
     - Usage:
         • DDL/DML → acciojob.daily
         • SELECT → retailmart only (read-only)
   Question Plan: 25 Conceptual + 35 Commands + 100 Practical = 160 total
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (25)
   ------------------------------------------------------------ */
/* Q1. Why is choosing the correct data type critical for performance? */
/* Q2. What are the trade-offs between TEXT and VARCHAR types? */
/* Q3. How does PostgreSQL store fixed and variable-length character types internally? */
/* Q4. What is the difference between NUMERIC and DECIMAL types in PostgreSQL? */
/* Q5. What is the effect of increasing precision and scale in NUMERIC(15,4)? */
/* Q6. How do TIMESTAMP and TIMESTAMPTZ differ in storage and behavior? */
/* Q7. What data type should you choose for representing money values? Why? */
/* Q8. How is a UUID generated and why is it useful in distributed systems? */
/* Q9. What are the differences between JSON and JSONB? */
/* Q10. What is the purpose of BYTEA type? */
/* Q11. Why might you use an ARRAY column instead of creating another table? */
/* Q12. What are the limitations of using ENUM in PostgreSQL? */
/* Q13. What are DOMAINs and how can they simplify data validation? */
/* Q14. What happens when you alter a column's data type using ALTER TABLE ... TYPE? */
/* Q15. Explain implicit vs explicit type casting. */
/* Q16. What happens if a cast between two types is not supported? */
/* Q17. How can you check all available data types in PostgreSQL? */
/* Q18. How can you change a column’s data type safely without data loss? */
/* Q19. Why should you be careful while using the MONEY type? */
/* Q20. Explain how INTERVAL data type is used with TIMESTAMP. */
/* Q21. What are composite types and why are they rarely used? */
/* Q22. Explain the difference between DATE, TIME, and TIMESTAMP in PostgreSQL. */
/* Q23. What are user-defined types and when are they useful? */
/* Q24. What is the difference between a table definition and a type definition? */
/* Q25. How are large text or byte objects stored internally in PostgreSQL? */

/* ============================================================
   💻 SECTION B: INTERMEDIATE COMMANDS (35)
   ------------------------------------------------------------ */
/* Q26. Create schema daily if it does not exist. */
/* Q27. Create table md_customers(id SERIAL, name VARCHAR(80), join_date DATE). */
/* Q28. Add column city VARCHAR(60) to md_customers. */
/* Q29. Rename column city to customer_city. */
/* Q30. Change name column type from VARCHAR(80) to TEXT. */
/* Q31. Drop column join_date. */
/* Q32. Create table md_prices(id SERIAL, label TEXT, amount NUMERIC(10,2)). */
/* Q33. Insert sample prices into md_prices. */
/* Q34. Add a column discount NUMERIC(5,2). */
/* Q35. Update discount for one product to 5.00. */
/* Q36. Change column amount from NUMERIC(10,2) to NUMERIC(12,4). */
/* Q37. Add column effective_date TIMESTAMP DEFAULT NOW(). */
/* Q38. Drop column discount. */
/* Q39. Drop table md_prices. */
/* Q40. Create table md_json(j JSON, jb JSONB). */
/* Q41. Insert JSON object {"id":1, "name":"Item"} into both columns. */
/* Q42. Retrieve data from md_json. */
/* Q43. Alter table md_json add column info TEXT. */
/* Q44. Drop table md_json. */
/* Q45. Create table md_arrays(scores INT[], tags TEXT[]). */
/* Q46. Insert sample array values using ARRAY[] syntax. */
/* Q47. Add column comments TEXT[]. */
/* Q48. Drop column comments. */
/* Q49. Drop md_arrays. */
/* Q50. Create table md_types(a CHAR(5), b VARCHAR(20), c TEXT). */
/* Q51. Insert few rows showing differences in storage. */
/* Q52. Drop table md_types. */
/* Q53. Create table md_uuid(uid UUID, created_on TIMESTAMPTZ DEFAULT NOW()). */
/* Q54. Insert generated UUIDs (hint: gen_random_uuid()). */
/* Q55. Drop md_uuid. */
/* Q56. Show all tables created in daily schema using information_schema.tables. */
/* Q57. Show PostgreSQL version. */
/* Q58. Retrieve all data types available using pg_type catalog. */
/* Q59. List columns for md_customers using information_schema.columns. */
/* Q60. Drop md_customers. */

/* ============================================================
   🧩 SECTION C: PRACTICAL TABLE DESIGN & TYPE TASKS (100)
   ------------------------------------------------------------ */
/* Q61. Create table md_products(prod_code VARCHAR(20), prod_name TEXT, mrp NUMERIC(10,2), available BOOLEAN). */
/* Q62. Insert 10 products with mixed BOOLEAN values. */
/* Q63. Create table md_orders(order_ref VARCHAR(30), order_date TIMESTAMP, prod_code VARCHAR(20)). */
/* Q64. Insert 10 orders with NOW() timestamps. */
/* Q65. Alter md_orders: add column quantity INTEGER. */
/* Q66. Alter md_orders: add column total NUMERIC(10,2). */
/* Q67. Update total manually by multiplying quantity and sample price. */
/* Q68. Alter md_orders: rename order_ref to order_number. */
/* Q69. Drop column quantity. */
/* Q70. Create table md_inventory(item TEXT, qty BIGINT, updated_at TIMESTAMPTZ DEFAULT NOW()). */
/* Q71. Insert 5 rows with current timestamps. */
/* Q72. Create table md_flags(active BOOLEAN, deleted BOOLEAN). */
/* Q73. Insert rows for each flag combination. */
/* Q74. Create table md_notes(id SERIAL, message TEXT, created_on DATE). */
/* Q75. Insert 3 notes with different created_on dates. */
/* Q76. Create table md_finance(txn_id VARCHAR(15), amount NUMERIC(12,4), mode TEXT). */
/* Q77. Insert 5 transaction records. */
/* Q78. Alter md_finance: change amount to NUMERIC(14,4). */
/* Q79. Add a column txn_time TIMESTAMP DEFAULT NOW(). */
/* Q80. Drop column mode. */
/* Q81. Create table md_json_data(info JSONB). */
/* Q82. Insert 3 rows with nested JSON objects. */
/* Q83. Create table md_geodata(city TEXT, coord POINT). */
/* Q84. Insert 3 cities with POINT coordinates. */
/* Q85. Create table md_filedata(fname TEXT, fdata BYTEA). */
/* Q86. Insert 2 files as bytea literals. */
/* Q87. Create table md_cast_demo(val_txt TEXT, val_num NUMERIC). */
/* Q88. Insert text values convertible to numbers, then update val_num using cast. */
/* Q89. Create table md_currency(amount MONEY, label TEXT). */
/* Q90. Insert 3 records into md_currency. */
/* Q91. Create table md_timestamp_test(ts TIMESTAMP, tz TIMESTAMPTZ). */
/* Q92. Insert NOW() and NOW() AT TIME ZONE 'UTC' values. */
/* Q93. Create table md_version(app TEXT, ver TEXT). */
/* Q94. Insert multiple version strings. */
/* Q95. Create table md_json_merge(id SERIAL, j JSONB, jb JSONB). */
/* Q96. Insert JSON data, then alter jb type to TEXT using USING CAST. */
/* Q97. Create table md_textarrays(items TEXT[]). */
/* Q98. Insert 5 array rows. */
/* Q99. Create table md_dates(event TEXT, event_date DATE). */
/* Q100. Insert 10 events on consecutive dates. */
/* Q101. Create table md_ipinfo(host TEXT, ip INET). */
/* Q102. Insert 3 host/ip pairs. */
/* Q103. Create table md_colormix(name TEXT, rgb INT[]). */
/* Q104. Insert 3 colors like {255,255,0}. */
/* Q105. Create table md_intervals(start_ts TIMESTAMP, dur INTERVAL). */
/* Q106. Insert data showing a 2-day interval. */
/* Q107. Create table md_cast_practice(a TEXT, b INT, c DATE). */
/* Q108. Fill b and c using ::int and ::date casting from a. */
/* Q109. Create table md_prices_change(item TEXT, old_price NUMERIC, new_price NUMERIC). */
/* Q110. Insert sample data and alter new_price type to NUMERIC(12,4). */
/* Q111. Create table md_boolean_demo(flag BOOLEAN DEFAULT TRUE). */
/* Q112. Insert TRUE and FALSE values. */
/* Q113. Create table md_lengths(meters NUMERIC(10,3), feet NUMERIC(10,3)). */
/* Q114. Insert sample conversions manually. */
/* Q115. Create table md_timestamps(ev TEXT, created TIMESTAMPTZ DEFAULT NOW()). */
/* Q116. Insert 5 rows verifying default timestamps. */
/* Q117. Create table md_array_demo(nums INT[], words TEXT[]). */
/* Q118. Insert 3 mixed arrays. */
/* Q119. Create table md_timezones(name TEXT, tz TEXT). */
/* Q120. Insert 5 timezone strings. */
/* Q121. Create table md_colors(label TEXT, rgb TEXT). */
/* Q122. Insert 5 color rows. */
/* Q123. Create table md_logs(id SERIAL, activity TEXT, logged_at TIMESTAMP). */
/* Q124. Insert 5 activity rows with NOW(). */
/* Q125. Create table md_catalog(uid UUID, label TEXT). */
/* Q126. Insert 3 UUID rows. */
/* Q127. Create table md_documents(title TEXT, body TEXT). */
/* Q128. Insert 3 documents. */
/* Q129. Create table md_urls(site TEXT, url TEXT). */
/* Q130. Insert 5 sites. */
/* Q131. Create table md_metrics(metric TEXT, value NUMERIC(10,3)). */
/* Q132. Insert 5 metric rows. */
/* Q133. Create table md_tempdata(a INT, b INT, c TEXT). */
/* Q134. Insert 3 mixed values. */
/* Q135. Alter md_tempdata change column b type from INT to BIGINT. */
/* Q136. Drop md_tempdata. */
/* Q137. Create table md_variants(label TEXT, details JSONB). */
/* Q138. Insert 3 JSONB rows with different object keys. */
/* Q139. Create table md_misc(a TEXT, b TEXT, c NUMERIC(10,2)). */
/* Q140. Insert 5 records. */
/* Q141. Alter md_misc change column c to NUMERIC(12,3). */
/* Q142. Drop md_misc. */
/* Q143. Retrieve all table names under acciojob.daily using information_schema. */
/* Q144. Retrieve PostgreSQL version using SQL. */
/* Q145. Retrieve available data types using pg_type catalog. */
/* Q146. Retrieve 10 rows from retailmart.products. */
/* Q147. Retrieve 10 rows from retailmart.customers. */
/* Q148. Retrieve 10 rows from retailmart.sales.orders. */
/* Q149. Retrieve column names of retailmart.products using information_schema. */
/* Q150. Retrieve all numeric columns from retailmart.products. */
/* Q151. Retrieve first 5 timestamps from retailmart.sales.orders. */
/* Q152. Retrieve database name using current_database(). */
/* Q153. Retrieve current user. */
/* Q154. Retrieve schema names available. */
/* Q155. Retrieve column data types from information_schema.columns. */
/* Q156. Retrieve distinct table names from acciojob.daily. */
/* Q157. Retrieve count of tables created today using pg_class. */
/* Q158. Retrieve PostgreSQL encoding information using SHOW server_encoding. */
/* Q159. Retrieve LC_COLLATE and LC_CTYPE settings. */
/* Q160. Retrieve database size using pg_database_size(). */

/* ============================================================
   ✅ END OF DAY 2 — MEDIUM LEVEL PRACTICE FILE (160 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Still no constraints or keys — focus on data types, conversion, redesign.
   - Use acciojob.daily schema for all DDL/DML.
   - Use retailmart for read-only SELECT tasks.
============================================================ */