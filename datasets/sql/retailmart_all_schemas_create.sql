-- ===============================================================
-- RetailMart Master Schema Creation (Corrected Version)
-- Author: Sayyed Shiraj Ahmad
-- Purpose:
--   1. Create 'retailmart' database if not exists
--   2. Switch to it
--   3. Create all schemas in correct dependency order
-- ===============================================================

\echo '🔹 Creating RetailMart Database'
\i 'datasets/sql/retailmart_create_database.sql'

-- ✅ Switch to new database before creating schemas
\c retailmart

\echo '🔹 Creating Core Schema'
\i 'datasets/sql/core_schema.sql'

\echo '🔹 Creating Customers Schema'
\i 'datasets/sql/customers_schema.sql'

\echo '🔹 Creating Stores Schema'
\i 'datasets/sql/stores_schema.sql'

\echo '🔹 Creating Products Schema'
\i 'datasets/sql/products_schema.sql'

\echo '🔹 Creating Sales Schema'
\i 'datasets/sql/sales_schema.sql'

\echo '🔹 Creating Finance Schema'
\i 'datasets/sql/finance_schema.sql'

\echo '🔹 Creating HR Schema'
\i 'datasets/sql/hr_schema.sql'

\echo '🔹 Creating Marketing Schema'
\i 'datasets/sql/marketing_schema.sql'

\echo '✅ All Schemas Created Successfully in RetailMart!'
