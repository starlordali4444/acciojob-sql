/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 2 (EASY LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Data Types & Table Design
   Day Scope Rules:
     - Focus: PostgreSQL data types + table design (CREATE/ALTER/DROP columns & tables).
     - Avoid: Constraints & keys (NOT NULL, UNIQUE, CHECK, PK/FK, DEFAULT) — these are Day 3.
     - Usage:
         • DDL/DML → acciojob.daily
         • SELECT (if any) → retailmart only (read-only)
   Question Plan: 25 Conceptual + 35 Commands + 100 Practical = 160 total
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (25)
   ------------------------------------------------------------ */
/* Q1. What is the difference between CHAR(n), VARCHAR(n), and TEXT in PostgreSQL? */
/* Q2. When would you choose NUMERIC(precision, scale) over FLOAT/DOUBLE PRECISION? */
/* Q3. What is the difference between TIMESTAMP and TIMESTAMPTZ? */
/* Q4. What is the UUID data type used for? */
/* Q5. What is an ARRAY column and when is it useful? */
/* Q6. What is the difference between JSON and JSONB? */
/* Q7. What is the INTERVAL data type used for? */
/* Q8. When should you use DATE vs TIME vs TIMESTAMP? */
/* Q9. What is the purpose of the BOOLEAN data type? */
/* Q10. What is the difference between SMALLINT, INTEGER, and BIGINT? */
/* Q11. What does NUMERIC(10,2) mean? Explain precision and scale. */
/* Q12. What is the INET type used for? (High-level) */
/* Q13. Explain why choosing the correct data type matters for performance and storage. */
/* Q14. What is the MONEY data type and what are its caveats? */
/* Q15. What are ENUM types and when would you define one? (concept only) */
/* Q16. What is a DOMAIN type in PostgreSQL? (concept only) */
/* Q17. What does type casting mean? Give a simple example. */
/* Q18. What happens when you change a column's type with ALTER TABLE ... TYPE? */
/* Q19. Why should you avoid overusing TEXT when VARCHAR(n) suffices? */
/* Q20. What is the default string collation behavior in PostgreSQL (high level)? */
/* Q21. How are time zones handled in TIMESTAMPTZ (high level)? */
/* Q22. What is the difference between a table and a composite type? */
/* Q23. What is the BYTEA type used for? */
/* Q24. What does SERIAL imply, and when would you use it? */
/* Q25. How would you decide between JSONB and relational columns for product attributes? */

/* ============================================================
   💻 SECTION B: BASIC COMMANDS (35)
   (All commands must run on acciojob.daily, avoid constraints/keys/defaults.)
   ------------------------------------------------------------ */
/* Q26. Ensure you are connected to acciojob; switch if needed. */
/* Q27. Create schema daily if it does not exist. */
/* Q28. Create table dt_basics(id SERIAL, name VARCHAR(50), notes TEXT). */
/* Q29. Create table dt_numbers(a_small SMALLINT, a_int INTEGER, a_big BIGINT). */
/* Q30. Create table dt_money(price MONEY). */
/* Q31. Create table dt_decimal(p1 NUMERIC(10,2), p2 NUMERIC(12,4)). */
/* Q32. Create table dt_time(d DATE, t TIME, ts TIMESTAMP, tz TIMESTAMPTZ). */
/* Q33. Create table dt_net(ip INET). */
/* Q34. Create table dt_uuid(uid UUID, label TEXT). */
/* Q35. Create table dt_arrays(tags TEXT[], scores INT[]). */
/* Q36. Create table dt_json(j JSON, jb JSONB). */
/* Q37. Insert one row into dt_decimal with p1=1234.56 and p2=789.1234. */
/* Q38. Insert one row into dt_time with current date/time values. */
/* Q39. Insert one row into dt_uuid using a generated uuid (hint: gen_random_uuid if available). */
/* Q40. Insert one row into dt_arrays with tags={'sql','pg'}, scores={10,20}. */
/* Q41. Insert a JSON object into dt_json: {"a":1,"b":"x"}. */
/* Q42. Select all rows from dt_decimal to verify inserts. */
/* Q43. Add a column remarks TEXT to dt_basics. */
/* Q44. Rename column notes to description in dt_basics. */
/* Q45. Change column name type from VARCHAR(50) to VARCHAR(80) in dt_basics. */
/* Q46. Change column p1 in dt_decimal from NUMERIC(10,2) to NUMERIC(12,2). */
/* Q47. Drop column remarks from dt_basics. */
/* Q48. Drop table dt_money. */
/* Q49. Drop table dt_net. */
/* Q50. Create table dt_casts(txt TEXT, as_int INTEGER, as_date DATE). */
/* Q51. Insert one row into dt_casts with txt values that can be cast to int/date. */
/* Q52. Update dt_casts to fill as_int and as_date using CAST/:: operations. */
/* Q53. Select * from dt_casts to verify casts. */
/* Q54. Create table dt_text_vs_varchar(c1 VARCHAR(5), c2 TEXT). */
/* Q55. Insert sample data into dt_text_vs_varchar. */
/* Q56. Drop table dt_text_vs_varchar. */
/* Q57. List all tables created under acciojob.daily using information_schema.tables. */
/* Q58. Drop table dt_casts. */
/* Q59. Drop table dt_arrays. */
/* Q60. Drop table dt_json. */

/* ============================================================
   🧩 SECTION C: PRACTICAL DDL & DATA TYPE TASKS (100)
   (Design-focused exercises using many Postgres types; keep within Day 2 scope.)
   ------------------------------------------------------------ */
/* Q61. Create table dt_products(prod_code VARCHAR(20), prod_name TEXT, mrp NUMERIC(10,2)). */
/* Q62. Insert 5 sample products into dt_products. */
/* Q63. Create table dt_customers(cust_code VARCHAR(20), cust_name TEXT, phone VARCHAR(15)). */
/* Q64. Insert 5 sample customers. */
/* Q65. Create table dt_orders(order_ref VARCHAR(30), order_date TIMESTAMP, cust_code VARCHAR(20)). */
/* Q66. Insert 5 sample orders with current timestamp. */
/* Q67. Create table dt_reviews(review_ref VARCHAR(20), prod_code VARCHAR(20), rating SMALLINT, review TEXT). */
/* Q68. Insert 5 reviews with ratings 1–5. */
/* Q69. Create table dt_inventory(sku VARCHAR(30), quantity INTEGER, last_update TIMESTAMPTZ). */
/* Q70. Insert 5 inventory records with NOW() for last_update. */
/* Q71. Alter dt_products: add column brand VARCHAR(40). */
/* Q72. Alter dt_products: change mrp from NUMERIC(10,2) to NUMERIC(12,2). */
/* Q73. Alter dt_products: rename prod_name to product_name. */
/* Q74. Alter dt_customers: add column email VARCHAR(80). */
/* Q75. Alter dt_customers: rename phone to mobile. */
/* Q76. Alter dt_orders: add column order_note TEXT. */
/* Q77. Alter dt_reviews: change rating to SMALLINT (if not already). */
/* Q78. Alter dt_inventory: change quantity INTEGER to BIGINT. */
/* Q79. Drop column order_note from dt_orders. */
/* Q80. Drop column brand from dt_products. */
/* Q81. Create table dt_geo(store_code VARCHAR(20), location POINT). */
/* Q82. Insert 3 stores with POINT values. */
/* Q83. Create table dt_files(file_name TEXT, data BYTEA). */
/* Q84. Insert one dummy row into dt_files with bytea literal. */
/* Q85. Create table dt_flags(is_active BOOLEAN, is_archived BOOLEAN). */
/* Q86. Insert 3 rows with different boolean combinations. */
/* Q87. Create table dt_timeshift(base_ts TIMESTAMPTZ, plus_one INTERVAL). */
/* Q88. Insert a row with base_ts=NOW() and plus_one='1 day'. */
/* Q89. Create table dt_contacts(name TEXT, tags TEXT[]). */
/* Q90. Insert 3 rows with array values for tags. */
/* Q91. Create table dt_properties(key TEXT, value JSONB). */
/* Q92. Insert 3 rows with nested JSONB objects. */
/* Q93. Create table dt_routes(route_id TEXT, points POINT[]). */
/* Q94. Insert 2 routes with arrays of points. */
/* Q95. Create table dt_catalog(uid UUID, title TEXT). */
/* Q96. Insert 3 rows with UUIDs. */
/* Q97. Create table dt_prices(item TEXT, amount NUMERIC(8,3)). */
/* Q98. Insert sample rows verifying scale 3. */
/* Q99. Create table dt_lengths(cm INTEGER, m NUMERIC(10,4)). */
/* Q100. Insert 3 rows converting values to meters manually. */
/* Q101. Create table dt_events(ev_code TEXT, occurred_on DATE, occurred_at TIME). */
/* Q102. Insert 3 events with different dates and times. */
/* Q103. Create table dt_birthdays(person TEXT, dob DATE). */
/* Q104. Insert 5 people with DOBs. */
/* Q105. Create table dt_textlimit(code CHAR(5), description VARCHAR(30)). */
/* Q106. Insert rows demonstrating CHAR padding behavior. */
/* Q107. Create table dt_money_demo(label TEXT, price MONEY). */
/* Q108. Insert 3 rows into dt_money_demo. */
/* Q109. Create table dt_cast_demo(x TEXT, y INT, z DATE). */
/* Q110. Insert rows then fill y and z using casts from x. */
/* Q111. Create table dt_json_demo(j JSON, jb JSONB). */
/* Q112. Insert one row with same object in j and jb. */
/* Q113. Create table dt_array_text(words TEXT[]). */
/* Q114. Insert arrays with 2–4 words each. */
/* Q115. Create table dt_phone_numbers(name TEXT, phones TEXT[]). */
/* Q116. Insert 3 contacts with multiple phone numbers. */
/* Q117. Create table dt_url(url TEXT). */
/* Q118. Insert 3 URLs. */
/* Q119. Create table dt_weekly_hours(day_name TEXT, open_time TIME, close_time TIME). */
/* Q120. Insert 7 rows (Mon–Sun). */
/* Q121. Create table dt_color_codes(name TEXT, rgb INT[]). */
/* Q122. Insert 3 colors with rgb arrays like {255,0,0}. */
/* Q123. Create table dt_versions(app TEXT, ver TEXT). */
/* Q124. Insert 3 app/version pairs. */
/* Q125. Create table dt_units(code TEXT, ratio NUMERIC(12,6)). */
/* Q126. Insert rows with 6-decimal precision. */
/* Q127. Create table dt_notes(title TEXT, body TEXT). */
/* Q128. Insert 3 notes. */
/* Q129. Create table dt_prices_history(item TEXT, price NUMERIC(10,2), changed_at TIMESTAMPTZ). */
/* Q130. Insert 5 price change rows. */
/* Q131. Create table dt_locale(locale TEXT, tz TEXT). */
/* Q132. Insert 3 locales/timezones as TEXT. */
/* Q133. Create table dt_binary_flags(flags BYTEA). */
/* Q134. Insert one dummy bytea value. */
/* Q135. Create table dt_emojis(label TEXT, symbol TEXT). */
/* Q136. Insert 5 emoji rows. */
/* Q137. Create table dt_docs(title TEXT, content TEXT). */
/* Q138. Insert 3 docs. */
/* Q139. Create table dt_paths(path TEXT, is_absolute BOOLEAN). */
/* Q140. Insert 4 paths with booleans. */
/* Q141. Create table dt_coords(lat NUMERIC(9,6), lon NUMERIC(9,6)). */
/* Q142. Insert 3 coordinate pairs. */
/* Q143. Create table dt_names(first_name VARCHAR(30), last_name VARCHAR(30)). */
/* Q144. Insert 5 names. */
/* Q145. Create table dt_refcodes(code VARCHAR(12), created TIMESTAMPTZ). */
/* Q146. Insert 5 codes with NOW(). */
/* Q147. Create table dt_timezones(zone TEXT). */
/* Q148. Insert 5 popular time zone strings. */
/* Q149. Create table dt_bool_demo(flag BOOLEAN). */
/* Q150. Insert rows with TRUE/FALSE variations. */
/* Q151. Create table dt_dims(width INT, height INT, area BIGINT). */
/* Q152. Insert rows and compute area manually. */
/* Q153. Create table dt_textlens(sample TEXT, len_info TEXT). */
/* Q154. Insert rows with notes about length; (no functions yet). */
/* Q155. Create table dt_order_refs(ref TEXT). */
/* Q156. Insert 10 order refs like 'ORD001'...'ORD010'. */
/* Q157. Create table dt_blob(holder TEXT, payload BYTEA). */
/* Q158. Insert one payload literal. */
/* Q159. Create table dt_misc(a INT, b TEXT, c TIMESTAMP). */
/* Q160. Insert 3 rows covering all columns. */

/* ============================================================
   ✅ END OF DAY 2 — EASY LEVEL PRACTICE FILE (160 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Do not add constraints/keys/defaults on Day 2.
   - Use acciojob.daily for all DDL/DML; use retailmart only for any read-only SELECTs.
   - Write answers directly below each comment.
============================================================ */
