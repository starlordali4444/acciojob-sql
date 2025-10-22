/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 2 (HARD LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Data Types & Table Design (Advanced)
   Day Scope Rules:
     - Focus: Complex use of PostgreSQL data types, table redesigns, and multi-table schemas.
     - Avoid: Constraints, Keys, and Defaults (covered Day 3).
     - Themes: E-commerce, Logistics, HR, and Library Systems.
     - Usage:
         • DDL/DML → acciojob.daily
         • SELECT → retailmart only (read-only)
   Question Plan: 25 Conceptual + 35 Commands + 100 Practical = 160 total
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (25)
   ------------------------------------------------------------ */
/* Q1. How does PostgreSQL handle large NUMERIC precision values internally? */
/* Q2. Explain the difference in storage between CHAR(10) and VARCHAR(10). */
/* Q3. Why might NUMERIC(18,6) be preferred for currency fields in analytics? */
/* Q4. What is the performance difference between TEXT and VARCHAR in indexing? */
/* Q5. Describe internal representation of UUID and why it's optimized for distributed systems. */
/* Q6. What is the maximum precision allowed for NUMERIC in PostgreSQL? */
/* Q7. How does PostgreSQL store TIMESTAMP data types on disk? */
/* Q8. What happens to existing data when you change a column’s type with USING CAST? */
/* Q9. Why can BYTEA be used for images, but not for large file storage? */
/* Q10. What is the advantage of JSONB over JSON for analytical workloads? */
/* Q11. What are the trade-offs of using ARRAY vs. separate normalized tables? */
/* Q12. How are INTERVAL data types represented internally? */
/* Q13. When is it appropriate to use composite types in PostgreSQL? */
/* Q14. What are DOMAIN types, and how do they simplify schema reuse? */
/* Q15. What is the difference between MONEY and NUMERIC for price representation? */
/* Q16. How can table inheritance be leveraged with custom data types? */
/* Q17. What is the difference between logical and physical column ordering? */
/* Q18. How do collation settings affect string comparison operations? */
/* Q19. Why should column types be as narrow as possible for performance? */
/* Q20. What is the overhead of using TIMESTAMPTZ compared to TIMESTAMP? */
/* Q21. Explain why serial types are considered syntactic sugar for sequences. */
/* Q22. What is the difference between CURRENT_DATE, NOW(), and LOCALTIMESTAMP? */
/* Q23. How do you check all built-in data types using system catalogs? */
/* Q24. What are the challenges of migrating tables between databases with different encodings? */
/* Q25. Explain why using NUMERIC for counts is discouraged in large datasets. */

/* ============================================================
   💻 SECTION B: ADVANCED COMMANDS (35)
   ------------------------------------------------------------ */
/* Q26. Create schema daily if not exists. */
/* Q27. Create table hd_products(prod_id UUID, name TEXT, price NUMERIC(10,2), details JSONB). */
/* Q28. Insert 5 product records with generated UUIDs and JSONB details. */
/* Q29. Alter hd_products add column tags TEXT[]. */
/* Q30. Update tags with {'new','featured'} for one product. */
/* Q31. Rename price column to unit_price. */
/* Q32. Drop and recreate hd_products with same structure but include brand TEXT. */
/* Q33. Create table hd_shipments(shipment_id SERIAL, shipped_on TIMESTAMP, region TEXT, distance_km NUMERIC(8,2)). */
/* Q34. Insert 5 shipments with sample distances. */
/* Q35. Alter hd_shipments change distance_km type to NUMERIC(10,3). */
/* Q36. Add column travel_time INTERVAL. */
/* Q37. Update travel_time = '2 hours' for one shipment. */
/* Q38. Drop column region. */
/* Q39. Rename table hd_shipments to hd_delivery. */
/* Q40. Drop hd_delivery. */
/* Q41. Create table hd_employees(emp_code VARCHAR(10), name TEXT, hire_date DATE, resume BYTEA). */
/* Q42. Insert 3 employee records with dummy bytea data. */
/* Q43. Add column email TEXT. */
/* Q44. Rename column email to office_email. */
/* Q45. Drop column resume. */
/* Q46. Drop table hd_employees. */
/* Q47. Create table hd_books(book_id SERIAL, title TEXT, published DATE, metadata JSON). */
/* Q48. Insert 5 books with JSON metadata. */
/* Q49. Drop hd_books. */
/* Q50. Create table hd_branches(branch_id SERIAL, branch_name TEXT, coordinates POINT). */
/* Q51. Insert 3 branches with POINT coordinates. */
/* Q52. Drop hd_branches. */
/* Q53. Create table hd_media(file_id SERIAL, file_name TEXT, file_data BYTEA, uploaded TIMESTAMPTZ). */
/* Q54. Insert 2 sample media records. */
/* Q55. Drop hd_media. */
/* Q56. Retrieve all tables in schema daily using information_schema. */
/* Q57. Retrieve PostgreSQL version. */
/* Q58. Retrieve all numeric columns from information_schema.columns. */
/* Q59. Retrieve database encoding using SHOW server_encoding. */
/* Q60. Retrieve LC_COLLATE and LC_CTYPE using SHOW commands. */

/* ============================================================
   🧩 SECTION C: PRACTICAL MULTI-TABLE & DATA TYPE CHALLENGES (100)
   ------------------------------------------------------------ */
/* Q61. Create table hd_orders(order_no VARCHAR(20), order_date TIMESTAMPTZ, total NUMERIC(12,2)). */
/* Q62. Insert 10 sample orders. */
/* Q63. Create table hd_customers(cust_id UUID, name TEXT, city TEXT, profile JSONB). */
/* Q64. Insert 10 customers with random UUIDs and JSONB profile data. */
/* Q65. Create table hd_inventory(item_code VARCHAR(20), stock_qty BIGINT, restock_date DATE). */
/* Q66. Insert 5 inventory records. */
/* Q67. Create table hd_logs(id SERIAL, log_message TEXT, created_at TIMESTAMPTZ DEFAULT NOW()). */
/* Q68. Insert 5 log entries. */
/* Q69. Create table hd_prices(product TEXT, old_price NUMERIC(10,2), new_price NUMERIC(12,2)). */
/* Q70. Insert 5 sample price changes. */
/* Q71. Create table hd_sessions(session_id UUID, start_ts TIMESTAMPTZ, duration INTERVAL). */
/* Q72. Insert 5 sessions. */
/* Q73. Create table hd_reviews(review_id SERIAL, content TEXT, rating SMALLINT, created TIMESTAMP). */
/* Q74. Insert 5 reviews. */
/* Q75. Alter hd_reviews change rating type to NUMERIC(3,1). */
/* Q76. Add column edited BOOLEAN DEFAULT FALSE. */
/* Q77. Drop column edited. */
/* Q78. Create table hd_products_ext(code TEXT, price MONEY, data JSON). */
/* Q79. Insert 5 records with different currencies (hint: use MONEY). */
/* Q80. Drop hd_products_ext. */
/* Q81. Create table hd_suppliers(supplier_id UUID, company_name TEXT, contact_emails TEXT[]). */
/* Q82. Insert 5 suppliers with multiple contact emails. */
/* Q83. Create table hd_routes(route_code TEXT, stops TEXT[], distance NUMERIC(10,3)). */
/* Q84. Insert 5 routes with arrays of stops. */
/* Q85. Create table hd_vehicles(vehicle_id SERIAL, reg_no TEXT, maintenance JSONB). */
/* Q86. Insert maintenance logs with JSON structure. */
/* Q87. Alter hd_vehicles change maintenance type to TEXT using CAST. */
/* Q88. Drop hd_vehicles. */
/* Q89. Create table hd_projects(proj_code TEXT, team TEXT[], start_date DATE, duration INTERVAL). */
/* Q90. Insert 5 project records. */
/* Q91. Create table hd_colors(name TEXT, rgb INT[]). */
/* Q92. Insert 5 color rows. */
/* Q93. Create table hd_timezone(zone TEXT, offset INTERVAL). */
/* Q94. Insert 5 zones with offsets. */
/* Q95. Create table hd_coordinates(id SERIAL, loc POINT, desc TEXT). */
/* Q96. Insert 5 coordinate rows. */
/* Q97. Create table hd_history(event TEXT, occurred TIMESTAMPTZ, info JSONB). */
/* Q98. Insert 5 event history rows. */
/* Q99. Create table hd_audit(id SERIAL, action TEXT, action_ts TIMESTAMPTZ DEFAULT NOW()). */
/* Q100. Insert 10 audit entries. */
/* Q101. Create table hd_salary(emp_id UUID, base NUMERIC(10,2), bonus NUMERIC(8,2)). */
/* Q102. Insert 5 salary rows. */
/* Q103. Alter hd_salary change base to NUMERIC(12,4). */
/* Q104. Drop hd_salary. */
/* Q105. Create table hd_catalog(uid UUID, title TEXT, attributes JSONB). */
/* Q106. Insert 5 catalog rows with nested JSON attributes. */
/* Q107. Create table hd_currency(code TEXT, rate NUMERIC(10,6)). */
/* Q108. Insert 5 currencies. */
/* Q109. Alter hd_currency change rate type to NUMERIC(12,6). */
/* Q110. Drop hd_currency. */
/* Q111. Create table hd_versions(app TEXT, version TEXT, build_date DATE). */
/* Q112. Insert 5 rows. */
/* Q113. Create table hd_feedback(uid UUID, feedback TEXT, submitted TIMESTAMP DEFAULT NOW()). */
/* Q114. Insert 5 feedback rows. */
/* Q115. Drop hd_feedback. */
/* Q116. Create table hd_binary_demo(id SERIAL, payload BYTEA). */
/* Q117. Insert dummy payloads. */
/* Q118. Drop hd_binary_demo. */
/* Q119. Retrieve first 10 rows from retailmart.products. */
/* Q120. Retrieve column data types from retailmart.products using information_schema. */
/* Q121. Retrieve all tables in acciojob.daily schema using pg_class. */
/* Q122. Retrieve all text-based columns in retailmart using information_schema.columns. */
/* Q123. Retrieve all tables created today using pg_stat_all_tables. */
/* Q124. Retrieve current database using current_database(). */
/* Q125. Retrieve PostgreSQL encoding and locale info using SHOW commands. */
/* Q126. Retrieve 10 rows from retailmart.customers. */
/* Q127. Retrieve 10 rows from retailmart.sales.orders. */
/* Q128. Retrieve column names and types from retailmart.sales.orders. */
/* Q129. Retrieve all numeric data types used in acciojob.daily tables. */
/* Q130. Retrieve all TIMESTAMP columns from acciojob.daily. */
/* Q131. Retrieve all JSON/JSONB columns from acciojob.daily. */
/* Q132. Retrieve first 10 rows from retailmart.products ordered by product_id. */
/* Q133. Retrieve total count of tables in acciojob.daily. */
/* Q134. Retrieve list of UUID columns from pg_type. */
/* Q135. Retrieve size of acciojob database in MB using pg_database_size(). */
/* Q136. Retrieve LC_COLLATE and LC_CTYPE configuration. */
/* Q137. Retrieve current PostgreSQL version. */
/* Q138. Retrieve all tables containing BYTEA columns. */
/* Q139. Retrieve all ARRAY columns in acciojob.daily. */
/* Q140. Retrieve all tables containing NUMERIC columns. */
/* Q141. Retrieve all column names containing the word 'date'. */
/* Q142. Retrieve table count grouped by data type (conceptual only). */
/* Q143. Retrieve names of all custom schemas in acciojob. */
/* Q144. Retrieve count of columns by data type using information_schema. */
/* Q145. Retrieve schema size in MB for daily schema. */
/* Q146. Retrieve all DATE columns in acciojob.daily. */
/* Q147. Retrieve list of unique data types in retailmart.products. */
/* Q148. Retrieve total number of NUMERIC columns in retailmart.products. */
/* Q149. Retrieve LC_COLLATE using SHOW. */
/* Q150. Retrieve LC_CTYPE using SHOW. */
/* Q151. Retrieve database size in bytes using pg_database_size(). */
/* Q152. Retrieve current timestamp using NOW(). */
/* Q153. Retrieve current schema using current_schema(). */
/* Q154. Retrieve PostgreSQL encoding using SHOW server_encoding. */
/* Q155. Retrieve version using SELECT version(). */
/* Q156. Retrieve collation details using pg_collation catalog. */
/* Q157. Retrieve data type info using pg_type. */
/* Q158. Retrieve user-defined types using pg_type. */
/* Q159. Retrieve schema owner details using pg_namespace. */
/* Q160. Retrieve all table creation times using pg_stat_all_tables. */

/* ============================================================
   ✅ END OF DAY 2 — HARD LEVEL PRACTICE FILE (160 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Focus on mastering PostgreSQL data type operations, redesigns, and analysis.
   - Use acciojob.daily schema for DDL/DML; retailmart for read-only exploration.
============================================================ */
