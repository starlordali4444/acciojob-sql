/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 3 (HARD LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Data Onboarding + Constraints & Keys + UPSERT (Advanced)
   Scope:
     - Advanced constraint management (composite, multi-FK, nested dependencies)
     - UPSERT chains, multi-table data integrity
     - ON DELETE / ON UPDATE actions across multiple tables
     - Use acciojob.daily for all DDL/DML, retailmart only for read-only SELECT
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (20)
   ------------------------------------------------------------ */
/* Q1. What are the challenges of onboarding data when multiple foreign keys exist between tables? */
/* Q2. How can cascading actions simplify or complicate data deletion? */
/* Q3. When would you choose ON UPDATE SET NULL instead of CASCADE? */
/* Q4. Why must indexes support unique constraints for performance? */
/* Q5. How does PostgreSQL internally enforce uniqueness constraints? */
/* Q6. What is a DEFERRABLE constraint, and why might you use it during onboarding? */
/* Q7. Explain the difference between immediate and deferred constraint checking. */
/* Q8. Can a foreign key reference another table in a different schema? */
/* Q9. What are self-referencing foreign keys? Give an example. */
/* Q10. What is the difference between TRUNCATE CASCADE and DELETE CASCADE? */
/* Q11. How does PostgreSQL prevent circular foreign key references? */
/* Q12. What happens if a referenced table is dropped without dropping dependent FKs? */
/* Q13. Why should you validate data before enabling constraints? */
/* Q14. How does ON CONFLICT DO UPDATE help incremental data ingestion? */
/* Q15. When might you need conditional updates inside an UPSERT statement? */
/* Q16. Why should primary key design align with business identifiers? */
/* Q17. What is the risk of using natural keys instead of surrogate keys? */
/* Q18. Explain how partial unique indexes differ from full unique constraints. */
/* Q19. When should you drop and recreate constraints rather than altering them? */
/* Q20. Why should onboarding be tested in a transaction block before committing? */

/* ============================================================
   🔒 SECTION B: ADVANCED CONSTRAINTS & KEYS (40)
   ------------------------------------------------------------ */
/* Q21. Create table h3_departments(
         dept_id SERIAL PRIMARY KEY,
         dept_name TEXT UNIQUE NOT NULL
       ). */
/* Q22. Create table h3_employees(
         emp_id SERIAL PRIMARY KEY,
         emp_code TEXT UNIQUE NOT NULL,
         emp_name TEXT NOT NULL,
         dept_id INT REFERENCES daily.h3_departments(dept_id) ON DELETE SET NULL ON UPDATE CASCADE
       ). */
/* Q23. Insert 3 departments and 5 employees distributed among them. */
/* Q24. Update one dept_id to test cascading effect on employees. */
/* Q25. Create table h3_projects(
         project_id SERIAL PRIMARY KEY,
         project_code TEXT UNIQUE NOT NULL,
         dept_id INT REFERENCES daily.h3_departments(dept_id) ON DELETE CASCADE
       ). */
/* Q26. Insert 3 projects linked to departments. */
/* Q27. Delete one department and check cascading delete for related projects. */
/* Q28. Create table h3_roles(
         role_code TEXT PRIMARY KEY,
         role_label TEXT UNIQUE
       ). */
/* Q29. Create table h3_assignments(
         emp_id INT REFERENCES daily.h3_employees(emp_id),
         role_code TEXT REFERENCES daily.h3_roles(role_code),
         assigned_on DATE DEFAULT CURRENT_DATE,
         PRIMARY KEY(emp_id, role_code)
       ). */
/* Q30. Insert 5 employee-role assignments. */
/* Q31. Attempt duplicate emp_id + role_code (expect PK failure). */
/* Q32. Create table h3_clients(
         client_id SERIAL PRIMARY KEY,
         client_name TEXT UNIQUE NOT NULL,
         city TEXT CHECK (city <> '')
       ). */
/* Q33. Insert 3 clients. */
/* Q34. Create table h3_contracts(
         contract_id SERIAL PRIMARY KEY,
         client_id INT REFERENCES daily.h3_clients(client_id) ON DELETE RESTRICT,
         project_id INT REFERENCES daily.h3_projects(project_id) ON DELETE SET NULL
       ). */
/* Q35. Insert 3 contracts linking clients to projects. */
/* Q36. Attempt deleting a client linked to a contract (expect FK restriction). */
/* Q37. Create table h3_pay_modes(code TEXT PRIMARY KEY, label TEXT UNIQUE NOT NULL). */
/* Q38. Insert 3 payment modes. */
/* Q39. Create table h3_payments(
         pay_id SERIAL PRIMARY KEY,
         contract_id INT REFERENCES daily.h3_contracts(contract_id),
         mode TEXT REFERENCES daily.h3_pay_modes(code),
         amount NUMERIC(10,2) CHECK (amount > 0)
       ). */
/* Q40. Insert payments and validate constraints. */
/* Q41. Alter h3_payments add DEFAULT 100 for amount. */
/* Q42. Test insert without amount to confirm default applies. */
/* Q43. Alter h3_contracts add UNIQUE constraint on (client_id, project_id). */
/* Q44. Insert duplicate client-project combination (expect failure). */
/* Q45. Add CHECK constraint on h3_projects to ensure LENGTH(project_code) > 2. */
/* Q46. Try inserting project_code='A' to see failure. */
/* Q47. Alter h3_employees add CHECK(emp_name <> '') to ensure valid names. */
/* Q48. Attempt inserting blank emp_name (expect failure). */
/* Q49. Create table h3_supplier_rating(supplier_id SERIAL PRIMARY KEY, rating INT CHECK (rating BETWEEN 1 AND 10)). */
/* Q50. Insert valid and invalid ratings (comment results). */
/* Q51. Add NOT NULL constraint to h3_clients.city if not already enforced. */
/* Q52. Verify city column cannot accept NULL. */
/* Q53. Add DEFAULT CURRENT_DATE to h3_assignments.assigned_on if not set. */
/* Q54. Add FOREIGN KEY from h3_projects.dept_id referencing h3_departments(dept_id) with ON UPDATE CASCADE. */
/* Q55. Update dept_id in departments to see cascading behavior in projects. */
/* Q56. Drop and recreate foreign key in h3_contracts to use ON DELETE CASCADE. */
/* Q57. Reinsert data and test delete propagation. */
/* Q58. Add composite UNIQUE on (emp_code, dept_id) in h3_employees. */
/* Q59. Try inserting duplicate combination (expect failure). */
/* Q60. Query all constraints from information_schema.table_constraints for h3_ tables. */

/* ============================================================
   🚀 SECTION C: ADVANCED ONBOARDING & UPSERT TASKS (40)
   ------------------------------------------------------------ */
/* Q61. Create staging table h3_stg_employees(emp_code TEXT, emp_name TEXT, dept_id INT). */
/* Q62. Insert 5 rows, including duplicate emp_code. */
/* Q63. Upsert into h3_employees(emp_code, emp_name, dept_id) using ON CONFLICT (emp_code) DO UPDATE SET dept_id = EXCLUDED.dept_id. */
/* Q64. Verify updated department IDs. */
/* Q65. Create staging table h3_stg_clients(client_name TEXT, city TEXT). */
/* Q66. Insert duplicate client_name rows. */
/* Q67. Upsert into h3_clients(client_name, city) using ON CONFLICT (client_name) DO UPDATE SET city = EXCLUDED.city. */
/* Q68. Create staging table h3_stg_contracts(client_id INT, project_id INT). */
/* Q69. Insert 5 rows with one duplicate client_id + project_id pair. */
/* Q70. Upsert into h3_contracts using ON CONFLICT (client_id, project_id) DO NOTHING. */
/* Q71. Verify duplicates ignored. */
/* Q72. Create staging table h3_stg_payments(contract_id INT, mode TEXT, amount NUMERIC(10,2)). */
/* Q73. Insert 5 rows with one duplicate contract_id. */
/* Q74. Upsert into h3_payments(contract_id, mode, amount) ON CONFLICT (contract_id) DO UPDATE SET amount = EXCLUDED.amount. */
/* Q75. Verify updated payment amount. */
/* Q76. Create staging table h3_stg_projects(project_code TEXT, dept_id INT). */
/* Q77. Insert 5 rows, including existing project_code. */
/* Q78. Upsert into h3_projects using ON CONFLICT (project_code) DO NOTHING. */
/* Q79. Verify ignored duplicate. */
/* Q80. Create staging table h3_stg_departments(dept_name TEXT). */
/* Q81. Insert duplicate department name. */
/* Q82. Upsert into h3_departments using ON CONFLICT (dept_name) DO UPDATE SET dept_name = EXCLUDED.dept_name. */
/* Q83. Retrieve all departments to verify upsert result. */
/* Q84. Insert test cascade by deleting dept_id referenced by projects. */
/* Q85. Verify cascade effect on dependent records. */
/* Q86. Query all FK dependencies using information_schema.referential_constraints. */
/* Q87. Retrieve all CHECK constraints for h3_ tables. */
/* Q88. Retrieve all UNIQUE constraints. */
/* Q89. Retrieve all PRIMARY KEYS from information_schema.table_constraints. */
/* Q90. Retrieve all DEFAULTs defined using information_schema.columns. */
/* Q91. Retrieve all constraints for daily schema using information_schema.table_constraints. */
/* Q92. Retrieve PostgreSQL version. */
/* Q93. Retrieve total FK count in acciojob.daily schema. */
/* Q94. Retrieve constraint types for each h3_ table. */
/* Q95. Retrieve ON DELETE/UPDATE actions via information_schema.referential_constraints. */
/* Q96. Retrieve list of all columns with CHECK constraints. */
/* Q97. Retrieve columns that have defaults using information_schema.columns. */
/* Q98. Retrieve all schema names using current_schema() and search_path. */
/* Q99. Comment your strategy for validating onboarding before constraint enabling. */
/* Q100. Comment steps for verifying successful cascading deletes during testing. */

/* ============================================================
   ✅ END OF DAY 3 — HARD LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Focus on multi-level constraints, FK cascades, and upsert chains.
   - Keep DDL/DML operations in acciojob.daily only.
   - Document expected constraint violations as comments.
============================================================ */
