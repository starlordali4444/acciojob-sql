# 📊 RetailMart CSV Dataset

## 📘 Overview
This folder contains the **RetailMart Enterprise Dataset (v4)** in CSV format.  
Each subfolder corresponds to a specific **PostgreSQL schema** — enabling modular loading, clear relationships, and realistic analytics workflows.

All CSVs are generated automatically using the instructor notebook:
`docs/scripts/build_retailmart_dataset_v4.ipynb`

---

## 🗂️ Folder Structure

| Folder | Description | Approx. Rows |
|---------|--------------|---------------|
| `core/` | Core dimension tables (date, region, category, brand) | ~1,000 |
| `customers/` | Customer master, addresses, reviews, loyalty data | ~150,000 |
| `stores/` | Stores, departments, employees, store-level expenses | ~25,000 |
| `products/` | Products, suppliers, inventory, promotions | ~120,000 |
| `sales/` | Orders, order_items, payments, shipments, returns | ~600,000+ |
| `finance/` | Financial summaries, revenue, and expenses | ~40,000 |
| `hr/` | Attendance and salary history for employees | ~150,000 |
| `marketing/` | Campaigns, ad spend, and customer email engagement | ~35,000 |

---

## 🧩 Schema-Wise Details

### 🟦 core/
| File | Description |
|------|--------------|
| `dim_date.csv` | Daily calendar with year, month, and quarter details |
| `dim_region.csv` | State-wise mapping to Indian regions |
| `dim_category.csv` | Product category master list |
| `dim_brand.csv` | Brand and category mapping |

---

### 🟨 customers/
| File | Description |
|------|--------------|
| `customers.csv` | Customer demographic master |
| `addresses.csv` | Billing and shipping addresses |
| `reviews.csv` | Product reviews and ratings |
| `loyalty_points.csv` | Reward points and last update info |

---

### 🟩 stores/
| File | Description |
|------|--------------|
| `stores.csv` | Store master with city, region, and state |
| `departments.csv` | Department reference table |
| `employees.csv` | Employee master with salary and roles |
| `expenses.csv` | Store-level operational expenses |

---

### 🟥 products/
| File | Description |
|------|--------------|
| `suppliers.csv` | Supplier list and IDs |
| `products.csv` | Product master (category, brand, supplier, price) |
| `inventory.csv` | Store-level stock with quantity and last updated date |
| `promotions.csv` | Promotional campaign details |

---

### 🟪 sales/
| File | Description |
|------|--------------|
| `orders.csv` | Customer orders linked to store and customer IDs |
| `order_items.csv` | Item-level details per order |
| `payments.csv` | Payment method and transaction data |
| `shipments.csv` | Shipment tracking and delivery info |
| `returns.csv` | Returned items with reasons and refund amounts |

---

### 🟧 finance/
| File | Description |
|------|--------------|
| `expenses.csv` | Expense records (linked to stores) |
| `revenue_summary.csv` | Monthly aggregated sales vs expense summary |

---

### 🟫 hr/
| File | Description |
|------|--------------|
| `attendance.csv` | Employee daily attendance (P/A/WFH/PL) |
| `salary_history.csv` | Historical salary adjustments |

---

### 🩵 marketing/
| File | Description |
|------|--------------|
| `campaigns.csv` | Campaign names, start/end dates, budgets |
| `ads_spend.csv` | Ad spend per channel with clicks & conversions |
| `email_clicks.csv` | Customer engagement on marketing emails |

---

## 🧠 Data Characteristics
- All data is **synthetic**, generated from curated Indian context JSONs (`docs/json/`)  
- Each table maintains **valid foreign key relationships** across schemas  
- Column naming follows snake_case for SQL consistency  
- Dates span **2022–2025**, covering multi-year business analytics use cases

---

## 🔍 Validation Queries

### Verify Row Counts
```sql
\c retailmart
SELECT COUNT(*) FROM sales.orders;
SELECT COUNT(*) FROM customers.customers;
SELECT COUNT(*) FROM products.products;
```

### Verify Relationships
```sql
SELECT o.order_id, c.full_name, p.prod_name
FROM sales.orders o
JOIN customers.customers c ON o.cust_id = c.cust_id
JOIN products.products p ON p.prod_id < 10
LIMIT 5;
```

### Check Duplicate Constraints
```sql
SELECT store_id, prod_id, COUNT(*)
FROM products.inventory
GROUP BY 1, 2 HAVING COUNT(*) > 1;
```

---

## 💡 Tips for Instructors
- Regenerate datasets anytime via:  
  `docs/scripts/build_retailmart_dataset_v4.ipynb`  
- All CSVs are **UTF-8 encoded** for universal PostgreSQL compatibility  
- Large CSVs (like `order_items.csv`) can be split for classroom demos if needed  

---

## 🧾 Credits
**Maintained by:** Sayyed Shiraj Ahmad (Ali)  
**Program:** AccioJob Data Analytics — PostgreSQL Track  

> _“Realistic data, real learning.”_
