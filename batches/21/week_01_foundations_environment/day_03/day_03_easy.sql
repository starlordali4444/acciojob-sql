/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 3 (EASY LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Data Onboarding + Constraints & Keys (+ UPSERT)
   Day Scope Rules:
     - Focus: Import mindset, CREATE TABLE for clean load, NOT NULL, UNIQUE, CHECK, DEFAULT,
              PRIMARY KEY, FOREIGN KEY, and basic UPSERT (INSERT ... ON CONFLICT ... DO ...).
     - Usage:
         • DDL/DML → acciojob.daily (create NEW tables; do NOT alter retailmart)
         • SELECT (read-only) → retailmart only
   Question Plan: 20 Conceptual + 40 Constraints/Keys Tasks + 40 Practical Load/UPSERT Tasks = 100 total
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (20)
   ------------------------------------------------------------ */
/* Q1. What is the difference between data onboarding and data migration? */
/* Q2. Why do we validate column data types before loading CSV data? */
/* Q3. Define NOT NULL and give a simple use case. */
/* Q4. Define UNIQUE and give a simple use case. */
/* Q5. Define CHECK constraint with a simple example condition. */
/* Q6. What is the purpose of DEFAULT values in a table? */
/* Q7. What is a PRIMARY KEY? Why must it be unique and not null? */
/* Q8. What is a FOREIGN KEY? Conceptually how does it enforce referential integrity? */
/* Q9. What is ON DELETE CASCADE vs ON DELETE RESTRICT (high-level)? */
/* Q10. What is an UPSERT and when is it used? */
/* Q11. Write the generic syntax of INSERT ... ON CONFLICT ... DO NOTHING. */
/* Q12. Write the generic syntax of INSERT ... ON CONFLICT ... DO UPDATE SET .... */
/* Q13. What is a staging table and why is it useful before loading into final tables? */
/* Q14. Why should we avoid duplicate keys during data onboarding? */
/* Q15. How can DEFAULT CURRENT_DATE help during onboarding? */
/* Q16. What is a composite primary key (concept only)? */
/* Q17. What is the difference between logical data checks (CHECK) and business rules in app code? */
/* Q18. Why should FKs reference a PRIMARY KEY or UNIQUE column? */
/* Q19. When would you choose DO NOTHING vs DO UPDATE in an upsert? */
/* Q20. What is the advantage of separating staging tables from production tables? */

/* ============================================================
   🔒 SECTION B: CONSTRAINTS & KEYS TASKS (40)
   (All tasks in acciojob.daily; create NEW tables only.)
   ------------------------------------------------------------ */
/* Q21. Create table d3_products(
         product_id SERIAL PRIMARY KEY,
         sku VARCHAR(30) UNIQUE,
         product_name TEXT NOT NULL
       ). */
/* Q22. Insert 3 rows into d3_products (with unique sku). */
/* Q23. Try inserting a row with NULL product_name to see NOT NULL behavior (then rollback/comment). */
/* Q24. Create table d3_customers(
         customer_id SERIAL PRIMARY KEY,
         customer_code VARCHAR(20) UNIQUE,
         full_name TEXT NOT NULL,
         city TEXT DEFAULT 'Unknown'
       ). */
/* Q25. Insert 3 customers; omit city for at least one to use DEFAULT. */
/* Q26. Create table d3_orders(
         order_id SERIAL PRIMARY KEY,
         customer_id INT REFERENCES daily.d3_customers(customer_id),
         order_date DATE DEFAULT CURRENT_DATE
       ). */
/* Q27. Insert 3 orders with valid customer_id values. */
/* Q28. Attempt to insert an order with a non-existent customer_id (expect FK failure; then comment). */
/* Q29. Create table d3_inventory(
         product_id INT REFERENCES daily.d3_products(product_id),
         location TEXT,
         qty INT CHECK (qty >= 0)
       ). */
/* Q30. Insert 3 inventory rows ensuring qty >= 0. */
/* Q31. Try inserting qty = -5 to observe CHECK failure (comment result). */
/* Q32. Add a UNIQUE constraint on (product_id, location) for d3_inventory (composite unique). */
/* Q33. Insert a duplicate (product_id, location) pair to test the unique pair (expect failure; comment). */
/* Q34. Create table d3_categories(
         category_id SERIAL PRIMARY KEY,
         category_name TEXT UNIQUE NOT NULL
       ). */
/* Q35. Insert 3 categories. */
/* Q36. Create table d3_product_category_map(
         product_id INT REFERENCES daily.d3_products(product_id),
         category_id INT REFERENCES daily.d3_categories(category_id),
         PRIMARY KEY(product_id, category_id)
       ). */
/* Q37. Insert 3 mappings ensuring valid product and category references. */
/* Q38. Attempt a duplicate mapping to test composite PK violation (comment). */
/* Q39. Create table d3_staff(
         staff_id SERIAL PRIMARY KEY,
         staff_code VARCHAR(10) UNIQUE,
         role TEXT CHECK (role IN ('Analyst','Manager','Clerk'))
       ). */
/* Q40. Insert 3 staff rows including each allowed role. */
/* Q41. Try inserting role = 'CEO' to observe CHECK failure (comment). */
/* Q42. Create table d3_suppliers(
         supplier_id SERIAL PRIMARY KEY,
         supplier_name TEXT NOT NULL,
         rating INT DEFAULT 3 CHECK (rating BETWEEN 1 AND 5)
       ). */
/* Q43. Insert 3 suppliers; verify default rating works when not provided. */
/* Q44. Add a FOREIGN KEY from d3_products(sku) referencing a new table? (Skip; instead, note FK must target PK/UNIQUE.) */
/* Q45. Alter d3_customers add UNIQUE constraint on (full_name, city) (composite uniqueness). */
/* Q46. Insert a duplicate (full_name, city) to test the composite unique (expect failure). */
/* Q47. Alter d3_orders set order_date default to CURRENT_DATE (if not already). */
/* Q48. Create table d3_regions(
         region_code VARCHAR(5) PRIMARY KEY,
         region_name TEXT NOT NULL
       ). */
/* Q49. Create table d3_branch(
         branch_id SERIAL PRIMARY KEY,
         region_code VARCHAR(5) REFERENCES daily.d3_regions(region_code)
       ). */
/* Q50. Insert regions and branches validating FK to region_code. */
/* Q51. Attempt to delete a region referenced by branch (expect failure without CASCADE). */
/* Q52. (Concept) Explain ON DELETE CASCADE vs RESTRICT using these tables (comment only). */
/* Q53. Create table d3_payment_modes(
         mode_code TEXT PRIMARY KEY,
         label TEXT UNIQUE NOT NULL
       ). */
/* Q54. Insert 3 payment modes. */
/* Q55. Create table d3_payments(
         payment_id SERIAL PRIMARY KEY,
         order_id INT REFERENCES daily.d3_orders(order_id),
         mode_code TEXT REFERENCES daily.d3_payment_modes(mode_code),
         amount NUMERIC(10,2) CHECK (amount > 0)
       ). */
/* Q56. Insert 3 payments with valid order_id and mode_code. */
/* Q57. Attempt inserting amount = 0 to test CHECK (expect failure). */
/* Q58. Add a DEFAULT of 'CARD' to mode_code in d3_payments (then test insert without mode_code). */
/* Q59. Add NOT NULL to d3_products.product_name (already NOT NULL if defined — ensure). */
/* Q60. Add UNIQUE to d3_customers.customer_code if missing (ensure uniqueness). */

/* ============================================================
   🚚 SECTION C: PRACTICAL ONBOARDING & UPSERT TASKS (40)
   (Use small mock INSERTs to simulate CSV loads; use ON CONFLICT for key handling.)
   ------------------------------------------------------------ */
/* Q61. Create staging table d3_stg_products(sku TEXT, product_name TEXT). */
/* Q62. Insert 5 rows into d3_stg_products with at least 1 duplicated sku. */
/* Q63. Upsert from d3_stg_products into d3_products(sku, product_name):
        - Insert new rows; ignore duplicates by sku (DO NOTHING). */
/* Q64. Show all rows in d3_products to verify upsert behavior (SELECT *). */
/* Q65. Create staging table d3_stg_customers(customer_code TEXT, full_name TEXT, city TEXT). */
/* Q66. Insert 5 rows with 1 duplicate customer_code and a NULL city. */
/* Q67. Upsert into d3_customers(customer_code, full_name, city):
        - On conflict (customer_code) DO UPDATE SET city = EXCLUDED.city. */
/* Q68. Verify city updated for the conflicting record. */
/* Q69. Create staging d3_stg_inventory(product_id INT, location TEXT, qty INT). */
/* Q70. Insert 5 rows with one duplicate (product_id, location) pair. */
/* Q71. Upsert into d3_inventory(product_id, location, qty)
        using ON CONFLICT (product_id, location) DO UPDATE SET qty = EXCLUDED.qty. */
/* Q72. Verify inventory qty for the conflicting pair. */
/* Q73. Create staging d3_stg_orders(customer_id INT, order_date DATE). */
/* Q74. Insert 5 rows; include an invalid customer_id to observe FK failure (comment and correct it). */
/* Q75. Insert valid rows into d3_orders from staging after fixing bad IDs. */
/* Q76. Create d3_stg_payments(order_id INT, mode_code TEXT, amount NUMERIC(10,2)). */
/* Q77. Insert 5 rows with one having amount <= 0 to see CHECK failure (comment and fix). */
/* Q78. Insert valid payments into d3_payments. */
/* Q79. Perform an upsert on d3_payment_modes(mode_code, label) with one duplicate mode_code. */
/* Q80. Verify the label updated for the duplicate mode_code. */
/* Q81. From retailmart.products, SELECT 5 product names for reference only. */
/* Q82. From retailmart.customers, SELECT 5 customer names (read-only reference). */
/* Q83. Create table d3_addresses(
         address_id SERIAL PRIMARY KEY,
         customer_id INT REFERENCES daily.d3_customers(customer_id),
         city TEXT NOT NULL
       ). */
/* Q84. Insert 3 addresses for existing customers. */
/* Q85. Try inserting an address for non-existent customer_id (expect FK error; comment). */
/* Q86. Add CHECK on d3_addresses.city to prevent empty string city (city <> ''). */
/* Q87. Insert one row with empty city to test (expect failure). */
/* Q88. Create d3_stg_categories(category_name TEXT). */
/* Q89. Insert 5 category names including one duplicate. */
/* Q90. Upsert into d3_categories(category_name) using UNIQUE on category_name (DO NOTHING). */
/* Q91. Insert mapping rows into d3_product_category_map for two products. */
/* Q92. Attempt duplicate mapping (expect composite PK violation; comment). */
/* Q93. Add DEFAULT 1 for rating in d3_suppliers (if not already 3) and test by inserting without rating. */
/* Q94. Create d3_stg_staff(staff_code TEXT, role TEXT). */
/* Q95. Insert 4 rows with one invalid role to test CHECK (comment and fix). */
/* Q96. Upsert staff into d3_staff on conflict(staff_code) do update set role = EXCLUDED.role. */
/* Q97. Verify final staff roles. */
/* Q98. Summarize counts for key tables with simple SELECT COUNT(*) (allowed). */
/* Q99. Document (as comments) when DO NOTHING is better than DO UPDATE in your onboarding. */
/* Q100. Document (as comments) a safe step-by-step onboarding checklist you would follow. */

/* ============================================================
   ✅ END OF DAY 3 — EASY LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Keep all writes in acciojob.daily; use retailmart only for read-only lookups.
   - Use clear comments for any expected constraint failure observations.
============================================================ */
