/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 1 (HARD LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: PostgreSQL Setup & Basics
   Database Context:
     - DDL/DML → acciojob.daily
     - SELECT Queries → retailmart
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (20)
   ------------------------------------------------------------ */
/* Q1. Explain PostgreSQL architecture and how it handles multiple databases. */
/* Q2. What is the difference between PostgreSQL schemas and databases? */
/* Q3. Describe the process of connecting PostgreSQL client tools (pgAdmin, ADS). */
/* Q4. Why is PostgreSQL considered object-relational? */
/* Q5. What are catalogs in PostgreSQL and why are they important? */
/* Q6. Explain the function of WAL (Write Ahead Log) in PostgreSQL. */
/* Q7. How does PostgreSQL ensure data durability? */
/* Q8. Describe the difference between TRUNCATE and DELETE. */
/* Q9. What are some ways to inspect metadata in PostgreSQL? */
/* Q10. Explain the role of OIDs (Object Identifiers). */
/* Q11. What is the difference between roles and users in PostgreSQL? */
/* Q12. How do you verify which user owns a table? */
/* Q13. What are namespaces, and how do they relate to schemas? */
/* Q14. How can you prevent accidental table deletion in PostgreSQL? */
/* Q15. Explain the concept of default privileges. */
/* Q16. How do you change the owner of a table? */
/* Q17. What are the advantages of using multiple schemas in a single database? */
/* Q18. Why should DDL and DML operations be separated in design? */
/* Q19. What happens internally when you execute CREATE DATABASE? */
/* Q20. What is the difference between SUPERUSER and regular user privileges? */

/* ============================================================
   💻 SECTION B: BASIC COMMANDS (40)
   ------------------------------------------------------------ */
/* Q21. Create database acciojob if it does not exist. */
/* Q22. Connect to acciojob. */
/* Q23. Verify the connection using SELECT current_database(). */
/* Q24. Create schema daily if not exists. */
/* Q25. Create table daily_departments(dept_id SERIAL PRIMARY KEY, dept_name TEXT NOT NULL). */
/* Q26. Insert 5 departments into daily_departments. */
/* Q27. Create table daily_employees(emp_id SERIAL, emp_name TEXT, dept_id INT). */
/* Q28. Insert 3 employees linked to department IDs. */
/* Q29. Select all records from daily_employees. */
/* Q30. Add column salary NUMERIC(10,2) to daily_employees. */
/* Q31. Update all employees' salaries to 50000. */
/* Q32. Rename daily_employees to daily_staff. */
/* Q33. Drop column salary from daily_staff. */
/* Q34. Drop and recreate table daily_employees with three columns (id, name, hire_date). */
/* Q35. Insert 3 employees with hire_date as current_date. */
/* Q36. Create temporary table temp_data(a INT, b TEXT). */
/* Q37. Insert 3 sample records into temp_data. */
/* Q38. Select count of records from temp_data. */
/* Q39. Drop temp_data. */
/* Q40. Create table daily_projects(id SERIAL, name TEXT, start_date DATE DEFAULT CURRENT_DATE). */
/* Q41. Insert 2 projects and verify insertion. */
/* Q42. Update project name for one record. */
/* Q43. Delete one record from daily_projects. */
/* Q44. Drop daily_projects. */
/* Q45. Create a role hard_user with LOGIN privilege. */
/* Q46. Grant CREATE privilege on schema daily to hard_user. */
/* Q47. Create table daily_logs(id SERIAL, action TEXT, created_at TIMESTAMP DEFAULT NOW()). */
/* Q48. Insert 3 activity logs (INSERT, UPDATE, DELETE). */
/* Q49. Retrieve all logs sorted by created_at. */
/* Q50. Drop daily_logs. */
/* Q51. Show database size using pg_database_size(). */
/* Q52. Show list of all schemas and their owners. */
/* Q53. Retrieve names of all tables in current schema using information_schema.tables. */
/* Q54. Retrieve PostgreSQL version using SELECT version(). */
/* Q55. Show active sessions using pg_stat_activity. */
/* Q56. Create table daily_branches(branch_id SERIAL, branch_name TEXT, city TEXT). */
/* Q57. Insert 3 branches with different cities. */
/* Q58. Update one city name. */
/* Q59. Delete one record. */
/* Q60. Drop daily_branches table. */

/* ============================================================
   🧩 SECTION C: PRACTICAL DDL & DML TASKS (40)
   ------------------------------------------------------------ */
/* Q61. Create schema daily if not exists in acciojob. */
/* Q62. Create table daily_products(product_id SERIAL, name TEXT, category TEXT, price NUMERIC(10,2)). */
/* Q63. Insert 10 sample rows into daily_products. */
/* Q64. Add a new column brand TEXT to daily_products. */
/* Q65. Update brand for all rows to 'Generic'. */
/* Q66. Delete 2 random records from daily_products. */
/* Q67. Create table daily_customers(customer_id SERIAL, name TEXT, city TEXT, joined_on DATE DEFAULT CURRENT_DATE). */
/* Q68. Insert 5 customers into daily_customers. */
/* Q69. Create table daily_orders(order_id SERIAL, customer_id INT, product_id INT, order_date DATE DEFAULT CURRENT_DATE). */
/* Q70. Insert 5 orders with valid customer and product IDs. */
/* Q71. Retrieve all orders from daily_orders. */
/* Q72. Rename column city to location in daily_customers. */
/* Q73. Drop column brand from daily_products. */
/* Q74. Truncate daily_orders table but retain structure. */
/* Q75. Drop daily_orders table. */
/* Q76. Backup daily_customers into daily_customers_backup. */
/* Q77. Drop daily_customers_backup. */
/* Q78. Retrieve first 15 records from retailmart.products. */
/* Q79. Retrieve all unique categories from retailmart.products. */
/* Q80. Retrieve total number of rows in retailmart.products. */
/* Q81. Retrieve all customers from retailmart.customers. */
/* Q82. Retrieve all employees from retailmart.hr.employees. */
/* Q83. Retrieve 10 records from retailmart.sales.orders. */
/* Q84. Retrieve first 5 product names and prices from retailmart.products. */
/* Q85. Retrieve all distinct product categories from retailmart.products. */
/* Q86. Retrieve total count of rows in retailmart.sales.orders. */
/* Q87. Retrieve all products ordered by name alphabetically. */
/* Q88. Retrieve top 5 products by price (using ORDER BY + LIMIT). */
/* Q89. Show name of current database using SELECT current_database(). */
/* Q90. Retrieve all schemas in acciojob using information_schema.schemata. */
/* Q91. Retrieve all table names from acciojob.daily schema using information_schema.tables. */
/* Q92. Create table daily_feedback(id SERIAL, feedback TEXT, added_on TIMESTAMP DEFAULT NOW()). */
/* Q93. Insert 3 feedback records. */
/* Q94. Select all feedback records ordered by id DESC. */
/* Q95. Truncate daily_feedback table. */
/* Q96. Drop daily_feedback table. */
/* Q97. Show database size in MB for acciojob. */
/* Q98. Show current PostgreSQL user. */
/* Q99. List all databases with their owners. */
/* Q100. List all tables available under retailmart.products schema. */

/* ============================================================
   ✅ END OF DAY 1 — HARD LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Stay within Day 1 concepts (setup, DDL, DML, schema, metadata).
   - No constraints, joins, or filters beyond basics.
============================================================ */