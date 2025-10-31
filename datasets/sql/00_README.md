# 🧠 RetailMart SQL Scripts

## 📘 Overview
This folder contains all SQL scripts required to **create** and **load** the RetailMart enterprise database.  
It includes individual schema definitions, bulk CSV loaders, and master orchestration scripts for seamless setup.

---

## 🗂️ Folder Structure
| File | Description |
|------|--------------|
| `retailmart_create_database.sql` | Creates the RetailMart database |
| `core_schema.sql` | Defines shared dimension tables (dim_date, dim_region, etc.) |
| `customers_schema.sql` | Defines customer-related tables and relationships |
| `stores_schema.sql` | Defines store operations, departments, and employees |
| `products_schema.sql` | Defines product catalog, suppliers, inventory, promotions |
| `sales_schema.sql` | Defines orders, order_items, payments, shipments, and returns |
| `finance_schema.sql` | Defines expenses and revenue summary tables |
| `hr_schema.sql` | Defines attendance and salary history tables |
| `marketing_schema.sql` | Defines campaigns, ads spend, and email click tracking |
| `*_load_csv.sql` | Bulk loads CSV files into corresponding schema tables |
| `retailmart_all_schemas_create.sql` | Master script — creates all schemas in correct order |
| `retailmart_all_schemas_load_csv.sql` | Master loader — loads all data from CSVs |

---

## ⚙️ Execution Order (Recommended)

### Step 1 — Create the Database & Schemas
```bash
psql -U postgres -d postgres -f datasets/sql/retailmart_all_schemas_create.sql
```

This script will:
1. Create the `retailmart` database (if not already present)
2. Automatically switch to it (`\c retailmart`)
3. Execute all `*_schema.sql` files in dependency order

✅ **Result:** Database + all schemas and tables created successfully.

---

### Step 2 — Load All Data from CSVs
```bash
psql -U postgres -d retailmart -f datasets/sql/retailmart_all_schemas_load_csv.sql
```

This script will sequentially run all `*_load_csv.sql` files and import CSV data from `datasets/csv/<schema>/` folders.

✅ **Result:** All schemas populated with realistic data from the RetailMart dataset.

---

## 🧩 Schema Dependency Order

| Order | Schema | Depends On | Purpose |
|--------|----------|--------------|----------|
| 1️⃣ | `core` | — | Date, region, category, brand dimensions |
| 2️⃣ | `customers` | `core` | Customer master and reviews |
| 3️⃣ | `stores` | `core` | Store, department, employee data |
| 4️⃣ | `products` | `core`, `stores` | Product, supplier, and inventory data |
| 5️⃣ | `sales` | `customers`, `stores`, `products` | Orders and payments |
| 6️⃣ | `finance` | `sales`, `stores` | Profit and expense tracking |
| 7️⃣ | `hr` | `stores` | Attendance and salary data |
| 8️⃣ | `marketing` | `customers`, `sales` | Campaign and engagement tracking |

---

## 🧹 Common Maintenance Commands

### Drop & Rebuild (for fresh load)
```sql
DROP DATABASE IF EXISTS retailmart;
```
Then re-run:
```bash
psql -U postgres -d postgres -f datasets/sql/retailmart_all_schemas_create.sql
psql -U postgres -d retailmart -f datasets/sql/retailmart_all_schemas_load_csv.sql
```

### Verify after load
```sql
\c retailmart
\dn
SELECT COUNT(*) FROM sales.orders;
```

---

## 💡 Notes
- All SQL paths are **relative to repo root** — always run from `acciojob-sql/` folder.  
- If using pgAdmin or ADS, open scripts manually in the correct order.  
- The dataset was generated via the instructor script:  
  `docs/scripts/build_retailmart_dataset_v4.ipynb`

---

## 🧾 Author & Credits
**Maintained by:** Sayyed Shiraj Ahmad (Ali)  
**Program:** AccioJob Data Analytics — PostgreSQL Track  

> _“Automate the boring SQL — focus on analytics.”_
