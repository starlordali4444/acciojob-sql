# 🎓 SQL Curriculum: Batch 26+ (RetailMart V3 Edition)

| **Parameter**      | **Details**                                                                       |
| :----------------- | :-------------------------------------------------------------------------------- |
| **Scope**          | 30 topic sessions (~60 hours)                                                      |
| **Pace**           | Core topics taught live first; advanced topics are self-practice                   |
| **Session Length** | 2 hours per session                                                               |
| **Total Hours**    | ~60 hours                                                                         |
| **Platform**       | PostgreSQL 18, pgAdmin 4, VS Code                                                 |
| **Database**       | **RetailMart V3** (16 Schemas, 55 Tables)                                         |
| **Audience**       | Aspiring **data analysts and data scientists**                                    |
| **Philosophy**     | Teach the 80/20 of analyst SQL. Use freed time for deep, repeated practice.       |
| **Target outcome** | Graduate goes from **scratch to ~2 years of experience** — can hold their own with working analysts/data scientists. |

---

## 🗂️ Session shape (per topic)

- **~40 min** — concept teaching (1–3 topics max)
- **~90 min** — practice block: **minimum 4 problems per topic**, escalating difficulty
- **~10 min** — wrap, recap, preview the next topic

## 🔒 Database usage rule

- **RetailMart V3 is read-only for data**: students never `INSERT`, `UPDATE`, `DELETE`, or `ALTER` RetailMart base tables. This mirrors real analyst work — analysts query the warehouse, they don't mutate it.
- **All DDL/DML practice happens in the student's own practice DB** (`accio_<batch_no>`).
- **Allowed on RetailMart** (non-data-mutating, analyst-relevant):
  - `CREATE INDEX` — analysts tune their own queries.
  - `CREATE VIEW` and `CREATE MATERIALIZED VIEW` in `analytics_schema` — the capstone deliverable.
- Each student runs their own local PostgreSQL with their own RetailMart copy, so these exceptions are safe.

---

## 🟡 Core vs. Advanced (self-practice) topics

The **core** topics — *Introduction to SQL* through *Database Concepts & Review* (the analyst 80/20) — should be mastered.

These **advanced / self-practice** topics are covered live **only if the batch is ahead of schedule**, otherwise they're yours to work through independently and safe to skip without falling behind: **Indexing, Pivoting & FILTER, Useful Aggregation Patterns (Median/P95/DISTINCT ON), Date/Time Mastery, JSON & Semi-Structured Data, Data Quality & Deduplication, Cohort/RFM/Funnel, and Review & Interview Prep.** Full practice sets + answer keys are provided for every one of them — nothing is cut, you just drive the pace.

*(Query-plan reading and Views & Materialized Views stay in the taught core — they feed the capstone.)*

---

## Foundations & Setup
**Goal**: Understand databases, get tools running, learn to build tables with proper types and constraints, and start manipulating data.

### Introduction to SQL & Databases
- **Topics**: What is data? Data vs Information. Roles that use SQL (Data Analyst, Data Engineer, Data Scientist, etc.). Skills matrix (Excel, SQL, Python, Power BI). DBMS vs RDBMS. Types of databases. What is a table, schema, database. SQL components overview (DDL, DML, DCL, TCL). SQL as a declarative language. The Amazon warehouse analogy.
- **Activity**: Conceptual walkthrough — no installation yet. At the end of class, share the setup link so students can start downloading PostgreSQL, pgAdmin 4, VS Code, and Git before the next session.

### Installation & RetailMart Onboarding
- **Topics**: PostgreSQL architecture (server/client model). Installing PostgreSQL 18, pgAdmin 4, VS Code, Git Bash. Connecting to the server. What is psql.
- **Lab 1**: Complete installation on student machines (Mac: `install_mac.sh` / Windows: step-by-step). Verify `psql --version`, `git --version`, `code --version`.
- **Lab 2**: Import RetailMart V3 via `setup_accio_retailmart.sql`. Connect in pgAdmin & psql.
- **Activity**: Tour of RetailMart V3 — list all 16 schemas, count tables per schema, explore `sales.orders`, `customers.customers`, `products.products`. Run first queries: `SELECT count(*)`, `SELECT * ... LIMIT 5`, `SELECT version()`.

### DDL & Data Types
- **Topics**: `CREATE DATABASE`, `CREATE SCHEMA`, `CREATE TABLE`, `DROP`, `ALTER TABLE`. Data types: `INT`, `SERIAL`, `BIGSERIAL`, `NUMERIC` (money), `VARCHAR`, `TEXT`, `TIMESTAMP`, `DATE`, `BOOLEAN`. Brief intro: `JSONB`, `UUID`. Choosing the right type for each column.
- **Lab** (in practice DB): Build `accio_<batch_no>` from scratch — design and create 3 tables with correct data types, justified per column. Reference RetailMart table definitions as examples.
- **Practice (4)** (all in practice DB): Create a table with intentionally wrong types and fix them; add/rename/drop columns with `ALTER TABLE`; design a `surveys` table choosing correct types; spot wrong type usages in a sample DDL.

### Constraints, Keys & DML
- **Topics**: `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `DEFAULT`, `NOT NULL`. `CASCADE` vs `RESTRICT`. `INSERT INTO`, `UPDATE`, `DELETE`, `TRUNCATE`.
- **Lab** (in practice DB): Add constraints to the tables from the DDL & Data Types topic — PK, FK relationships, CHECK rules. Then populate them with `INSERT`, modify with `UPDATE`, remove with `DELETE`.
- **Practice (4)** (all in practice DB): Add a `CHECK(price > 0)` and try violating it; add `ON DELETE CASCADE` between two tables and observe the effect; `INSERT` 10 rows, `UPDATE` a subset, `DELETE` with a `WHERE` condition; intentionally break a FK insert and read the error message.

### Filtering & Sorting
- **Topics**: `SELECT`, `WHERE`, `AND`/`OR`/`NOT`, `LIKE`/`ILIKE`, `BETWEEN`, `IN`, `IS NULL`, `ORDER BY`, `LIMIT`/`OFFSET`.
- **Practice (6)**: Gmail customers via `LIKE`; orders in date range via `BETWEEN`; multi-condition with `OR`/`AND` precedence; pagination (page 3, 20/page); NULL handling on `customers.phone`; top 10 most expensive products.

---

## Querying & Aggregation
**Goal**: Master filtering, scalar functions, grouping, and basic joins. Practice-heavy week.

### Scalar Functions (String & Date)
- **Topics**: `UPPER`, `LOWER`, `LENGTH`, `SUBSTRING`, `TRIM`, `CONCAT`, `REPLACE`, `POSITION`. `NOW()`, `EXTRACT`, `DATE_TRUNC`, `TO_CHAR`, interval arithmetic.
- **Practice (6)**: Proper-case customer names; mask phone numbers; extract domain from email; orders by month using `DATE_TRUNC`; "days since last order" using interval math; format `created_at` as `DD-Mon-YYYY`.

### Conditional Logic & Derived Columns
- **Topics**: `CASE WHEN`, `COALESCE`, `NULLIF`, `CAST` / `::`.
- **Practice (5)**: Segment customers VIP/Regular/New by order count; `COALESCE` missing `return_reason`; bucket order amounts into Small/Med/Large; `NULLIF` to avoid divide-by-zero in margin calc; cast a `VARCHAR` date to `DATE` and filter.

### Aggregate Functions & Grouping
- **Topics**: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `STRING_AGG`. `GROUP BY` mechanics, `HAVING` vs `WHERE`.
- **Practice (6)**: Total revenue by region; avg order value per store; stores with > ₹1M revenue (`HAVING`); customers with ≥ 5 orders; product names per category as a comma list (`STRING_AGG`); top 10 categories by item count.

### Joins Part 1 (Foundations)
- **Topics**: `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`. Join keys, ambiguity, aliasing.
- **Practice (6)**: Orders with customer names; products never ordered (`LEFT JOIN`); orders missing a shipment record; employees with their store name; categories with their parent category; customer order count including zero-order customers.

### Joins Part 2 (Advanced)
- **Topics**: `FULL OUTER JOIN`, multi-table joins (4–5 tables), join order intuition.
- **Practice (5)**: Full supply-chain trace `orders → shipments → warehouses → inventory`; unsold inventory; orders + customer + product + store in one row; reconcile two systems via `FULL OUTER JOIN`; rewrite a 3-table inner join three different ways.

---

## Advanced Joins, Subqueries & CTEs
**Goal**: Multi-table reasoning, query nesting, and the database-concepts foundation analysts get asked about in interviews.

### Self Join & UNION
- **Topics**: `SELF JOIN` for hierarchies; `UNION` / `UNION ALL`.
- **Practice (4)**: Employee–manager hierarchy; pairs of products in the same category; union of `audit.application_logs` + `audit.api_requests` into one feed; `UNION` vs `UNION ALL` performance comparison.

### Subqueries Part 1
- **Topics**: Scalar subqueries, multi-row subqueries with `IN`, subqueries in `SELECT` and `FROM`.
- **Practice (5)**: Products cheaper than category average; customers above the global avg spend; subquery in `SELECT` for "orders this month per customer"; rewrite an `IN`-subquery as a JOIN; spot the bug — subquery returning multiple rows where scalar expected.

### Subqueries Part 2 (Correlated, EXISTS) & CTEs
- **Topics**: Correlated subqueries, `EXISTS` / `NOT EXISTS`, basic `WITH` (CTEs).
- **Practice (4)**: Customers with at least one return; products never bought via `NOT EXISTS`; CTE-based churn (no order in 6 months); refactor a 3-level nested subquery into chained CTEs.

### Database Concepts for Analysts (Normalization, ACID, Transactions)
- **Topics**: Concept-level only — no procedural code, no hands-on locking.
  - **Normalization**: 1NF, 2NF, 3NF with examples; functional dependencies; why source schemas look the way they do; denormalization tradeoffs (when derived totals on `orders` are correct).
  - **ACID**: Atomicity, Consistency, Isolation, Durability — what each one means in plain English with one example each.
  - **Transactions**: `BEGIN`, `COMMIT`, `ROLLBACK` — concept and basic syntax. Why a long analytics SELECT is implicitly inside a transaction. PostgreSQL default isolation = `READ COMMITTED` (one-line awareness).
- **Lab**: Audit RetailMart — identify which tables are 3NF and which keep derived/denormalized fields, and explain why each choice was made.
- **Practice (4)**: Spot the 1NF / 2NF / 3NF violation in three sample tables; design a many-to-many junction table for a hypothetical RetailMart relationship; argue for/against denormalizing a specific RetailMart table; rank the 4 ACID properties by which most affects an analyst's daily work and explain.

### Mixed Review & Practice
- **Activity**: Mixed-difficulty practice covering everything from foundations through CTEs. No new concepts — pure reinforcement.
- **Practice (8)**: Multi-table join with filtering and aggregation; CTE that chains filtering → grouping → ranking; subquery vs JOIN rewrite challenge; `CASE WHEN` inside an aggregate with `GROUP BY`; `EXISTS` combined with date filtering; self-join with aggregation; `UNION ALL` with consistent column types; debug a broken query (find and fix 3 errors).

---

## Window Functions & Performance
**Goal**: Analytics queries plus understanding why queries are slow.

### Window Functions Part 1 (Ranking & Bucketing)
- **Topics**: `OVER()`, `PARTITION BY`, `ORDER BY` inside a window. `ROW_NUMBER`, `RANK`, `DENSE_RANK`. **`NTILE`** for quartile / decile / percentile bucketing (used later in RFM). Top-N per group pattern.
- **Practice (7)**: Top 3 highest-paid employees per department; rank products within each category by sales; deduplicate `customers` keeping latest record per email; "second highest" salary; rank stores by revenue per region; ROW_NUMBER vs RANK vs DENSE_RANK side-by-side on tied data; `NTILE(4)` to bucket customers into spend quartiles.

### Window Functions Part 2 (Aggregation, Frames)
- **Topics**: `SUM() OVER`, `AVG() OVER`, running totals, moving averages, window frame syntax (`ROWS BETWEEN ...`).
- **Practice (6)**: Cumulative revenue by month; 7-day moving avg of orders; running total of expenses per department; % of category total per product; rolling 30-day customer count; reset running total at year boundary.

### Window Functions Part 3 (LAG/LEAD)
- **Topics**: `LAG`, `LEAD`. Period-over-period analysis.
- **Practice (6)**: Month-over-month revenue growth %; gap between consecutive orders per customer; detect price changes from a price-history source; first-vs-second order time delta; web session duration from `web_events` using `LAG`; flag rows where today's value > yesterday's by > 20%.

### Reading Query Plans (Analyst Lens)
- **Topics**: `EXPLAIN`, `EXPLAIN ANALYZE`. Reading a plan: Seq Scan vs Index Scan vs Bitmap, Nested Loop vs Hash Join, cost vs actual time, estimated vs actual rows. Common slow patterns *analysts* hit: `SELECT *` on wide tables, leading wildcard `LIKE`, function-on-column in `WHERE`, missing `LIMIT` on exploration queries.
- **Practice (5)**: Read a plan and identify the bottleneck; rewrite `WHERE UPPER(email) = ...` to be sargable; replace `SELECT *` in a wide-table query; spot the missing `LIMIT`; compare plan before/after rewriting an `OR` as `UNION ALL`.

### Indexing for Analysts (Hands-On)

> 🟡 **Advanced / self-practice** — taught live only if time permits; otherwise practice on your own. Safe to skip to stay on pace.
- **Topics**: What an index is and how it speeds reads. **B-Tree** (the default — covers `=`, `<`, `>`, `BETWEEN`, `ORDER BY`). **Composite indexes** (column order matters — leftmost-prefix rule). **Partial indexes** (WHERE-clause-bound, useful for "active" rows). `CREATE INDEX` syntax + `CREATE INDEX CONCURRENTLY` (concept). Reading whether your query *uses* an index from `EXPLAIN`. When indexing helps vs. when it doesn't (full-table aggregates).
- **Lab**: Pick a slow analyst query on RetailMart, run `EXPLAIN ANALYZE`, add the right `CREATE INDEX`, re-run, measure speedup, inspect the new plan.
- **Practice (6)**: Add a single-column B-Tree index and measure before/after; choose composite column order for a 2-predicate query and verify with `EXPLAIN`; create a partial index for `WHERE status = 'active'` and confirm it's used; identify a redundant index on a sample table; identify a query where indexing won't help (full aggregate); inventory existing indexes on `sales.orders` via `pg_indexes`.

---

## Analytics Power Tools
**Goal**: The SQL patterns analysts and data scientists write every day — pivots, useful aggregates, time-series, semi-structured data, and views as the analyst's delivery format.

### Pivoting, Unpivoting & FILTER Clause

> 🟡 **Advanced / self-practice** — taught live only if time permits; otherwise practice on your own. Safe to skip to stay on pace.
- **Topics**: Pivoting with `CASE WHEN` inside aggregates ("conditional aggregation"). The cleaner `FILTER (WHERE ...)` clause. Unpivoting with `UNION ALL` or `unnest`. When to pivot in SQL vs leave it for the BI tool.
- **Lab**: Build a pivoted "category × month" revenue matrix from `sales.order_items`.
- **Practice (6)**: Revenue by month with one column per `payment_mode` using `FILTER`; count of orders by region with one column per status; pivot employees by department, columns are tenure buckets; unpivot a wide quarterly KPI table into long format; pivot returning a percent-of-row-total; pivot order-count by week with one column per status bucket.

### Useful Aggregation Patterns (Median, Latest-Per-Group)

> 🟡 **Advanced / self-practice** — taught live only if time permits; otherwise practice on your own. Safe to skip to stay on pace.
- **Topics**: `PERCENTILE_CONT` for **median** and **P90 / P95** — treat it like `AVG`, just one new function. `DISTINCT ON` for "latest record per group" — a very common analyst need. Reinforcement of pivoting from the Pivoting & FILTER topic.
- **Lab**: Build an "executive KPI strip" using median order value and P95 order value per region.
- **Practice (5)**: Median and P95 order value per region; median delivery time per warehouse; `DISTINCT ON` to get the latest order per customer; `DISTINCT ON` to get the most-recent price per product; combine `PERCENTILE_CONT` with a pivot from the Pivoting topic (median revenue per region × per quarter).

### Date/Time Mastery for Time-Series Analytics

> 🟡 **Advanced / self-practice** — taught live only if time permits; otherwise practice on your own. Safe to skip to stay on pace.
- **Topics**: `DATE_TRUNC`, `EXTRACT`, interval arithmetic. **Generating date dimensions** with `generate_series`. **Gap-filling**: `LEFT JOIN` against a date series to get zeros for missing days. Fiscal calendar handling. Time bucketing (hourly / daily / weekly / monthly). Timezone awareness with `TIMESTAMPTZ`.
- **Lab**: Build a "complete daily revenue" report — one row per day for the last 90 days, zero where there's no order.
- **Practice (6)**: Generate a date dimension table covering 2020–2030 with `day_of_week`, `week_num`, `month_name`, `fiscal_quarter`; gap-fill a sparse weekly metric; build a "first 30 days" cohort timeline per customer; convert UTC timestamps to IST and bucket by hour-of-day; revenue by ISO week (with year-week boundary correctness); count orders in 15-minute buckets to find peak shopping hour.

### JSON & Semi-Structured Data

> 🟡 **Advanced / self-practice** — taught live only if time permits; otherwise practice on your own. Safe to skip to stay on pace.
- **Topics**: `JSONB` operators: `->`, `->>`, `#>`, `#>>`, `@>`, `?`. `jsonb_array_elements` for unnesting arrays. `jsonb_path_query` (concept). When source data arrives as nested JSON (event streams, API exports). Flattening nested JSON into rows.
- **Lab**: Parse a JSONB payload column from the audit schema to extract method, status_code, latency, and user_agent into typed columns.
- **Practice (5)**: Extract a top-level field from a JSONB column and aggregate; filter rows where a JSON field equals a value; unnest a JSON array column into one row per element; group by a nested JSON field; cast extracted JSONB values to `NUMERIC` for math.

### Views & Materialized Views (Analyst's Delivery Format)
- **Topics**: `CREATE VIEW` for sharing tested logic with the team; layered views (raw → cleaned → metrics). `CREATE MATERIALIZED VIEW` for expensive analytics. `REFRESH MATERIALIZED VIEW [CONCURRENTLY]` and the unique-index requirement. View vs MV decision: data freshness vs query speed. Cascading dependencies (`DROP ... CASCADE` trap).
- **Lab**: Build a 3-layer view stack: `v_orders_clean` → `v_orders_enriched` → `mv_monthly_revenue_kpis`.
- **Practice (5)**: View that joins 4 tables and applies cleaning rules; convert a slow analytics query into an MV; MV with concurrent refresh + the required unique index; schedule a refresh strategy (daily vs hourly tradeoffs); track which views depend on a base view before dropping it.

---

## Analyst Patterns, Interview Prep & Capstone
**Goal**: Analyst patterns (data quality, cohort/RFM), interview review woven into capstone, then a 2-part capstone showcase.

### Data Quality, Deduplication & Cleansing

> 🟡 **Advanced / self-practice** — taught live only if time permits; otherwise practice on your own. Safe to skip to stay on pace.
- **Topics**: Finding duplicates with `GROUP BY ... HAVING COUNT(*) > 1` and with `ROW_NUMBER`. **Deduping while keeping the right record** using `ROW_NUMBER OVER (PARTITION ... ORDER BY ...)`. NULL strategies: `COALESCE`, `NULLIF`, `IS DISTINCT FROM`. Simple anomaly flags: thresholds, percentage changes (e.g. "> 50% price jump"), missing-value clusters. Regex basics with `~` and `~*` for pattern matching. Standardizing free-text (`LOWER`, `TRIM`, `REGEXP_REPLACE`).
- **Lab**: Audit `customers.customers` for data quality — duplicate emails, malformed phone numbers, NULL clusters, suspicious values.
- **Practice (6)**: Find duplicate customers by email and pick the most-recently-active; flag orders whose `gross_total` exceeds a fixed business threshold; detect product price changes > 50% jump (likely data-entry errors); standardize phone numbers to a canonical format with regex; backfill NULL `region` from another column using `COALESCE`; reconcile two near-duplicate product lists by lowercased trimmed name.

### Cohort Analysis, RFM & Funnel Queries

> 🟡 **Advanced / self-practice** — taught live only if time permits; otherwise practice on your own. Safe to skip to stay on pace.
- **Topics**: Cohort tables (signup month × months-since-signup retention grid). RFM (Recency, Frequency, Monetary) segmentation with `NTILE`. Funnel queries: counting users at each step, drop-off rates. CLV (customer lifetime value) calculation. Period-over-period growth tables.
- **Lab**: Build a customer cohort retention matrix for `customers.customers` joined to `sales.orders`.
- **Practice (6)**: Monthly signup-cohort retention grid (months 0–6); RFM scoring tagging customers Champions / Loyal / At-Risk / Lost; signup → first-order → second-order funnel with conversion %; CLV per acquisition channel; "stickiness" metric (DAU/MAU ratio) by week from `web_events`; product-category cross-purchase matrix.

### Review & Interview Prep

> 🟡 **Advanced / self-practice** — taught live only if time permits; otherwise practice on your own. Safe to skip to stay on pace.
- **Interview-style review** (rapid-fire mixed problems):
  1. Top-N per group (window function refresher).
  2. Month-over-month growth % (LAG).
  3. Customer cohort retention table (CTE + pivot).
  4. Find duplicates and dedupe keeping latest (`ROW_NUMBER`).
  5. `EXISTS` vs `IN` rewrite question.
  6. Median + P95 per group (`PERCENTILE_CONT`).
  7. Pivot using `FILTER` clause.
  8. Read an `EXPLAIN ANALYZE` plan and identify the bottleneck.
- **Explain-your-query drill**: Each student picks a query from the course, walks through it line-by-line as if explaining to an interviewer.
- **Practice (6)**: Mixed difficulty problems covering all major topics from Weeks 1–5.

### Capstone Part 1: Analytics Layer & JSON Export
- **Setup**: `analytics_schema`, metadata tables, indexes for the analytics views.
- **Core modules** (views + materialized views):
  - **Sales**: monthly trends, MoM/YoY growth, payment-mode mix, day-of-week patterns.
  - **Customer**: RFM segmentation, CLV, cohort retention.
  - **Product**: top products, ABC/Pareto, category performance.
- **Advanced modules** (V3 schemas):
  - **Store & Finance**: profitability, vendor payments, budget vs actual.
  - **Supply Chain**: SLA tracking with `logistics.shipments`, warehouse turnover, return-rate by category.
  - **Audit & Behavior**: error rates from `audit.application_logs`, API performance from `audit.api_requests`, web-funnel from `web_events`.
- **Automation**: `refresh_all.sh` shell script running `REFRESH MATERIALIZED VIEW ...` in dependency order.
- **JSON export**: `export_all_json.sh` running per-module `json_agg` queries → one JSON file per module under `dashboard/data/`.
- **Deliverable end of day**: 15+ views, 6+ MVs, refresh script, JSON files ready to feed the dashboard.

### Capstone Part 2: Dashboard Build, GitHub Pages Deploy & Demo
- **Dashboard build** (instructor-supplied starter HTML + Chart.js boilerplate; students wire it to their JSON):
  - 8 tabs (Executive / Sales / Customers / Products / Stores / Finance / Audit / Operations).
  - Each tab pulls from its module's JSON file and renders the relevant Chart.js charts + KPI cards.
  - Auto-refresh, dark mode, responsive grid.
- **GitHub Pages deploy**:
  - `git init` the `dashboard/` folder, push to a public repo.
  - Enable GitHub Pages → live URL.
  - Verify the deployed dashboard reads the JSON correctly.
- **Demo & presentation** (10–15 min per student):
  - Live walkthrough of the deployed GitHub Pages URL.
  - Brief explanation of 1–2 technical highlights (CTE / window function / pivot / MV / cohort / RFM logic).
  - One business insight from the data: "what would I tell the CEO?"
  - Q&A.
- **Wrap**: course retrospective, share GitHub Pages URLs as portfolio pieces, next-steps guidance.

---

## 📊 Practice problem totals

| Topic group                                  | Problems       |
| :------------------------------------------- | :------------: |
| Foundations & Setup                          | 20             |
| Querying & Aggregation                       | 28             |
| Advanced Joins, Subqueries & CTEs            | 27             |
| Window Functions & Performance               | 30             |
| Analytics Power Tools                        | 27             |
| Analyst Patterns, Interview Prep & Capstone  | 24 + capstone  |

**Total: ~156 hands-on problems + a 2-part capstone (build + showcase).**
