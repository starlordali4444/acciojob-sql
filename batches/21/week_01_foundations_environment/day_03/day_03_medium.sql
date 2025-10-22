/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 3 (MEDIUM LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Data Onboarding + Constraints & Keys + UPSERT
   Scope: Multiple-table onboarding with constraints and conflict-handling.
   Rules:
     - Focus: NOT NULL, UNIQUE, CHECK, DEFAULT, PRIMARY/FOREIGN KEYS, ON DELETE/UPDATE actions, UPSERT logic.
     - DDL/DML → acciojob.daily  |  SELECT (read-only) → retailmart
   Question Plan: 20 Conceptual + 40 Constraint Tasks + 40 Practical = 100 total
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (20)
   ------------------------------------------------------------ */
/* Q1. What is the difference between TRUNCATE and DELETE during onboarding? */
/* Q2. Explain why foreign key references are useful for maintaining relational integrity. */
/* Q3. What does ON UPDATE CASCADE do in PostgreSQL? */
/* Q4. What happens when a referenced parent record is deleted under ON DELETE SET NULL? */
/* Q5. What are the advantages of enforcing constraints at the database level instead of application code? */
/* Q6. Can a table have multiple UNIQUE constraints? If yes, why? */
/* Q7. When should a CHECK constraint be preferred over a trigger? */
/* Q8. What is the difference between UPSERT and MERGE? */
/* Q9. How does ON CONFLICT differ from IGNORE in MySQL? */
/* Q10. Why should a staging table not have primary keys during bulk onboarding? */
/* Q11. What is a cascading delete and when might it be dangerous? */
/* Q12. Can a DEFAULT be dynamic (e.g., from another table)? */
/* Q13. What are composite primary keys and when are they needed? */
/* Q14. Why is data type consistency critical for foreign key relationships? */
/* Q15. What happens if you try to reference a non-unique column in a foreign key? */
/* Q16. How can deferred constraint checks improve onboarding performance? */
/* Q17. What is the role of information_schema when verifying constraints? */
/* Q18. Explain the difference between column-level and table-level constraints. */
/* Q19. What is the difference between DO NOTHING and DO UPDATE in upsert behavior? */
/* Q20. Why is normalization important before defining foreign keys? */

/* ============================================================
   🔒 SECTION B: CONSTRAINTS & KEYS TASKS (40)
   ------------------------------------------------------------ */
/* Q21. Create table m3_regions(
         region_id SERIAL PRIMARY KEY,
         region_name TEXT UNIQUE NOT NULL
       ). */
/* Q22. Insert 3 regions into m3_regions. */
/* Q23. Create table m3_branch(
         branch_id SERIAL PRIMARY KEY,
         branch_name TEXT NOT NULL,
         region_id INT REFERENCES daily.m3_regions(region_id) ON DELETE SET NULL
       ). */
/* Q24. Insert 3 branches linked to regions. */
/* Q25. Delete one region and observe ON DELETE SET NULL effect on branches. */
/* Q26. Create table m3_roles(role_code TEXT PRIMARY KEY, role_name TEXT UNIQUE NOT NULL). */
/* Q27. Create table m3_employees(
         emp_id SERIAL PRIMARY KEY,
         emp_code TEXT UNIQUE NOT NULL,
         emp_name TEXT NOT NULL,
         role_code TEXT REFERENCES daily.m3_roles(role_code) ON UPDATE CASCADE
       ). */
/* Q28. Insert 3 roles and 5 employees linked to them. */
/* Q29. Update a role_code in m3_roles to see cascading effect in employees. */
/* Q30. Create table m3_suppliers(
         supplier_id SERIAL PRIMARY KEY,
         name TEXT NOT NULL,
         credit_limit NUMERIC(10,2) CHECK (credit_limit >= 0 AND credit_limit <= 100000)
       ). */
/* Q31. Insert suppliers, including one boundary case with credit_limit = 100000. */
/* Q32. Try inserting credit_limit = -1 to observe CHECK failure. */
/* Q33. Create table m3_products(
         product_id SERIAL PRIMARY KEY,
         sku TEXT UNIQUE NOT NULL,
         price NUMERIC(10,2) DEFAULT 0 CHECK (price >= 0)
       ). */
/* Q34. Insert products with positive price and one without price (test DEFAULT). */
/* Q35. Create table m3_orders(
         order_id SERIAL PRIMARY KEY,
         product_id INT REFERENCES daily.m3_products(product_id),
         supplier_id INT REFERENCES daily.m3_suppliers(supplier_id),
         order_date DATE DEFAULT CURRENT_DATE
       ). */
/* Q36. Insert orders ensuring valid FKs. */
/* Q37. Attempt to insert invalid product_id to test FK constraint (comment expected failure). */
/* Q38. Alter m3_suppliers add UNIQUE constraint on (name). */
/* Q39. Attempt inserting duplicate supplier name to verify unique constraint (comment expected failure). */
/* Q40. Add CHECK constraint to m3_products ensuring sku length > 3 using LENGTH(sku) > 3. */
/* Q41. Try inserting sku='AB' to test check constraint (expect failure). */
/* Q42. Alter m3_orders add CHECK constraint to ensure supplier_id > 0. */
/* Q43. Attempt inserting supplier_id = 0 (expect failure). */
/* Q44. Add DEFAULT value for supplier_id in m3_orders = 1. */
/* Q45. Verify default supplier_id works when omitted. */
/* Q46. Add a FOREIGN KEY from m3_orders.product_id referencing m3_products(product_id) ON DELETE CASCADE. */
/* Q47. Delete a product and check cascading delete effect on m3_orders. */
/* Q48. Add NOT NULL constraint to m3_products.sku if not already enforced. */
/* Q49. Create table m3_customers(
         customer_id SERIAL PRIMARY KEY,
         email TEXT UNIQUE NOT NULL,
         city TEXT DEFAULT 'NA'
       ). */
/* Q50. Insert customers and verify DEFAULT behavior. */
/* Q51. Create table m3_addresses(
         addr_id SERIAL PRIMARY KEY,
         customer_id INT REFERENCES daily.m3_customers(customer_id),
         city TEXT CHECK (city <> '')
       ). */
/* Q52. Try inserting an address with empty city (expect failure). */
/* Q53. Add composite UNIQUE on (customer_id, city). */
/* Q54. Attempt duplicate (customer_id, city) combination (expect failure). */
/* Q55. Create table m3_pay_modes(code TEXT PRIMARY KEY, label TEXT UNIQUE). */
/* Q56. Insert 3 modes (CASH, CARD, ONLINE). */
/* Q57. Create table m3_payments(
         pay_id SERIAL PRIMARY KEY,
         order_id INT REFERENCES daily.m3_orders(order_id),
         mode TEXT REFERENCES daily.m3_pay_modes(code),
         amount NUMERIC(10,2) CHECK (amount > 0)
       ). */
/* Q58. Insert payments and test check constraint violation for amount=0. */
/* Q59. Alter m3_payments add DEFAULT 100 for amount. */
/* Q60. Insert row omitting amount to test default. */

/* ============================================================
   🚀 SECTION C: PRACTICAL ONBOARDING & UPSERT TASKS (40)
   ------------------------------------------------------------ */
/* Q61. Create staging table m3_stg_products(sku TEXT, price NUMERIC(10,2)). */
/* Q62. Insert 5 rows, including duplicate sku. */
/* Q63. Upsert into m3_products using ON CONFLICT (sku) DO UPDATE SET price = EXCLUDED.price. */
/* Q64. Verify updated prices. */
/* Q65. Create staging table m3_stg_suppliers(name TEXT, credit_limit NUMERIC(10,2)). */
/* Q66. Insert 5 rows, one with existing name. */
/* Q67. Upsert into m3_suppliers(name, credit_limit) ON CONFLICT (name) DO NOTHING. */
/* Q68. Verify duplicates ignored. */
/* Q69. Create staging table m3_stg_orders(product_id INT, supplier_id INT, order_date DATE). */
/* Q70. Insert 5 rows, including invalid FK IDs (comment expected failures). */
/* Q71. Fix and insert valid FKs into m3_orders. */
/* Q72. Upsert into m3_orders ON CONFLICT (order_id) DO UPDATE SET order_date = EXCLUDED.order_date. */
/* Q73. Verify upsert updated order_date for conflict. */
/* Q74. Create staging table m3_stg_customers(email TEXT, city TEXT). */
/* Q75. Insert 5 customers, including one duplicate email. */
/* Q76. Upsert into m3_customers(email, city) ON CONFLICT (email) DO UPDATE SET city = EXCLUDED.city. */
/* Q77. Verify updated city. */
/* Q78. Create staging table m3_stg_payments(order_id INT, mode TEXT, amount NUMERIC(10,2)). */
/* Q79. Insert 5 rows, one duplicate order_id. */
/* Q80. Upsert into m3_payments(order_id, mode, amount) using ON CONFLICT (order_id) DO UPDATE SET amount = EXCLUDED.amount. */
/* Q81. Verify updated payment amounts. */
/* Q82. Demonstrate deleting a supplier referenced by order to trigger cascade. */
/* Q83. Attempt inserting payment with amount = -100 (expect check failure). */
/* Q84. Add new CHECK on m3_suppliers for credit_limit BETWEEN 1 AND 500000. */
/* Q85. Create backup of m3_customers as m3_customers_bkp. */
/* Q86. Delete all rows in backup and drop table. */
/* Q87. Retrieve first 10 products from retailmart.products (read-only). */
/* Q88. Retrieve 10 customers from retailmart.customers (read-only). */
/* Q89. List all constraints defined on m3_products using information_schema.table_constraints. */
/* Q90. Retrieve foreign keys for m3_orders using information_schema.key_column_usage. */
/* Q91. Retrieve check constraints from m3_suppliers using information_schema.check_constraints. */
/* Q92. Retrieve columns having default values using information_schema.columns. */
/* Q93. Retrieve all tables in acciojob.daily created today using pg_stat_all_tables. */
/* Q94. Retrieve constraint types and names from information_schema.table_constraints for all m3_ tables. */
/* Q95. Retrieve PostgreSQL version. */
/* Q96. Retrieve schema names using current_schema() and show search_path. */
/* Q97. Retrieve all unique constraints across acciojob.daily. */
/* Q98. Retrieve total number of foreign keys defined in acciojob.daily schema. */
/* Q99. Comment on the difference between DO NOTHING and DO UPDATE for onboarding. */
/* Q100. Comment a detailed onboarding pipeline you would design to ensure safe constraint enforcement. */

/* ============================================================
   ✅ END OF DAY 3 — MEDIUM LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Maintain proper DDL/DML boundaries.
   - Keep all FK/PK references consistent with created tables.
   - Document expected constraint violations as comments for learning.
============================================================ */
