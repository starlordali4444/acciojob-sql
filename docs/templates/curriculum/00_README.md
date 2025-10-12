# 📚 Curriculum Templates (Student-Facing)

## 📘 Overview
This folder contains the **standardized SQL curriculum templates** used for all batches at AccioJob.  
Each template is designed to ensure uniformity, clarity, and reusability across all student groups.

Only this folder (`docs/templates/curriculum/`) is **visible to students** — while instructor automation and setup scripts remain hidden.

---

## 🗂️ Structure Overview

| Level | Folder | Description |
|--------|---------|-------------|
| Week | `week_01_foundations_environment/` | Core SQL setup, DBMS concepts, environment installation |
| Day | `day_01/`, `day_02/`, ... | Each day contains theory + practice material |
| File | `.xlsx`, `.sql`, `.md` | Notes, exercises, and SQL solutions |

---

## 🧱 Typical Week Layout

```
week_01_foundations_environment/
├── day_01/
│   ├── day_01_notes.xlsx
│   ├── query.sql
│   ├── setup_postgres_mac.md
│   ├── setup_pgadmin4.md
│   ├── setup_ads.md
│   ├── install_postgresql_mac.sh
│   └── setup_index.md
├── day_02/
│   ├── notes.xlsx
│   ├── queries.sql
│   └── exercises.xlsx
└── README.md
```

---

## 🧩 File Descriptions

| File Type | Purpose |
|------------|----------|
| `.xlsx` | Structured theory and practical notes |
| `.sql` | Practice queries or assignments |
| `.md` | Instructional guides and setup walkthroughs |
| `.sh` | Platform-specific installer (Day 1 only) |

---

## 🧰 Instructor Workflow

When a new batch is created using:
```bash
bash docs/scripts/create_batch.sh 21
```
the script automatically copies:
- The entire curriculum template structure from here  
- All required setup files (`docs/templates/setup/`)  
- The PostgreSQL installer (`docs/templates/sh/install_postgresql_mac.sh`)

This ensures each batch (`/batches/<batch_number>/`) begins with:
- Consistent folder naming  
- Ready-to-use setup materials  
- Clean separation between instructor and student content  

---

## 🧠 Teaching Flow Alignment

| Week | Focus | Example Activities |
|-------|--------|--------------------|
| Week 01 | Environment & SQL Foundations | Installation, syntax, DDL/DML basics |
| Week 02 | Filtering & Aggregation | Grouping, CASE WHEN, HAVING |
| Week 03 | Joins & Relationships | Inner/Outer Joins, Subqueries |
| Week 04 | Analytical SQL | CTEs, Window Functions |
| Week 05 | Advanced SQL | Views, Indexing, Transactions |
| Week 06 | Project Week | RetailMart Analytics Case Study |

---

## 🧾 Maintainer
Created and maintained by **Sayyed Shiraj Ahmad (Ali)**  
for the **AccioJob SQL Curriculum (PostgreSQL Edition)**  

> _“Consistency builds confidence — every batch, every week.”_
