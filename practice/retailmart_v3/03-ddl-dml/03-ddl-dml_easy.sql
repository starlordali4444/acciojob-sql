/* ============================================================
   SQL PRACTICE SET - DDL & Data Types (EASY LEVEL)
   Curriculum:   RetailMart V3
   Topic:        DDL & Data Types
   Database:     YOUR practice DB - NOT RetailMart V3
                 RetailMart is read-only. Do all DDL in accio_NN.

   Scope:
     - CREATE DATABASE, CREATE SCHEMA, CREATE TABLE
     - DROP TABLE, DROP SCHEMA
     - ALTER TABLE (add/drop/rename column, change type)
     - Data types: INT, SERIAL, BIGSERIAL, NUMERIC, VARCHAR,
                   TEXT, TIMESTAMP, DATE, BOOLEAN, JSONB, UUID

   Structure: 25 Conceptual + 25 CREATE + 25 ALTER + 25 Type Choice
   ============================================================ */

/* ============================================================
   SECTION A: DATA-TYPE & DDL CONCEPTS (25)
   ------------------------------------------------------------ */
/* Q1.  Your junior asks "what is DDL?" - answer in one sentence + give 3 example commands. */
/* Q2.  What does CREATE TABLE actually do behind the scenes? */
/* Q3.  Why do we declare data types instead of letting the DB figure it out? */
/* Q4.  What's the difference between VARCHAR(50) and TEXT? When would you pick each? */
/* Q5.  Why is NUMERIC preferred over FLOAT for storing money? */
/* Q6.  What does SERIAL do? Name 3 things it gives you for free. */
/* Q7.  When would you use BIGSERIAL instead of SERIAL? */
/* Q8.  What's the difference between TIMESTAMP and DATE? */
/* Q9.  When should you use TIMESTAMPTZ instead of plain TIMESTAMP? */
/* Q10. What is JSONB used for, and how does it differ from TEXT containing JSON? */
/* Q11. What is UUID and when would you use it instead of SERIAL? */
/* Q12. What's the difference between CREATE DATABASE and CREATE SCHEMA? */
/* Q13. Can you have two tables with the same name in one database? Explain. */
/* Q14. A junior writes CREATE TABLE Customers (...). Why is lowercase 'customers' usually safer in PostgreSQL? */
/* Q15. Explain what IF NOT EXISTS does in CREATE TABLE - and why it's useful. */
/* Q16. What does DROP TABLE CASCADE do that DROP TABLE alone doesn't? */
/* Q17. What is the danger of running DROP DATABASE in production? */
/* Q18. ALTER TABLE ... ADD COLUMN - what's the default value for the new column on existing rows? */
/* Q19. ALTER TABLE ... DROP COLUMN - is this reversible? Why or why not? */
/* Q20. What happens to existing data when you change a column's TYPE with ALTER TABLE? */
/* Q21. A teammate asks: "what's the difference between CHAR(10) and VARCHAR(10)?" - answer. */
/* Q22. When would you use BOOLEAN vs a 0/1 INT column? */
/* Q23. Why do experienced developers AVOID adding columns at the end of huge tables in production? */
/* Q24. Explain what "domain integrity" means and how data types enforce it. */
/* Q25. Why is it bad to store phone numbers as INT? */

/* ============================================================
   SECTION B: CREATE TABLE PRACTICE (25)
   Topics: Build tables of various shapes
   Each question below is to be run in YOUR accio_NN practice DB.
   ------------------------------------------------------------ */
/* Q26. Create a schema called day_03_practice in your accio_NN database. */
/* Q27. In day_03_practice, create a table employees with: emp_id (SERIAL PK), full_name (VARCHAR 100), salary (NUMERIC 10,2), joined (DATE). */
/* Q28. Create a table products with: product_id SERIAL PK, name VARCHAR(150), price NUMERIC(12,2), in_stock BOOLEAN. */
/* Q29. Create a table customers with: cust_id SERIAL PK, email VARCHAR(100), phone VARCHAR(20), is_active BOOLEAN, created_at TIMESTAMP. */
/* Q30. Create a table orders_demo with: order_id BIGSERIAL PK, cust_id INT, total NUMERIC(12,2), order_date DATE. */
/* Q31. Create a table reviews with: review_id SERIAL PK, rating INT, comment TEXT, posted_on TIMESTAMPTZ. */
/* Q32. Create a table events_log with: event_id BIGSERIAL PK, payload JSONB, occurred_at TIMESTAMPTZ. */
/* Q33. Create a table sessions with: session_id UUID PK, user_id INT, started TIMESTAMPTZ, ended TIMESTAMPTZ. */
/* Q34. Create a tiny lookup table tier_master with: tier_id INT PK, tier_name VARCHAR(20), min_points INT. */
/* Q35. Create an audit table login_log with: log_id BIGSERIAL PK, user_id INT, login_time TIMESTAMP, ip_address VARCHAR(45). */
/* Q36. Create a table feedback with: feedback_id SERIAL PK, customer_id INT, rating INT, freeform TEXT. */
/* Q37. Create a SECOND schema called day_03_archive (for old data). */
/* Q38. Create a table day_03_archive.old_orders with: order_id INT PK, archived_at TIMESTAMP. */
/* Q39. Create a table day_03_practice.cities with city_id SERIAL PK, city_name VARCHAR(50), state VARCHAR(50). */
/* Q40. Create a table day_03_practice.brands: brand_id SERIAL PK, brand_name VARCHAR(100), country VARCHAR(50). */
/* Q41. Drop the day_03_practice.cities table you just created. */
/* Q42. Recreate cities - but this time use IF NOT EXISTS so it doesn't error if it already exists. */
/* Q43. Create a table inventory with composite primary key (warehouse_id INT, product_id INT, snapshot_date DATE) and quantity_on_hand INT. */
/* Q44. Create a table phone_book with name VARCHAR(100) and phone_number VARCHAR(20) - NO primary key (intentional, to learn what happens). */
/* Q45. Create a table products_v2 (in day_03_practice) that is identical to products but adds a sku_code VARCHAR(50) column. */
/* Q46. Create a table day_03_practice.payment_modes: mode_id SERIAL PK, mode_name VARCHAR(30), is_active BOOLEAN. */
/* Q47. Create a table day_03_practice.bank_accounts: account_id SERIAL PK, holder VARCHAR(100), balance NUMERIC(14,2), opened_on DATE. */
/* Q48. Create a table day_03_practice.transactions: txn_id BIGSERIAL PK, from_account INT, to_account INT, amount NUMERIC(14,2), txn_time TIMESTAMPTZ. */
/* Q49. Create a table day_03_practice.subscriptions: sub_id SERIAL PK, user_id INT, plan_name VARCHAR(50), starts DATE, ends DATE, auto_renew BOOLEAN. */
/* Q50. Create a table day_03_practice.notifications: notif_id BIGSERIAL PK, user_id INT, channel VARCHAR(20), sent_at TIMESTAMPTZ, payload JSONB. */

/* ============================================================
   SECTION C: ALTER TABLE PRACTICE (25)
   Topics: Add, drop, rename columns; change types
   ------------------------------------------------------------ */
/* Q51. Add a new column 'department' VARCHAR(50) to day_03_practice.employees. */
/* Q52. Add a new column 'last_login' TIMESTAMP to day_03_practice.customers. */
/* Q53. Add a column 'discount_pct' INT to day_03_practice.products. */
/* Q54. Add a column 'is_verified' BOOLEAN to day_03_practice.customers. */
/* Q55. Add a column 'updated_at' TIMESTAMPTZ to day_03_practice.products. */
/* Q56. Rename the column 'department' in employees to 'dept_name'. */
/* Q57. Rename the column 'discount_pct' in products to 'discount_percent'. */
/* Q58. Rename the table 'reviews' to 'product_reviews'. */
/* Q59. Drop the column 'last_login' from customers. */
/* Q60. Drop the column 'is_active' from customers. */
/* Q61. Change the type of products.price from NUMERIC(12,2) to NUMERIC(14,2) - to allow larger prices. */
/* Q62. Change the type of employees.salary to NUMERIC(12,2). */
/* Q63. Change customers.phone from VARCHAR(20) to VARCHAR(25). */
/* Q64. Add a column 'tags' of type TEXT[] (array of text) to day_03_practice.products. */
/* Q65. Add a column 'metadata' of type JSONB to day_03_practice.products. */
/* Q66. Add a column 'rating_avg' NUMERIC(3,2) to day_03_practice.products. */
/* Q67. Drop the column 'metadata' you just added to products. */
/* Q68. Add a column 'created_at' TIMESTAMP with DEFAULT CURRENT_TIMESTAMP to day_03_practice.products. */
/* Q69. Add a column 'is_archived' BOOLEAN with DEFAULT FALSE to day_03_practice.products. */
/* Q70. Set a DEFAULT of 0 on the discount_percent column in products. */
/* Q71. Drop the DEFAULT from discount_percent. */
/* Q72. Rename the schema day_03_archive to day_03_cold_storage. */
/* Q73. Drop the table day_03_practice.notifications. */
/* Q74. Drop the entire day_03_cold_storage schema with CASCADE (removes everything inside). */
/* Q75. Drop the day_03_practice.subscriptions table only if it exists (use IF EXISTS). */

/* ============================================================
   SECTION D: PICK THE RIGHT DATA TYPE (25)
   For each scenario, the question asks you to write the column
   declaration with the type you'd choose. Run nothing - just
   declare the type.
   ------------------------------------------------------------ */
/* Q76. Storing an Indian phone number ("+91 9876543210"). What type? */
/* Q77. Storing a customer's lifetime spend (Rs with paisa precision). What type? */
/* Q78. Storing a product description that could be a few sentences. What type? */
/* Q79. Storing whether a customer has opted in to marketing emails. What type? */
/* Q80. Storing the timestamp a user clicked a button (millisecond precision, with timezone). What type? */
/* Q81. Storing just the date someone joined the company. What type? */
/* Q82. Storing a UPI VPA like "priya@axis". What type and length? */
/* Q83. Storing a pincode (always 6 digits). What type and constraint? */
/* Q84. Storing the latitude of a delivery address. What type and precision? */
/* Q85. Storing a primary key for a small lookup table (~50 rows). What type? */
/* Q86. Storing a primary key for a high-volume events table (1B+ rows). What type? */
/* Q87. Storing event payload from an API webhook (nested JSON). What type? */
/* Q88. Storing a session token that should be globally unique. What type? */
/* Q89. Storing an order quantity (small integer, 1-1000). What type? */
/* Q90. Storing a percentage value like 12.50% with 2 decimal precision. What type? */
/* Q91. Storing a long product review that might be 5,000 characters. What type? */
/* Q92. Storing a yes/no flag for is_email_verified. What type? */
/* Q93. Storing a date range start (just a date, no time). What type? */
/* Q94. Storing a website URL (could be 2,000 chars). What type? */
/* Q95. Storing tax_rate as a percentage with 4 decimal precision (e.g., 18.0000). What type? */
/* Q96. Storing tags for a blog post (multiple tags per post). What type or design? */
/* Q97. Storing IPv4 / IPv6 addresses. What type? */
/* Q98. Storing a hash (SHA-256, 64 hex chars). What type? */
/* Q99. Storing a price in USD that may need precision up to 4 decimals (currency conversion). What type? */
/* Q100. Storing a one-letter status code ('A', 'I', 'D'). What type? */

/* ============================================================
   END OF DDL & Data Types - EASY LEVEL (100 QUESTIONS)
   ------------------------------------------------------------
   Tips:
   - Run ALL queries in YOUR accio_NN practice DB, never in RetailMart
   - After CREATE practice, use \dt and \d table_name to verify
   - Data type choice is a JUDGMENT skill - practice naming the tradeoff
============================================================ */
