/* ============================================================
   SQL PRACTICE SET - Constraints & DML (EASY LEVEL)
   Curriculum:   RetailMart V3
   Topic:        Constraints, Keys & DML
   Database:     YOUR practice DB - NOT RetailMart V3

   Scope:
     - PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, DEFAULT, NOT NULL
     - CASCADE vs RESTRICT
     - INSERT, UPDATE, DELETE, TRUNCATE
     - Transactions (BEGIN/COMMIT/ROLLBACK at concept level)

   Structure: 25 Conceptual + 25 Constraints + 25 INSERT + 25 UPDATE/DELETE
   ============================================================ */

/* ============================================================
   SECTION A: CONSTRAINTS & DML - CONCEPTUAL (25)
   ------------------------------------------------------------ */
/* Q1.  What does PRIMARY KEY enforce - and what does it implicitly create? */
/* Q2.  Can a table have more than one PRIMARY KEY? Can it have a composite PK? Explain. */
/* Q3.  What does a FOREIGN KEY actually do at the database level? */
/* Q4.  Explain ON DELETE CASCADE in one sentence - and one risk. */
/* Q5.  Explain ON DELETE RESTRICT (or NO ACTION) in one sentence. */
/* Q6.  Explain ON DELETE SET NULL - when would you use it? */
/* Q7.  Difference between UNIQUE and PRIMARY KEY? */
/* Q8.  Can a UNIQUE column be NULL? Can a PRIMARY KEY column be NULL? */
/* Q9.  What's the difference between NOT NULL and a CHECK constraint? */
/* Q10. What does DEFAULT do - and when is it applied? */
/* Q11. Why is INSERT INTO ... VALUES (...) the basic form, and when is INSERT ... SELECT useful? */
/* Q12. Explain UPDATE without WHERE - what's the danger? */
/* Q13. Explain DELETE without WHERE - what's the danger? */
/* Q14. Difference between DELETE and TRUNCATE in 2 sentences. */
/* Q15. Why is TRUNCATE faster than DELETE? */
/* Q16. Can you ROLLBACK a TRUNCATE? */
/* Q17. Can you ROLLBACK a DELETE? */
/* Q18. What is "referential integrity"? */
/* Q19. What happens if you try to INSERT into a child table with a non-existent FK value? */
/* Q20. Can you DROP a parent table if child tables reference it? What's the trick to do it safely? */
/* Q21. Why are constraints checked AT WRITE TIME instead of at query time? */
/* Q22. Difference between a CHECK constraint and a TRIGGER? */
/* Q23. Why do experienced DBAs add NOT NULL to most columns? */
/* Q24. Explain BEGIN/COMMIT/ROLLBACK in one sentence each. */
/* Q25. After ROLLBACK, is the row "deleted" or "never inserted"? Explain. */

/* ============================================================
   SECTION B: ADD CONSTRAINTS TO YOUR TABLES (25)
   These run on the tables you created in Day 3 inside day_03_practice.
   ------------------------------------------------------------ */
/* Q26. Add a UNIQUE constraint on day_03_practice.customers.email. */
/* Q27. Add a NOT NULL constraint on day_03_practice.customers.email. */
/* Q28. Add a CHECK constraint to day_03_practice.products: price > 0. */
/* Q29. Add a CHECK constraint to day_03_practice.product_reviews: rating BETWEEN 1 AND 5. */
/* Q30. Add a FOREIGN KEY: day_03_practice.orders_demo.cust_id references day_03_practice.customers(cust_id). */
/* Q31. Add ON DELETE CASCADE to the orders_demo -> customers FK. (Drop and recreate the FK.) */
/* Q32. Add a NOT NULL constraint on day_03_practice.products.name. */
/* Q33. Add a DEFAULT value FALSE to day_03_practice.products.in_stock. */
/* Q34. Add a DEFAULT NOW() to day_03_practice.customers.created_at. */
/* Q35. Add a multi-column UNIQUE constraint on day_03_practice.tier_master: (tier_name). */
/* Q36. Add a CHECK on day_03_practice.employees: salary >= 0. */
/* Q37. Add a FOREIGN KEY from day_03_practice.transactions.from_account -> bank_accounts.account_id. */
/* Q38. Add a FOREIGN KEY from day_03_practice.transactions.to_account -> bank_accounts.account_id. */
/* Q39. Add a CHECK on bank_accounts: balance >= 0. */
/* Q40. Add a UNIQUE constraint on bank_accounts.holder + opened_on (composite). */
/* Q41. Drop the CHECK constraint you added on products.price > 0. (You'll need to know its name - look it up first.) */
/* Q42. Drop the UNIQUE constraint on customers.email. */
/* Q43. Drop the FOREIGN KEY from orders_demo to customers. */
/* Q44. Add a NOT NULL to feedback.rating. */
/* Q45. Add a CHECK on feedback: rating BETWEEN 1 AND 5. */
/* Q46. Add a DEFAULT 'pending' (TEXT) to a new status column in orders_demo. (Add the column first, then default.) */
/* Q47. Add an inline CHECK constraint while creating a new table day_03_practice.scores (score_id SERIAL PK, score INT CHECK (score BETWEEN 0 AND 100)). */
/* Q48. Create a new table day_03_practice.employees_with_fk that has a FOREIGN KEY to day_03_practice.tier_master(tier_id) on a column tier_id. */
/* Q49. Add ON DELETE SET NULL to the FK in employees_with_fk -> tier_master. */
/* Q50. Add a UNIQUE constraint on day_03_practice.transactions(from_account, txn_time) to prevent duplicate txns. */

/* ============================================================
   SECTION C: INSERT DATA (25)
   ------------------------------------------------------------ */
/* Q51. Insert one row into day_03_practice.customers with email 'aarav@example.com', phone '+91 9000000001', is_active TRUE, created_at NOW(). */
/* Q52. Insert one row into day_03_practice.customers - let cust_id auto-generate (SERIAL), email 'priya@example.com'. */
/* Q53. Insert 3 rows into day_03_practice.tier_master: (1, 'Bronze', 0), (2, 'Silver', 100), (3, 'Gold', 500). */
/* Q54. Insert one row into day_03_practice.products: name 'Mango Juice', price 80.00, in_stock TRUE. */
/* Q55. Insert one row into day_03_practice.products: name 'Premium Tea', price 350.00 - let in_stock take its DEFAULT. */
/* Q56. Try inserting an order into orders_demo for a cust_id that doesn't exist (e.g., 99999). What error do you expect? */
/* Q57. Insert a valid order into orders_demo for an existing customer. */
/* Q58. Insert 5 employees into day_03_practice.employees with one INSERT statement (multi-row INSERT). */
/* Q59. Insert one row into day_03_practice.bank_accounts: holder 'Rahul Sharma', account_type 'Savings', balance 50000, opened_on '2024-01-15'. */
/* Q60. Insert 3 more bank_accounts in a single multi-row INSERT. */
/* Q61. Insert a transaction: from_account 1, to_account 2, amount 5000, txn_time NOW(). */
/* Q62. Try inserting a transaction with from_account = 99999 (doesn't exist). What happens because of the FK? */
/* Q63. Try inserting a customer with NULL email (after you added NOT NULL). What error do you expect? */
/* Q64. Try inserting a product with price = -100. What error do you expect from the CHECK? */
/* Q65. Insert one feedback row: customer_id 1, rating 5, freeform 'Loved it!'. */
/* Q66. Try inserting a feedback with rating = 7. What error from the CHECK? */
/* Q67. Insert into events_log: payload as JSON object {"event":"signup","city":"Mumbai"}, occurred_at NOW(). */
/* Q68. Insert into sessions: session_id gen_random_uuid(), user_id 1, started NOW(), ended NULL. */
/* Q69. Insert a row into day_03_practice.brands: brand_name 'AccioSnacks', country 'India'. */
/* Q70. Insert 3 cities into day_03_practice.cities in one statement: Mumbai/MH, Delhi/DL, Bengaluru/KA. */
/* Q71. Insert 2 payment_modes: 'UPI'/TRUE, 'COD'/TRUE. */
/* Q72. Insert one row into employees_with_fk: full_name 'Test User', tier_id 2 (must exist). */
/* Q73. Try inserting a duplicate email into customers (after UNIQUE added). What error do you expect? */
/* Q74. Insert via SELECT - populate day_03_practice.brands_copy (you'll need to create it first) from brands. */
/* Q75. Insert a transaction that violates the UNIQUE (from_account, txn_time) constraint. What error? */

/* ============================================================
   SECTION D: UPDATE / DELETE / TRUNCATE / TRANSACTIONS (25)
   ------------------------------------------------------------ */
/* Q76. Update day_03_practice.customers SET is_active = FALSE WHERE cust_id = 1. */
/* Q77. Update all products SET in_stock = TRUE. */
/* Q78. Update day_03_practice.products SET price = price * 1.10 - give every product a 10% price hike. */
/* Q79. Update day_03_practice.employees SET salary = 50000 WHERE salary IS NULL. */
/* Q80. Update day_03_practice.customers SET phone = '+91 9999999999' WHERE email = 'aarav@example.com'. */
/* Q81. Update day_03_practice.bank_accounts SET balance = balance - 1000 WHERE account_id = 1. */
/* Q82. Update day_03_practice.bank_accounts SET balance = balance + 1000 WHERE account_id = 2. */
/* Q83. Delete one row: DELETE FROM customers WHERE cust_id = 1. */
/* Q84. Delete all products where price < 50. */
/* Q85. Delete all feedback with rating < 3. */
/* Q86. Delete a customer WITH cascade - verify their orders_demo rows are also deleted (because of ON DELETE CASCADE you added earlier). */
/* Q87. TRUNCATE day_03_practice.feedback - fast wipe. */
/* Q88. TRUNCATE day_03_practice.events_log RESTART IDENTITY - wipe AND reset the BIGSERIAL counter. */
/* Q89. Run a transaction: BEGIN; UPDATE bank_accounts SET balance = balance - 5000 WHERE account_id = 1; UPDATE bank_accounts SET balance = balance + 5000 WHERE account_id = 2; COMMIT. */
/* Q90. Run a transaction that you ROLLBACK to verify rollback works: BEGIN; UPDATE bank_accounts SET balance = 0; ROLLBACK. Then SELECT to verify balances unchanged. */
/* Q91. Update product names: SET name = INITCAP(name) on day_03_practice.products. */
/* Q92. Update day_03_practice.employees SET dept_name = 'Engineering' WHERE dept_name IS NULL. */
/* Q93. Delete from day_03_practice.notifications where sent_at < CURRENT_DATE - INTERVAL '30 days' (purge old notifications). */
/* Q94. Update day_03_practice.subscriptions SET auto_renew = FALSE WHERE ends < CURRENT_DATE. */
/* Q95. Delete from day_03_practice.login_log where login_time < CURRENT_DATE - INTERVAL '90 days'. */
/* Q96. TRUNCATE day_03_practice.notifications. */
/* Q97. Delete every row from sessions where ended IS NOT NULL (already closed). */
/* Q98. Update orders_demo SET total = 0 WHERE total IS NULL. */
/* Q99. Inside a transaction, INSERT a customer, then ROLLBACK. After ROLLBACK, query - should the customer exist? */
/* Q100. Wipe ALL day_03_practice tables by using TRUNCATE ... CASCADE on day_03_practice.customers (cascades to children). */

/* ============================================================
   END OF Constraints & DML - EASY LEVEL (100 QUESTIONS)
   ------------------------------------------------------------
   Tips:
   - Every query in this file runs in YOUR accio_NN practice DB
   - Never run UPDATE / DELETE / TRUNCATE on RetailMart V3
   - When in doubt, wrap the change in BEGIN / ... / ROLLBACK to test
============================================================ */
