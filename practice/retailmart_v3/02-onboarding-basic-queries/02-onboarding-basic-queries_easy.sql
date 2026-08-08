/* ============================================================
   SQL PRACTICE SET - Installation & RetailMart Onboarding (EASY LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Installation & RetailMart V3 Onboarding
   Database:     RetailMart V3 (16 schemas, 55 tables)

   Scope:
     - PostgreSQL server/client model
     - psql, pgAdmin 4, VS Code, Git setup
     - First queries: version(), current_database(), schema/table tours
     - SELECT * ... LIMIT N, SELECT count(*)
     - Schema-qualified names

   Structure: 25 Conceptual + 25 Setup Verification + 25 Schema Tour + 25 First Queries
   ============================================================ */

/* ============================================================
   SECTION A: SETUP & POSTGRESQL ARCHITECTURE - CONCEPTUAL (25)
   ------------------------------------------------------------ */
/* Q1.  Your friend asks "is PostgreSQL the same as pgAdmin?" - explain the difference. */
/* Q2.  Explain what psql is in one sentence. */
/* Q3.  In the client-server model, what runs where: PostgreSQL, pgAdmin, your queries? */
/* Q4.  What is the default port PostgreSQL listens on, and why does it matter? */
/* Q5.  Why do you need both PostgreSQL AND pgAdmin? Can't you use just one? */
/* Q6.  A teammate types `psql` in terminal and gets "command not found". Name 2 likely causes. */
/* Q7.  Explain why a fresh PostgreSQL installation usually has a 'postgres' superuser. */
/* Q8.  What is the 'public' schema in PostgreSQL - is it the same as RetailMart's schemas? */
/* Q9.  Name 3 SQL clients besides pgAdmin you could use (any platform). */
/* Q10. Why do we use VS Code AND pgAdmin in this course - what does each do better? */
/* Q11. Your batchmate asks "what does \dt do in psql?" - answer. */
/* Q12. Explain what `\l` lists in psql. */
/* Q13. Explain what `\dn` lists in psql. */
/* Q14. What does `\c some_db` do in psql? */
/* Q15. Your friend says "Git is for code, not databases" - counter-argue why we use Git in this course. */
/* Q16. Explain what `setup_accio_retailmart.sql` does in one sentence. */
/* Q17. Why does the setup script use `\copy` instead of `COPY` for loading CSVs? */
/* Q18. What command in psql exits the session cleanly? */
/* Q19. A junior asks "do I need to run psql with sudo?" - answer with the trade-off. */
/* Q20. Why is PostgreSQL preferred over MySQL for this analytics course? Name two reasons. */
/* Q21. In an interview, you're asked "what's the difference between TCP and Unix-socket connections in PostgreSQL?" - short answer. */
/* Q22. What is a "connection string" - give the typical Postgres format. */
/* Q23. Your teammate forgot the postgres password. Name one safe way to reset it on macOS. */
/* Q24. Why does this course use a SEPARATE practice DB (accio_NN) AND the RetailMart V3 DB? */
/* Q25. After installation, what THREE smoke-test queries should you always run to verify everything works? */

/* ============================================================
   SECTION B: SETUP VERIFICATION QUERIES (25)
   Topics: version, identity, basic system info
   ------------------------------------------------------------ */
/* Q26. Return the PostgreSQL server version (single column). */
/* Q27. Return the name of the database you're currently connected to. */
/* Q28. Return your current login user. */
/* Q29. Return the current date (server-side). */
/* Q30. Return the current timestamp (server-side, with timezone). */
/* Q31. Return the IP address of the server you're connected to (use inet_server_addr()). */
/* Q32. Return the current schema (search_path top entry). */
/* Q33. Return all schemas the user has access to from information_schema.schemata. */
/* Q34. Count how many schemas exist in the database. */
/* Q35. List all table names in the 'sales' schema using information_schema.tables. */
/* Q36. List all table names in the 'customers' schema. */
/* Q37. List all table names in the 'core' schema. */
/* Q38. Count how many tables exist in the 'sales' schema. */
/* Q39. Count how many tables exist across all schemas in this database. */
/* Q40. Return the size of the database in human-readable form (use pg_size_pretty + pg_database_size). */
/* Q41. List columns of customers.customers (use information_schema.columns). */
/* Q42. List columns of sales.orders. */
/* Q43. List columns of products.products. */
/* Q44. Return the data type of every column in stores.employees from information_schema. */
/* Q45. Return the count of distinct schemas owned by the postgres user. */
/* Q46. Return a list of all table names that start with 'order' across any schema. */
/* Q47. Return a list of all table names that contain 'employee' across any schema. */
/* Q48. Return all schema names alphabetically sorted. */
/* Q49. Show the search_path setting for the current session. */
/* Q50. Return the server's timezone setting. */

/* ============================================================
   SECTION C: SCHEMA TOUR - ROW COUNTS & PEEKS (25)
   Topics: SELECT count(*), SELECT * LIMIT N for every major table
   ------------------------------------------------------------ */
/* Q51. Count rows in customers.customers - how many customers does RetailMart have? */
/* Q52. Count rows in sales.orders - total order volume. */
/* Q53. Count rows in sales.order_items - line items across all orders. */
/* Q54. Count rows in products.products - product catalog size. */
/* Q55. Count rows in stores.stores - number of retail outlets. */
/* Q56. Count rows in stores.employees - total headcount. */
/* Q57. Count rows in core.dim_brand - number of brands. */
/* Q58. Count rows in core.dim_category - number of categories. */
/* Q59. Count rows in core.dim_region - number of regions. */
/* Q60. Count rows in core.dim_department - number of departments. */
/* Q61. Count rows in support.tickets - total support cases ever. */
/* Q62. Count rows in marketing.campaigns - campaigns run. */
/* Q63. Count rows in hr.attendance - attendance records. */
/* Q64. Count rows in finance.expenses - expense entries. */
/* Q65. Count rows in payroll.pay_slips - pay slips issued. */
/* Q66. Count rows in loyalty.members - loyalty program enrollment. */
/* Q67. Count rows in audit.application_logs - system logs captured. */
/* Q68. Count rows in audit.api_requests - API hits logged. */
/* Q69. Count rows in web_events.page_views - total page-view events. */
/* Q70. Count rows in call_center.calls - calls handled. */
/* Q71. Count rows in manufacture.work_orders - production work orders. */
/* Q72. Count rows in supply_chain.warehouses - number of warehouses. */
/* Q73. Count rows in sales.returns - return records. */
/* Q74. Count rows in sales.shipments - shipment records. */
/* Q75. Count rows in customers.reviews - product reviews submitted. */

/* ============================================================
   SECTION D: FIRST PEEK AT THE DATA - SELECT * LIMIT (25)
   Topics: SELECT * LIMIT 5 to feel each table's shape
   ------------------------------------------------------------ */
/* Q76. The DBA wants you to "peek" at customers.customers - show the first 5 rows of every column. */
/* Q77. Peek at the first 5 rows of sales.orders. */
/* Q78. Peek at the first 5 rows of products.products. */
/* Q79. Peek at the first 5 rows of stores.employees. */
/* Q80. Peek at the first 5 rows of stores.stores. */
/* Q81. Peek at the first 5 rows of core.dim_brand. */
/* Q82. Peek at the first 5 rows of core.dim_category. */
/* Q83. Peek at the first 5 rows of core.dim_region. */
/* Q84. Peek at the first 5 rows of support.tickets. */
/* Q85. Peek at the first 5 rows of marketing.campaigns. */
/* Q86. Peek at the first 5 rows of hr.attendance. */
/* Q87. Peek at the first 5 rows of finance.expenses. */
/* Q88. Peek at the first 5 rows of payroll.pay_slips. */
/* Q89. Peek at the first 5 rows of loyalty.members. */
/* Q90. Peek at the first 5 rows of loyalty.tiers. */
/* Q91. Peek at the first 5 rows of audit.application_logs. */
/* Q92. Peek at the first 5 rows of audit.api_requests. */
/* Q93. Peek at the first 5 rows of web_events.page_views. */
/* Q94. Peek at the first 5 rows of call_center.calls. */
/* Q95. Peek at the first 5 rows of manufacture.work_orders. */
/* Q96. Peek at the first 5 rows of supply_chain.warehouses. */
/* Q97. Peek at the first 5 rows of supply_chain.shipments. */
/* Q98. Peek at the first 5 rows of customers.addresses. */
/* Q99. Peek at the first 5 rows of customers.reviews. */
/* Q100. Peek at the first 5 rows of customers.wallets. */

/* ============================================================
   END OF Installation & RetailMart Onboarding - EASY LEVEL (100 QUESTIONS)
   ------------------------------------------------------------
   Tips:
   - All queries are simple - focus on TYPING them, not copy-paste
   - Use psql + pgAdmin both - get comfortable with each
   - Schema-qualified names are mandatory: customers.customers, sales.orders
   - After today you should know every major table by sight
============================================================ */
