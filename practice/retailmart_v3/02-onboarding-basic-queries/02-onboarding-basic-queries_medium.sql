/* ============================================================
   SQL PRACTICE SET - Installation & RetailMart Onboarding (MEDIUM LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Setup, psql power-use, RetailMart V3 exploration
   Database:     RetailMart V3

   Scope:
     - psql backslash commands and PSQL-specific tricks
     - information_schema and pg_catalog queries
     - Multi-step exploration: counts, column inspection, FK lookup
     - COUNT(*) WHERE filters, DISTINCT, basic predicates

   Structure: 20 Setup-deeper + 30 Schema/Catalog + 30 Filtered Counts + 20 Diagnostic
   ============================================================ */

/* ============================================================
   SECTION A: SETUP & PSQL POWER-USE (20)
   ------------------------------------------------------------ */
/* Q1.  In psql, what does \dt+ show that \dt does not? */
/* Q2.  How would you list ALL tables across ALL schemas in psql in one command? */
/* Q3.  In psql, how do you set your output format to expanded (\x) - and when is it useful? */
/* Q4.  How do you turn ON timing in psql to see query execution time? */
/* Q5.  How do you redirect psql output to a file (one command)? */
/* Q6.  Your pgAdmin server connection fails with "could not connect" - list 3 things you'd check. */
/* Q7.  In psql, how do you load a SQL file from disk? */
/* Q8.  What does \df show? */
/* Q9.  How do you describe a specific table's columns in psql? */
/* Q10. How do you exit psql cleanly? */
/* Q11. In VS Code with SQLTools, you can't see RetailMart V3 schemas. List 3 likely causes. */
/* Q12. Your psql prompt shows 'accio_NN=#' - what does the '#' mean? */
/* Q13. How do you change passwords for the postgres user via psql? */
/* Q14. What does the .psql_history file contain and where is it? */
/* Q15. How do you run a single SQL command from the shell WITHOUT entering an interactive psql session? */
/* Q16. Your batch-mate has PostgreSQL but no psql command. What likely went wrong with install? */
/* Q17. How do you check the disk size of EACH database on the server? */
/* Q18. How do you find which user owns the customers.customers table? */
/* Q19. Inside psql, how would you view the actual DDL of the sales.orders table? */
/* Q20. How do you view PostgreSQL's configured shared_buffers value via psql? */

/* ============================================================
   SECTION B: SCHEMA / CATALOG EXPLORATION (30)
   ------------------------------------------------------------ */
/* Q21. Count how many tables exist per schema (top 10) using information_schema.tables. */
/* Q22. List all schemas WITH count of tables in each, sorted descending. */
/* Q23. List all columns of type 'numeric' across the entire database. */
/* Q24. List all columns of type 'date' across all schemas. */
/* Q25. List all columns of type 'jsonb' across all schemas. */
/* Q26. Find every table that has a column literally named 'cust_id'. */
/* Q27. Find every table that has a column literally named 'customer_id'. */
/* Q28. Find every table whose name contains 'log'. */
/* Q29. Find every table whose name contains 'order'. */
/* Q30. Show columns of customers.customers with their data type AND whether nullable. */
/* Q31. Show columns of sales.orders with their data type AND character_maximum_length where applicable. */
/* Q32. List all PRIMARY KEY constraints across the database from information_schema.table_constraints. */
/* Q33. List all FOREIGN KEY constraints. */
/* Q34. List all CHECK constraints. */
/* Q35. List all UNIQUE constraints. */
/* Q36. Show tables in 'sales' schema and the number of columns in each. */
/* Q37. Find every table that has a column named 'email'. */
/* Q38. Find every column whose name contains 'date' across all schemas. */
/* Q39. Find columns whose name contains 'amount'. */
/* Q40. Show all sequences in the database (information_schema.sequences). */
/* Q41. Show all VIEWS in the database. */
/* Q42. Show the data type of customers.customers.tier specifically. */
/* Q43. Show the longest VARCHAR column in the database (highest character_maximum_length). */
/* Q44. List tables in the 'core' schema sorted by table_name. */
/* Q45. List tables in the 'audit' schema. */
/* Q46. Show server version + database name + current user in one row. */
/* Q47. Show the database size for accio_NN + retailmart_v3 (if both exist) in human-readable form. */
/* Q48. Show how many connections are currently open to this DB (pg_stat_activity). */
/* Q49. Show the OS user the database server is running as (use current_setting('cluster_name') or similar). */
/* Q50. List all installed extensions (pg_extension). */

/* ============================================================
   SECTION C: FILTERED COUNTS / DISTINCT EXPLORATION (30)
   ------------------------------------------------------------ */
/* Q51. How many customers are in tier 'Gold'? */
/* Q52. How many customers are in tier 'Platinum'? */
/* Q53. How many products have a price greater than 5000? */
/* Q54. How many orders are 'Cancelled'? */
/* Q55. How many tickets have priority 'Critical'? */
/* Q56. How many tickets are currently 'Open'? */
/* Q57. How many tickets are 'In Progress'? */
/* Q58. How many tickets have NEVER been resolved (resolved_date IS NULL)? */
/* Q59. How many sales.shipments are still in transit (delivered_date IS NULL)? */
/* Q60. How many web_events.page_views are from anonymous users (customer_id IS NULL)? */
/* Q61. How many orders did RetailMart place in calendar year 2025? */
/* Q62. How many orders happened in Q1 2025 (Jan-Mar)? */
/* Q63. How many customers registered in 2024? */
/* Q64. How many distinct cities are in customers.addresses? */
/* Q65. How many distinct store cities are there? */
/* Q66. How many distinct courier_name values in sales.shipments? */
/* Q67. How many distinct call_reason values in call_center.calls? */
/* Q68. How many distinct categories in support.tickets? */
/* Q69. How many distinct brands have at least one product? */
/* Q70. How many distinct payment_mode values are in sales.payments? */
/* Q71. How many ads_spend rows are for platform = 'Google'? */
/* Q72. How many ads_spend rows are for platform = 'Meta' (returns 0 - value isn't in V3 data; verify by checking distinct values). */
/* Q73. How many employees work as 'Store Manager'? */
/* Q74. How many employees work as 'Cashier'? */
/* Q75. How many api_requests had status_code = 500? */
/* Q76. How many api_requests had status_code = 200? */
/* Q77. How many application_logs are at level 'ERROR'? */
/* Q78. How many application_logs are at level 'FATAL'? */
/* Q79. How many page_views are from 'Mobile' devices? */
/* Q80. How many calls have call_duration_seconds = exactly 60 (probable timeout)? */

/* ============================================================
   SECTION D: DIAGNOSTIC / MULTI-STEP QUERIES (20)
   ------------------------------------------------------------ */
/* Q81. Are there any orders with NULL net_total? Find them. */
/* Q82. Are there any customers with NULL first_name? */
/* Q83. Are there any products with NULL brand_id? */
/* Q84. Are there any employees with NULL dept_id? */
/* Q85. Are there any reviews with NULL rating? */
/* Q86. Are there orders with order_date in the FUTURE (after CURRENT_DATE)? */
/* Q87. Are there shipments with delivered_date EARLIER than shipped_date (data quality bug)? */
/* Q88. Are there tickets with resolved_date EARLIER than created_date? */
/* Q89. Are there products with price = 0 or negative? */
/* Q90. Are there employees with salary = 0 or negative? */
/* Q91. Show the date range of sales.orders (MIN and MAX order_date). */
/* Q92. Show the date range of hr.attendance. */
/* Q93. Show the date range of web_events.page_views (view_timestamp). */
/* Q94. Show the date range of marketing.campaigns (start_date min/max). */
/* Q95. Show how many DISTINCT customer_ids appear in sales.orders. */
/* Q96. Show how many DISTINCT product_ids appear in sales.order_items. */
/* Q97. Show how many DISTINCT employee_ids appear in hr.attendance. */
/* Q98. Show how many DISTINCT brand_ids appear in products.products. */
/* Q99. Show how many DISTINCT cust_ids appear in support.tickets. */
/* Q100. Show how many DISTINCT campaign_ids appear in marketing.ads_spend. */

/* ============================================================
   END OF Installation & RetailMart Onboarding - MEDIUM LEVEL (100 QUESTIONS)
============================================================ */
