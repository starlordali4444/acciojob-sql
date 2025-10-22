/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 1 (CRAZY HARD LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: PostgreSQL Setup & Basics
   Database Context:
     - DDL/DML → acciojob.daily
     - SELECT Queries → retailmart
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (20)
   ------------------------------------------------------------ */
/* Q1. Describe PostgreSQL’s internal process when creating a new database. */
/* Q2. Explain how PostgreSQL manages schemas internally and how namespaces are resolved. */
/* Q3. Differentiate between logical and physical database structures in PostgreSQL. */
/* Q4. Explain how PostgreSQL maintains ACID compliance even in DDL operations. */
/* Q5. What is the pg_catalog schema, and what type of objects are stored there? */
/* Q6. How can you query PostgreSQL system catalogs to inspect all user-created tables? */
/* Q7. What happens to dependent objects when you drop a schema with CASCADE? */
/* Q8. Why does PostgreSQL use separate processes for client connections? */
/* Q9. How does PostgreSQL ensure concurrent access safety without locking the entire table? */
/* Q10. Explain how the autovacuum process affects performance. */
/* Q11. How do OIDs function and why are they deprecated for user tables? */
/* Q12. What metadata views exist for checking active locks? */
/* Q13. Describe the purpose of pg_tables, pg_roles, and pg_user system views. */
/* Q14. How would you recover a database if DROP DATABASE was accidentally executed? */
/* Q15. Explain the difference between TRUNCATE, DELETE, and DROP in terms of transaction logs. */
/* Q16. What is the relationship between a database template and CREATE DATABASE command? */
/* Q17. Why is it important to use schemas instead of multiple databases for modular design? */
/* Q18. What is the process of connecting a new client to PostgreSQL through TCP/IP? */
/* Q19. Explain how to check and modify the search_path for schema resolution. */
/* Q20. How can database ownership be transferred to another user? */

/* ============================================================
   💻 SECTION B: ADVANCED COMMANDS (40)
   ------------------------------------------------------------ */
/* Q21. Create database acciojob if it doesn’t exist. */
/* Q22. Connect to acciojob and verify connection. */
/* Q23. Create schema daily if not exists. */
/* Q24. Create table daily_products(product_id SERIAL PRIMARY KEY, name TEXT, category TEXT, price NUMERIC(10,2), stock INT). */
/* Q25. Insert 10 sample rows into daily_products using a single INSERT statement. */
/* Q26. Create table daily_suppliers(supplier_id SERIAL, supplier_name TEXT, city TEXT). */
/* Q27. Insert 5 suppliers into daily_suppliers. */
/* Q28. Add a column email TEXT to daily_suppliers. */
/* Q29. Update supplier emails using UPDATE command with multiple SET statements. */
/* Q30. Drop and recreate daily_suppliers table with all required columns in one statement. */
/* Q31. Create table daily_customers(customer_id SERIAL, name TEXT, city TEXT, created_on TIMESTAMP DEFAULT NOW()). */
/* Q32. Insert 8 customers with varying cities. */
/* Q33. Create table daily_orders(order_id SERIAL, customer_id INT, product_id INT, order_date DATE DEFAULT CURRENT_DATE). */
/* Q34. Insert 10 orders covering multiple customers and products. */
/* Q35. Rename daily_orders table to daily_transactions. */
/* Q36. Drop column order_date from daily_transactions and re-add it as TIMESTAMP. */
/* Q37. Truncate daily_transactions but keep structure intact. */
/* Q38. Create temporary table temp_backup as SELECT * FROM daily_products. */
/* Q39. Drop temp_backup. */
/* Q40. Create table daily_warehouse(wh_id SERIAL, wh_name TEXT, city TEXT, capacity INT). */
/* Q41. Insert 4 warehouse records. */
/* Q42. Update capacity values by adding 1000 to each existing one. */
/* Q43. Drop daily_warehouse table. */
/* Q44. Create a role crazy_user with CREATEDB and LOGIN privileges. */
/* Q45. Grant CREATE ON DATABASE acciojob to crazy_user. */
/* Q46. Create table daily_audit(id SERIAL, table_name TEXT, action TEXT, log_time TIMESTAMP DEFAULT NOW()). */
/* Q47. Insert 5 log records into daily_audit for CREATE, UPDATE, DELETE actions. */
/* Q48. Retrieve all logs ordered by log_time DESC. */
/* Q49. Drop daily_audit table. */
/* Q50. Retrieve list of all tables across all schemas using information_schema.tables. */
/* Q51. Retrieve all schemas excluding system schemas using pg_namespace. */
/* Q52. Retrieve all active sessions with database name and query text from pg_stat_activity. */
/* Q53. Show all databases with their size in MB using pg_database_size. */
/* Q54. Create table daily_branches(branch_id SERIAL, branch_name TEXT, region TEXT). */
/* Q55. Insert 6 branches from different regions. */
/* Q56. Rename region column to zone in daily_branches. */
/* Q57. Drop and recreate the daily_branches table. */
/* Q58. Show all users and their roles using pg_roles. */
/* Q59. Create table daily_logs(id SERIAL, activity TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP). */
/* Q60. Insert 5 logs using a single multi-row INSERT command. */

/* ============================================================
   🧩 SECTION C: PRACTICAL CHALLENGES (40)
   ------------------------------------------------------------ */
/* Q61. In acciojob database, create schema daily if not exists. */
/* Q62. Create 3 tables: daily_customers, daily_products, and daily_orders with all relevant columns. */
/* Q63. Insert at least 10 records in each table. */
/* Q64. Update all product prices by increasing 10%. */
/* Q65. Add a new column last_updated TIMESTAMP DEFAULT NOW() to daily_products. */
/* Q66. Update last_updated for all rows using NOW(). */
/* Q67. Drop the last_updated column. */
/* Q68. Rename daily_products to daily_inventory. */
/* Q69. Create table daily_shipments(shipment_id SERIAL, product_id INT, shipped_on DATE). */
/* Q70. Insert 5 shipment records. */
/* Q71. Truncate daily_shipments. */
/* Q72. Drop daily_shipments table. */
/* Q73. Create backup table daily_inventory_backup as SELECT * FROM daily_inventory. */
/* Q74. Delete all records from daily_inventory_backup. */
/* Q75. Drop daily_inventory_backup table. */
/* Q76. Retrieve first 20 rows from retailmart.products. */
/* Q77. Retrieve product names and prices sorted by name ascending. */
/* Q78. Retrieve 10 records from retailmart.sales.orders. */
/* Q79. Retrieve all customers from retailmart.customers. */
/* Q80. Retrieve all columns from retailmart.hr.employees. */
/* Q81. Retrieve count of all records in retailmart.products. */
/* Q82. Retrieve product_id and product_name columns from retailmart.products. */
/* Q83. Retrieve first 10 orders from retailmart.sales.orders. */
/* Q84. Retrieve all categories from retailmart.products ordered alphabetically. */
/* Q85. Show database name using current_database(). */
/* Q86. Show PostgreSQL version. */
/* Q87. Retrieve size of acciojob database in MB. */
/* Q88. Retrieve all schemas available using information_schema.schemata. */
/* Q89. Retrieve all tables in acciojob.daily schema using information_schema.tables. */
/* Q90. Create table daily_feedback(id SERIAL, feedback TEXT, added_on TIMESTAMP DEFAULT NOW()). */
/* Q91. Insert 5 feedback records. */
/* Q92. Update one feedback text. */
/* Q93. Truncate daily_feedback. */
/* Q94. Drop daily_feedback. */
/* Q95. Retrieve all active connections and terminate one (theoretically mention command). */
/* Q96. Retrieve name of default schema from search_path. */
/* Q97. Retrieve names of all superusers from pg_roles. */
/* Q98. Retrieve total number of user tables created in acciojob. */
/* Q99. Retrieve database creation date from pg_database catalog. */
/* Q100. Retrieve all table names and their schema using pg_class and pg_namespace joins (conceptually allowed). */

/* ============================================================
   ✅ END OF DAY 1 — CRAZY HARD LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - These are advanced system-level and metadata-heavy challenges.
   - Still restricted to setup, DDL, and DML (no joins or filters).
============================================================ */
