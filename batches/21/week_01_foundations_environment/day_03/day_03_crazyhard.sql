/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 3 (CRAZY HARD LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Data Onboarding + Constraints & Keys + UPSERT (Expert)
   Scope & Rules (STRICT):
     - Focus ONLY on constraints (NOT NULL, UNIQUE, CHECK, DEFAULT, PK, FK),
       referential actions (ON DELETE/UPDATE ...), and UPSERT patterns.
     - Include advanced topics: DEFERRABLE constraints, deferred checks, transactional onboarding.
     - DDL/DML → acciojob.daily     |     Read-only SELECT → retailmart
     - No joins/filters beyond simple SELECTs for verification (joins proper come later days).
   Structure: 20 Conceptual + 40 Constraint/Key Tasks + 40 Practical/UPSERT Tasks = 100
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (20)
   ------------------------------------------------------------ */
/* Q1. Explain DEFERRABLE vs NOT DEFERRABLE constraints with real onboarding scenarios. */
/* Q2. What does INITIALLY DEFERRED vs INITIALLY IMMEDIATE mean for FK/UNIQUE checks? */
/* Q3. Why might you wrap onboarding in BEGIN; SET CONSTRAINTS ALL DEFERRED; ... COMMIT;? */
/* Q4. Compare DO NOTHING vs DO UPDATE in upserts for late-arriving dimension records. */
/* Q5. When would you model a composite PRIMARY KEY instead of a surrogate SERIAL? */
/* Q6. Explain the difference between business keys and surrogate keys in onboarding. */
/* Q7. Give examples of multi-column CHECK constraints with cross-column logic. */
/* Q8. Why is ON UPDATE CASCADE rarely used for natural keys? Risks and benefits. */
/* Q9. Describe a safe plan to add NOT NULL to a column that already contains NULLs. */
/* Q10. What pitfalls exist when changing DEFAULTs during rolling data loads? */
/* Q11. How can deferred FKs help when loading mutually dependent tables? */
/* Q12. Outline an approach to migrate from UNIQUE(email) to UNIQUE(email, country). */
/* Q13. How would you backfill valid defaults before enabling CHECK constraints? */
/* Q14. Explain why UPSERTs should be idempotent in batch pipelines. */
/* Q15. How would you detect which rows updated during an UPSERT? (high-level) */
/* Q16. Contrast ON DELETE RESTRICT vs NO ACTION in PostgreSQL semantics. */
/* Q17. When is ON DELETE SET NULL preferable to CASCADE? Give two examples. */
/* Q18. How do you temporarily disable a constraint for load, then re-enable safely? */
/* Q19. What verification queries prove referential integrity after a large load? */
/* Q20. Describe a rollback plan when an onboarding step fails mid-transaction. */

/* ============================================================
   🔒 SECTION B: ADVANCED CONSTRAINTS & KEYS TASKS (40)
   (Use transactions, deferrable constraints, and multi-table relationships.)
   ------------------------------------------------------------ */
/* Q21. BEGIN; Create table c3_dim_region(
         region_code TEXT PRIMARY KEY,
         region_name TEXT UNIQUE NOT NULL
       ) DEFERRABLE INITIALLY DEFERRED; COMMIT; */
/* Q22. Create table c3_dim_branch(
         branch_code TEXT PRIMARY KEY,
         region_code TEXT,
         CONSTRAINT fk_branch_region FOREIGN KEY(region_code)
           REFERENCES daily.c3_dim_region(region_code)
           ON DELETE RESTRICT ON UPDATE CASCADE
           DEFERRABLE INITIALLY DEFERRED
       ); */
/* Q23. Insert two regions and three branches in a single transaction with constraints deferred. */
/* Q24. Add table c3_customer(
         customer_id SERIAL PRIMARY KEY,
         email TEXT NOT NULL,
         country TEXT DEFAULT 'IN',
         CONSTRAINT uq_email_country UNIQUE(email, country)
       ); */
/* Q25. Try inserting duplicate emails with different countries (should succeed) and same country (should fail). */
/* Q26. Create table c3_product(
         product_id SERIAL PRIMARY KEY,
         sku TEXT NOT NULL,
         price NUMERIC(10,2) DEFAULT 0 CHECK (price >= 0),
         CONSTRAINT uq_sku UNIQUE(sku)
       ); */
/* Q27. Add CHECK on c3_product to ensure LENGTH(sku) >= 4; test with 'AB' (expect failure). */
/* Q28. Create table c3_order_header(
         order_id SERIAL PRIMARY KEY,
         customer_id INT NOT NULL,
         order_date DATE DEFAULT CURRENT_DATE,
         CONSTRAINT fk_oh_customer FOREIGN KEY(customer_id)
           REFERENCES daily.c3_customer(customer_id)
           DEFERRABLE INITIALLY DEFERRED
       ); */
/* Q29. Create table c3_order_line(
         order_id INT,
         line_no INT,
         product_id INT,
         qty INT CHECK (qty > 0),
         CONSTRAINT pk_ol PRIMARY KEY(order_id, line_no),
         CONSTRAINT fk_ol_order FOREIGN KEY(order_id) REFERENCES daily.c3_order_header(order_id) DEFERRABLE,
         CONSTRAINT fk_ol_product FOREIGN KEY(product_id) REFERENCES daily.c3_product(product_id) DEFERRABLE
       ); */
/* Q30. In a single transaction with constraints deferred, insert header and lines out-of-order (lines first, then header) and commit. */
/* Q31. Add ON DELETE CASCADE on fk_ol_order (recreate FK) and demonstrate deleting an order cascades lines. */
/* Q32. Add table c3_payment_mode(code TEXT PRIMARY KEY, label TEXT UNIQUE NOT NULL). */
/* Q33. Add table c3_payment(
         payment_id SERIAL PRIMARY KEY,
         order_id INT REFERENCES daily.c3_order_header(order_id) ON DELETE CASCADE,
         mode TEXT REFERENCES daily.c3_payment_mode(code),
         amount NUMERIC(10,2) CHECK (amount > 0)
       ); */
/* Q34. Insert payments and attempt amount = 0 to confirm CHECK failure. */
/* Q35. Add NOT NULL to c3_customer.email in a safe way (backfill concept: comment steps, then ALTER). */
/* Q36. Add DEFAULT CURRENT_DATE to c3_order_header.order_date if not present and verify. */
/* Q37. Add composite UNIQUE on (order_id, product_id) in c3_order_line using an extra constraint; test duplicate product in same order. */
/* Q38. Create c3_staff(staff_code TEXT PRIMARY KEY, role TEXT CHECK (role IN ('Analyst','Manager','Clerk'))). */
/* Q39. Create c3_staff_assignment(
         staff_code TEXT REFERENCES daily.c3_staff(staff_code),
         order_id INT REFERENCES daily.c3_order_header(order_id),
         CONSTRAINT pk_sa PRIMARY KEY(staff_code, order_id)
       ); */
/* Q40. Insert assignments; try a duplicate PK to see violation. */
/* Q41. Add FK from c3_dim_branch.region_code to c3_dim_region.region_code if missing; test ON UPDATE CASCADE by changing a region_code. */
/* Q42. Add CHECK on c3_order_line to ensure qty <= 1000; test with 5000 (expect failure). */
/* Q43. Mark all FK constraints in c3_order_line as DEFERRABLE INITIALLY DEFERRED (recreate as needed). */
/* Q44. Wrap a multi-table insert in BEGIN; SET CONSTRAINTS ALL DEFERRED; ... COMMIT; and verify. */
/* Q45. Add UNIQUE on c3_payment_mode.label; test duplicates. */
/* Q46. Add CHECK on c3_customer.country to allow only ('IN','US','UK'); test failure with 'ZZ'. */
/* Q47. Add DEFAULT 1.00 to c3_payment.amount then insert row without amount to verify. */
/* Q48. Create c3_address(
         addr_id SERIAL PRIMARY KEY,
         customer_id INT REFERENCES daily.c3_customer(customer_id) ON DELETE CASCADE,
         city TEXT NOT NULL CHECK (city <> '')
       ); */
/* Q49. Delete a customer and confirm cascading delete to addresses. */
/* Q50. Query information_schema to list all constraints on c3_* tables (name, type, table). */
/* Q51. Query referential actions for all FKs from information_schema.referential_constraints. */
/* Q52. List all CHECK constraints and their expressions for c3_* tables. */
/* Q53. Verify which constraints are deferrable using information_schema.table_constraints. */
/* Q54. Show columns that have DEFAULTs in c3_* tables via information_schema.columns. */
/* Q55. Show columns declared NOT NULL across c3_* tables. */
/* Q56. Demonstrate TRUNCATE c3_order_line RESTRICT failing when referenced by FK (comment result). */
/* Q57. Demonstrate TRUNCATE ... CASCADE on c3_order_header and explain effects (comment). */
/* Q58. Document (comment) when ON DELETE SET NULL would be safer than CASCADE here. */
/* Q59. Document (comment) rollback plan if any FK violation occurs mid-load. */
/* Q60. Document (comment) a pre-load validation checklist (counts, null checks, uniqueness checks). */

/* ============================================================
   🚀 SECTION C: PRACTICAL TRANSACTIONAL ONBOARDING & UPSERTS (40)
   (Use staging tables, complex ON CONFLICT, and idempotent patterns.)
   ------------------------------------------------------------ */
/* Q61. Create staging c3_stg_customer(email TEXT, country TEXT, city TEXT). */
/* Q62. Insert 8 rows containing duplicates on (email,country) and some NULL city. */
/* Q63. Upsert into c3_customer(email, country, city)
        ON CONFLICT (email, country)
        DO UPDATE SET city = COALESCE(EXCLUDED.city, c3_customer.city); */
/* Q64. Verify rows updated only when city provided. */
/* Q65. Create staging c3_stg_product(sku TEXT, price NUMERIC(10,2)). */
/* Q66. Insert 10 rows including duplicate skus and one negative price. */
/* Q67. Upsert into c3_product(sku, price) with ON CONFLICT (sku) DO UPDATE SET price = GREATEST(EXCLUDED.price, 0); */
/* Q68. Verify negative price corrected to 0 by upsert rule. */
/* Q69. Create staging c3_stg_order_header(customer_id INT, order_date DATE). */
/* Q70. Create staging c3_stg_order_line(order_id INT, line_no INT, product_id INT, qty INT). */
/* Q71. Begin a transaction; SET CONSTRAINTS ALL DEFERRED; insert order_lines first, then headers; commit successfully. */
/* Q72. Verify referential integrity holds after commit. */
/* Q73. Re-run the same transaction to confirm idempotency (should not duplicate headers when using PKs). */
/* Q74. Create staging c3_stg_payment(order_id INT, mode TEXT, amount NUMERIC(10,2)). */
/* Q75. Insert duplicates for same order_id with different amounts. */
/* Q76. Upsert into c3_payment(order_id, mode, amount)
        ON CONFLICT (order_id) DO UPDATE SET amount = EXCLUDED.amount; */
/* Q77. Verify latest amount is reflected. */
/* Q78. Create staging c3_stg_branch(branch_code TEXT, region_code TEXT). */
/* Q79. Insert branches referencing both existing and future (not yet inserted) regions. */
/* Q80. Perform a deferred transactional load that inserts branches first then regions; commit. */
/* Q81. Create staging c3_stg_address(customer_id INT, city TEXT). */
/* Q82. Insert addresses including one invalid customer_id. Attempt insert and show FK failure; fix and retry. */
/* Q83. Upsert c3_payment_mode(code,label) with conflicting code to update only label (DO UPDATE). */
/* Q84. Upsert c3_order_line(order_id,line_no,product_id,qty)
        ON CONFLICT (order_id,line_no) DO UPDATE SET product_id = EXCLUDED.product_id, qty = EXCLUDED.qty; */
/* Q85. Demonstrate preventing regression updates by only updating when EXCLUDED.qty > c3_order_line.qty (concept: add WHERE clause in upsert). */
/* Q86. Wrap a full mini-pipeline in one transaction: customers → products → headers → lines → payments; use deferrable FKs. */
/* Q87. After commit, verify counts against staging tables (simple COUNT comparisons). */
/* Q88. Attempt to delete a product referenced by lines with CASCADE enabled; verify cascade. */
/* Q89. Attempt to delete a customer referenced by addresses with CASCADE enabled; verify cascade. */
/* Q90. Add CHECK to c3_payment ensuring amount <= 100000; test upsert of amount 200000 (should fail). */
/* Q91. List all constraint names that failed at least once during exercises (comment your observations). */
/* Q92. Show all constraints for daily schema via information_schema.table_constraints filtered by c3_. */
/* Q93. Show FK actions (update/delete rules) for c3_ FKs. */
/* Q94. Show which constraints are deferrable vs immediate. */
/* Q95. Document an idempotent rerun strategy if a batch partially succeeded (comments). */
/* Q96. Document a backout plan to restore pre-load state (comments). */
/* Q97. Document guard-rails to prevent accidental TRUNCATE/DELETE in production (comments). */
/* Q98. Document which upserts chose DO NOTHING vs DO UPDATE and why (comments). */
/* Q99. Provide a post-load validation checklist (nulls, keys, referential integrity) in comments. */
/* Q100. Provide a final status summary template (rows read/inserted/updated/skipped) as comments. */

/* ============================================================
   ✅ END OF DAY 3 — CRAZY HARD LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Use transactions and deferred constraints thoughtfully.
   - Keep DDL/DML in acciojob.daily; retailmart only for read-only checks.
   - Comment expected failures and learnings for each guarded test.
============================================================ */
