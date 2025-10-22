/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 1 (EASY LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: PostgreSQL Setup & Basics
   Database Context:
     - DDL/DML → acciojob.daily
     - SELECT Queries → retailmart
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (20)
   ------------------------------------------------------------ */
/* Q1. What is a database? */
/* Q2. Define DBMS in simple terms. */
/* Q3. What is PostgreSQL used for? */
/* Q4. Differentiate between database and schema. */
/* Q5. What is a table in SQL? */
/* Q6. What is a row in a table? */
/* Q7. What is a column in a table? */
/* Q8. What is pgAdmin 4? */
/* Q9. What command is used to connect to a database? */
/* Q10. What does the CREATE DATABASE command do? */
/* Q11. What is a primary key? */
/* Q12. What is the default port number for PostgreSQL? */
/* Q13. What is meant by DDL? */
/* Q14. What is meant by DML? */
/* Q15. What does SELECT * do in SQL? */
/* Q16. What does DROP TABLE command do? */
/* Q17. What command is used to view all databases? */
/* Q18. What is a schema used for? */
/* Q19. What is the public schema? */
/* Q20. What is the purpose of SQL commands? */

/* ============================================================
   💻 SECTION B: BASIC COMMANDS (40)
   ------------------------------------------------------------ */
/* Q21. Create a database named acciojob. */
/* Q22. Connect to the acciojob database. */
/* Q23. Show all databases in PostgreSQL. */
/* Q24. Create a schema named daily. */
/* Q25. Show all schemas in the current database. */
/* Q26. Create a table named student with id INT and name TEXT. */
/* Q27. Insert one record (1, 'Amit') into student. */
/* Q28. Display all records from student. */
/* Q29. Add a column age INT to student. */
/* Q30. Update Amit's age to 22. */
/* Q31. Delete all records from student. */
/* Q32. Drop the student table. */
/* Q33. Create table course (course_id SERIAL, course_name TEXT). */
/* Q34. Insert 3 sample courses. */
/* Q35. Show all records from course table. */
/* Q36. Create a temporary table temp_marks(id INT, marks INT). */
/* Q37. Insert 2 records into temp_marks. */
/* Q38. Select all records from temp_marks. */
/* Q39. Drop temp_marks table. */
/* Q40. Create schema practice. */
/* Q41. Drop schema practice. */
/* Q42. Create table daily_logs(id SERIAL, log_text TEXT). */
/* Q43. Insert a record ('System started') into daily_logs. */
/* Q44. Select all from daily_logs. */
/* Q45. Create a new role beginner_user. */
/* Q46. Grant CONNECT privilege to beginner_user on acciojob. */
/* Q47. Create table sample_table(id INT PRIMARY KEY). */
/* Q48. Insert value (5) into sample_table. */
/* Q49. Drop table sample_table. */
/* Q50. Create table empty_table(id INT). */
/* Q51. Describe the structure of empty_table. */
/* Q52. Drop empty_table. */
/* Q53. Check PostgreSQL version using SQL query. */
/* Q54. Show current database name. */
/* Q55. Show current user name. */
/* Q56. List all available roles/users. */
/* Q57. Create table greetings(message TEXT). */
/* Q58. Insert record ('Hello PostgreSQL'). */
/* Q59. Select all from greetings. */
/* Q60. Drop table greetings. */

/* ============================================================
   🧩 SECTION C: PRACTICAL DDL & DML TASKS (40)
   ------------------------------------------------------------ */
/* Q61. In acciojob database, create schema daily if not exists. */
/* Q62. Create table daily_products(product_id SERIAL, name TEXT, price NUMERIC). */
/* Q63. Insert 3 sample products. */
/* Q64. Display all from daily_products. */
/* Q65. Update price of first product to 499. */
/* Q66. Delete one record from daily_products. */
/* Q67. Create table daily_customers(customer_id SERIAL, name TEXT, city TEXT). */
/* Q68. Insert 3 customers. */
/* Q69. Create table daily_orders(order_id SERIAL, product_id INT, customer_id INT). */
/* Q70. Insert 2 sample orders. */
/* Q71. Select all orders from daily_orders. */
/* Q72. Join daily_orders with daily_customers to show order with customer name. */
/* Q73. Alter daily_products add column stock INT. */
/* Q74. Update stock of one product to 50. */
/* Q75. Drop column stock from daily_products. */
/* Q76. Rename column name to product_name in daily_products. */
/* Q77. Delete all data from daily_orders without dropping it. */
/* Q78. Drop daily_orders table. */
/* Q79. Create backup of daily_customers as daily_customers_bkp. */
/* Q80. Drop daily_customers_bkp table. */
/* Q81. Retrieve 5 rows from retailmart.products. */
/* Q82. Retrieve all unique categories from retailmart.products. */
/* Q83. Count total products in retailmart.products. */
/* Q84. Show top 3 most expensive products from retailmart.products. */
/* Q85. Show all customers from retailmart.customers. */
/* Q86. Show first 5 employees from retailmart.hr.employees (if exists). */
/* Q87. Display all columns from retailmart.sales.orders. */
/* Q88. Retrieve all products where price > 1000. */
/* Q89. Retrieve products where category = 'Electronics'. */
/* Q90. Count number of orders in retailmart.sales.orders. */
/* Q91. Retrieve first 10 cities from retailmart.customers. */
/* Q92. Retrieve distinct product categories from retailmart.products. */
/* Q93. Retrieve all records where stock > 0 in daily_products (if stock added). */
/* Q94. Create table daily_feedback(id SERIAL, feedback TEXT). */
/* Q95. Insert ('Excellent course') into daily_feedback. */
/* Q96. Select all from daily_feedback. */
/* Q97. Delete all from daily_feedback. */
/* Q98. Drop daily_feedback table. */
/* Q99. Retrieve first 5 records from retailmart.products ordered by price. */
/* Q100. Retrieve all distinct cities from retailmart.customers ordered alphabetically. */

/* ============================================================
   ✅ END OF DAY 1 — EASY LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Do not modify existing retailmart tables.
   - Use acciojob.daily schema for all DDL/DML tasks.
   - Write answers directly below each comment.
============================================================ */
