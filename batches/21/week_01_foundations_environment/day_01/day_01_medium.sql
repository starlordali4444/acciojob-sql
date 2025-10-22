/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 1 (MEDIUM LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: PostgreSQL Setup & Basics
   Database Context:
     - DDL/DML → acciojob.daily
     - SELECT Queries → retailmart
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (20)
   ------------------------------------------------------------ */
/* Q1. Explain the difference between DBMS and RDBMS with examples. */
/* Q2. What is the role of PostgreSQL in data analysis? */
/* Q3. Define a schema and explain its importance in database organization. */
/* Q4. How does PostgreSQL store databases on the file system? */
/* Q5. What is the difference between CREATE DATABASE and CREATE SCHEMA? */
/* Q6. What is the use of SERIAL data type in PostgreSQL? */
/* Q7. What happens if we try to create a schema that already exists? */
/* Q8. What is the function of the 'public' schema in PostgreSQL? */
/* Q9. What is the difference between DROP DATABASE and DROP SCHEMA? */
/* Q10. What is a data type, and why is it important in table creation? */
/* Q11. Explain the difference between VARCHAR and TEXT. */
/* Q12. What is the significance of DEFAULT values in a table? */
/* Q13. How can you describe the structure of an existing table? */
/* Q14. What are system catalogs in PostgreSQL? */
/* Q15. What are metadata queries used for? */
/* Q16. How do we check PostgreSQL version using SQL command? */
/* Q17. What does the term 'relational' mean in RDBMS? */
/* Q18. Explain what pgAdmin 4 interface allows you to do. */
/* Q19. What is the difference between SQL script and SQL query? */
/* Q20. What are the advantages of organizing tables in schemas? */

/* ============================================================
   💻 SECTION B: BASIC COMMANDS (40)
   ------------------------------------------------------------ */
/* Q21. Create a new database named acciojob. */
/* Q22. Connect to the acciojob database. */
/* Q23. List all existing databases. */
/* Q24. Create a schema named daily. */
/* Q25. Show all schemas in the current database. */
/* Q26. Create a table daily_employees(emp_id SERIAL, emp_name TEXT, designation TEXT). */
/* Q27. Insert 3 employees into daily_employees. */
/* Q28. Select all records from daily_employees. */
/* Q29. Add a column department TEXT to daily_employees. */
/* Q30. Update designation of one employee to 'Analyst'. */
/* Q31. Rename table daily_employees to daily_staff. */
/* Q32. Drop column department from daily_staff. */
/* Q33. Delete one record from daily_staff. */
/* Q34. Drop the table daily_staff. */
/* Q35. Create schema temp_space. */
/* Q36. Drop schema temp_space. */
/* Q37. Create table daily_projects(proj_id INT, proj_name TEXT). */
/* Q38. Insert two projects into daily_projects. */
/* Q39. Display all records from daily_projects. */
/* Q40. Drop daily_projects table. */
/* Q41. Create table sample_table(a INT, b TEXT). */
/* Q42. Insert 2 records into sample_table. */
/* Q43. Update one record in sample_table. */
/* Q44. Delete one record in sample_table. */
/* Q45. Drop sample_table. */
/* Q46. Create a new role medium_user with LOGIN privilege. */
/* Q47. Grant USAGE on schema daily to medium_user. */
/* Q48. Create table daily_logs(id SERIAL, action TEXT, log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP). */
/* Q49. Insert 3 activity logs. */
/* Q50. Select all logs ordered by id. */
/* Q51. Drop daily_logs table. */
/* Q52. Show the name of the current database. */
/* Q53. Show all active connections using SQL query (hint: pg_stat_activity). */
/* Q54. Show PostgreSQL version. */
/* Q55. Create table daily_branches(id SERIAL, branch_name TEXT). */
/* Q56. Insert 3 branches into daily_branches. */
/* Q57. Select all branches. */
/* Q58. Drop daily_branches. */
/* Q59. Show all users/roles present in the system. */
/* Q60. Drop role medium_user. */

/* ============================================================
   🧩 SECTION C: PRACTICAL DDL & DML TASKS (40)
   ------------------------------------------------------------ */
/* Q61. Create schema daily if not exists in acciojob database. */
/* Q62. Create table daily_products(product_id SERIAL, name TEXT, category TEXT, price NUMERIC(10,2)). */
/* Q63. Insert 5 sample records into daily_products. */
/* Q64. Select all from daily_products. */
/* Q65. Update price of one product to 799. */
/* Q66. Delete one product record. */
/* Q67. Create table daily_customers(customer_id SERIAL, name TEXT, email TEXT). */
/* Q68. Insert 3 customer records. */
/* Q69. Select all records from daily_customers. */
/* Q70. Rename daily_customers table to daily_clients. */
/* Q71. Add a new column city TEXT to daily_clients. */
/* Q72. Update one customer's city to 'Delhi'. */
/* Q73. Drop column email from daily_clients. */
/* Q74. Delete all rows from daily_clients but keep structure. */
/* Q75. Drop daily_clients table. */
/* Q76. Create table daily_sales(id SERIAL, product_id INT, sale_date DATE DEFAULT CURRENT_DATE). */
/* Q77. Insert 2 sales records. */
/* Q78. Select all from daily_sales. */
/* Q79. Drop daily_sales. */
/* Q80. Retrieve first 10 records from retailmart.products. */
/* Q81. Retrieve all distinct categories from retailmart.products. */
/* Q82. Count total number of rows in retailmart.products (no filters). */
/* Q83. Retrieve first 5 customers from retailmart.customers. */
/* Q84. Retrieve all columns from retailmart.sales.orders. */
/* Q85. Retrieve product names and categories from retailmart.products. */
/* Q86. Retrieve product_id and price columns from retailmart.products. */
/* Q87. Retrieve first 5 employees from retailmart.hr.employees. */
/* Q88. Show database name of retailmart using current_database(). */
/* Q89. Retrieve all columns from retailmart.products ordered by product_id. */
/* Q90. Retrieve all product names sorted alphabetically (no filter). */
/* Q91. Show first 5 rows from retailmart.products using LIMIT. */
/* Q92. Retrieve total number of schemas available in acciojob. */
/* Q93. Show all tables in retailmart.products schema. */
/* Q94. Create table daily_feedback(id SERIAL, feedback TEXT, created_at TIMESTAMP DEFAULT NOW()). */
/* Q95. Insert 2 feedback entries. */
/* Q96. Select all from daily_feedback. */
/* Q97. Truncate daily_feedback table. */
/* Q98. Drop daily_feedback table. */
/* Q99. Show current user name. */
/* Q100. List all tables created in acciojob.daily schema. */

/* ============================================================
   ✅ END OF DAY 1 — MEDIUM LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Do not modify existing retailmart tables.
   - Use acciojob.daily schema for all DDL/DML tasks.
   - Stay within Day 1 topics only (no constraints, filters, or joins).
============================================================ */
