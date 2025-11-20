# 🛒 RetailMart Analytics Dashboard

A comprehensive business intelligence dashboard built with PostgreSQL 16, featuring real-time analytics across Sales, Products, Customers, and Store performance.

## 📋 **Table of Contents**

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup Instructions](#detailed-setup-instructions)
- [Accessing the Dashboard](#accessing-the-dashboard)
- [Scheduled Data Updates](#scheduled-data-updates)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)
- [Features](#features)

---

## 🔧 **Prerequisites**

Before running this project, ensure you have:

### **Required Software:**
- **PostgreSQL 16** (or higher)
- **Python 3.x** (for web server)
- **psql** command-line tool
- **Terminal/Command Line** access

### **Database Requirements:**
- ✅ PostgreSQL server running
- ✅ RetailMart database exists with data loaded
- ✅ Database user with CREATE schema permissions

### **Verify Prerequisites:**
```bash
# Check PostgreSQL version
psql --version
# Expected: psql (PostgreSQL) 16.x

# Check Python version
python3 --version
# Expected: Python 3.x

# Test database connection
psql -U postgres -d retailmart -c "SELECT 'Connection successful!' as status;"
# Should return: Connection successful!
```

---

## 🚀 **Quick Start**

If all prerequisites are met, run these commands in order:
```bash
# 1. Navigate to project directory
cd /path/to/retailmart_analytics_project

# 2. Run all SQL scripts
psql -U postgres -d retailmart -f 01_setup/create_analytics_schema.sql
psql -U postgres -d retailmart -f 01_setup/create_metadata_tables.sql
psql -U postgres -d retailmart -f 02_kpi_queries/sales_analytics.sql
psql -U postgres -d retailmart -f 02_kpi_queries/product_analytics.sql
psql -U postgres -d retailmart -f 02_kpi_queries/customer_analytics.sql
psql -U postgres -d retailmart -f 02_kpi_queries/store_analytics.sql

# 3. Export JSON data
./export_all_json.sh refresh

# 4. Start web server
cd 03_dashboard
python3 -m http.server 8000

# 5. Open browser and go to:
# http://localhost:8000
```

**That's it!** Your dashboard should now be running. 🎉

---

## 📖 **Detailed Setup Instructions**

### **Step 1: Verify Project Structure**
```bash
# Check all files exist
ls -la 01_setup/
ls -la 02_kpi_queries/
ls -la 03_dashboard/
ls -la export_all_json.sh

# Your structure should look like:
# retailmart_analytics_project/
# ├── 01_setup/
# │   ├── create_analytics_schema.sql
# │   └── create_metadata_tables.sql
# ├── 02_kpi_queries/
# │   ├── sales_analytics.sql
# │   ├── product_analytics.sql
# │   ├── customer_analytics.sql
# │   └── store_analytics.sql
# ├── 03_dashboard/
# │   ├── index.html
# │   ├── dashboard.js
# │   └── styles.css
# └── export_all_json.sh
```

---

### **Step 2: Create Database Schema**
```bash
# Create analytics schema
psql -U postgres -d retailmart -f 01_setup/create_analytics_schema.sql

# Expected output:
#         status          
# -----------------------
#  Analytics schema created successfully!
```

---

### **Step 3: Create Metadata Tables**
```bash
# Create audit and metadata tracking tables
psql -U postgres -d retailmart -f 01_setup/create_metadata_tables.sql

# Expected output:
# Creating metadata and audit tables...
# Metadata tables created successfully!
```

---

### **Step 4: Create Analytics Modules**

Run each analytics module in order:

#### **4.1 Sales Analytics**
```bash
psql -U postgres -d retailmart -f 02_kpi_queries/sales_analytics.sql

# Expected output:
# ✓ View created: vw_daily_sales_summary
# ✓ Materialized view created: mv_monthly_sales_dashboard
# ✓ Materialized view created: mv_executive_summary
# ✓ Function created: get_executive_summary_json()
# ... (7 JSON functions total)
```

#### **4.2 Product Analytics**
```bash
psql -U postgres -d retailmart -f 02_kpi_queries/product_analytics.sql

# Expected output:
# ✓ Materialized view created: mv_top_products
# ✓ Materialized view created: mv_abc_analysis
# ✓ Function created: get_top_products_json()
# ... (5 JSON functions total)
```

#### **4.3 Customer Analytics**
```bash
psql -U postgres -d retailmart -f 02_kpi_queries/customer_analytics.sql

# Expected output:
# ✓ Materialized view created: mv_customer_lifetime_value
# ✓ Materialized view created: mv_rfm_analysis
# ✓ Materialized view created: mv_cohort_retention
# ✓ Function created: get_top_customers_json()
# ... (6 JSON functions total)
```

#### **4.4 Store Analytics**
```bash
psql -U postgres -d retailmart -f 02_kpi_queries/store_analytics.sql

# Expected output:
# ✓ Materialized view created: mv_store_performance
# ✓ View created: vw_regional_performance
# ✓ Function created: fn_refresh_all_analytics()
# ✓ Function created: get_top_stores_json()
# ... (4 JSON functions total)
```

---

### **Step 5: Verify Database Objects**
```bash
# Check all views were created (should show 17 views)
psql -U postgres -d retailmart -c "\dv analytics.*"

# Check all materialized views (should show 8)
psql -U postgres -d retailmart -c "\dm analytics.*"

# Check all functions (should show 22+ functions)
psql -U postgres -d retailmart -c "\df analytics.*"
```

---

### **Step 6: Export JSON Data**

Make the export script executable:
```bash
chmod +x export_all_json.sh
```

Run the export script with refresh option:
```bash
./export_all_json.sh refresh
```

**Expected Output:**
```
============================================================================
                  RETAILMART ANALYTICS JSON EXPORT                          
============================================================================

⚠ Refresh flag detected - Refreshing all materialized views...

  module  |                    view_name                     |   status   | execution_time  
----------+--------------------------------------------------+------------+-----------------
 Sales    | mv_monthly_sales_dashboard, mv_executive_summary | SUCCESS    | 00:00:00.307428
 Product  | mv_top_products, mv_abc_analysis                 | SUCCESS    | 00:00:00.895118
 Customer | mv_customer_lifetime_value, mv_rfm_analysis...   | SUCCESS    | 00:00:00.431290
 Store    | mv_store_performance                             | SUCCESS    | 00:00:00.058398

✓ All materialized views refreshed successfully!

ℹ Creating directory structure...
ℹ Created directory: ./03_dashboard/data/sales
ℹ Created directory: ./03_dashboard/data/products
ℹ Created directory: ./03_dashboard/data/customers
ℹ Created directory: ./03_dashboard/data/stores

============================================================================
                        EXPORTING SALES MODULE                              
============================================================================

✓ Exported: ./03_dashboard/data/sales/executive_summary.json
✓ Exported: ./03_dashboard/data/sales/monthly_trend.json
... (22 files total)

============================================================================
                          EXPORT COMPLETE!                                  
============================================================================

✓ All JSON files exported successfully!

📂 Files created in:
   - ./03_dashboard/data/sales/ (7 files)
   - ./03_dashboard/data/products/ (5 files)
   - ./03_dashboard/data/customers/ (6 files)
   - ./03_dashboard/data/stores/ (4 files)
```

---

### **Step 7: Verify JSON Files**
```bash
# Count JSON files (should be 22)
find 03_dashboard/data -name "*.json" | wc -l

# List all JSON files
find 03_dashboard/data -name "*.json"

# Check file sizes (all should be > 0 bytes)
ls -lh 03_dashboard/data/*/*.json
```

---

## 🌐 **Accessing the Dashboard**

### **Start Web Server**
```bash
# Navigate to dashboard directory
cd 03_dashboard

# Start Python HTTP server on port 8000
python3 -m http.server 8000
```

**Expected Output:**
```
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

**Alternative Web Servers:**
```bash
# Using Node.js (if installed)
npx http-server -p 8000

# Using PHP (if installed)
php -S localhost:8000
```

---

### **Open Dashboard in Browser**

**Option 1: Command Line**
```bash
# macOS
open http://localhost:8000

# Linux
xdg-open http://localhost:8000

# Windows (WSL)
explorer.exe http://localhost:8000
```

**Option 2: Manual**
- Open your web browser
- Navigate to: `http://localhost:8000`

---

### **Dashboard Features**

The dashboard has **5 main tabs**:

#### **1. 📊 Executive Summary**
- Total Revenue, Orders, Customers, Avg Order Value
- Monthly Revenue Trend (12 months)
- Sales by Category
- Top 10 Products
- Top 10 Customers

#### **2. 💰 Sales Analytics**
- Last 30 Days Revenue & Orders
- Daily Sales Trend
- Sales by Day of Week
- Quarterly Performance

#### **3. 📦 Product Performance**
- Top 10 Products by Revenue
- ABC Classification
- Product Performance Details Table

#### **4. 👥 Customer Insights**
- RFM Customer Segmentation
- Customer Lifetime Value Distribution
- Churn Risk Distribution

#### **5. 🏪 Store Performance**
- Top 10 Stores by Revenue
- Regional Performance Comparison
- Store Performance Scorecard Table

---

## 🔄 **Scheduled Data Updates**

### **Manual Refresh**

To manually refresh data:
```bash
# Refresh materialized views and export new JSON files
./export_all_json.sh refresh

# Then refresh your browser (Ctrl+Shift+R or Cmd+Shift+R)
```

---

### **Automated Refresh with Cron**

Set up automatic daily updates at midnight:
```bash
# Edit crontab
crontab -e

# Add this line (update path to your project directory)
0 0 * * * cd /full/path/to/retailmart_analytics_project && ./export_all_json.sh refresh >> /tmp/retailmart_export.log 2>&1
```

**Other Schedule Options:**
```bash
# Every 6 hours
0 */6 * * * cd /path/to/project && ./export_all_json.sh refresh

# Every hour
0 * * * * cd /path/to/project && ./export_all_json.sh refresh

# Every Monday at 8 AM
0 8 * * 1 cd /path/to/project && ./export_all_json.sh refresh
```

---

## 🔧 **Troubleshooting**

### **Issue: Connection Refused**

**Error:** `psql: error: connection to server ... failed: Connection refused`

**Solution:**
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start PostgreSQL if stopped
sudo systemctl start postgresql

# On macOS with Homebrew:
brew services start postgresql@16
```

---

### **Issue: Database Does Not Exist**

**Error:** `FATAL: database "retailmart" does not exist`

**Solution:**
```bash
# Create the database
createdb -U postgres retailmart

# Or using psql:
psql -U postgres -c "CREATE DATABASE retailmart;"
```

---

### **Issue: Permission Denied on Script**

**Error:** `bash: ./export_all_json.sh: Permission denied`

**Solution:**
```bash
chmod +x export_all_json.sh
```

---

### **Issue: JSON Files Not Loading in Dashboard**

**Symptoms:** Dashboard shows "Loading..." or empty charts

**Solutions:**
```bash
# 1. Verify JSON files exist
ls -la 03_dashboard/data/*/*.json

# 2. Check file content (should not be empty)
cat 03_dashboard/data/sales/executive_summary.json

# 3. Ensure web server is running from correct directory
cd 03_dashboard
python3 -m http.server 8000

# 4. Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)

# 5. Check browser console for errors (F12)
```

---

### **Issue: Charts Not Displaying**

**Symptoms:** Empty chart containers

**Solutions:**
```bash
# 1. Check browser console (F12) for JavaScript errors

# 2. Verify Chart.js is loading (check browser Network tab)

# 3. Clear browser cache and hard refresh

# 4. Check that JSON data is valid
cat 03_dashboard/data/sales/executive_summary.json | python3 -m json.tool
```

---

### **Issue: Export Script Fails**

**Error:** `Failed to export: ./03_dashboard/data/sales/...`

**Solutions:**
```bash
# 1. Test JSON function manually
psql -U postgres -d retailmart -c "SELECT analytics.get_executive_summary_json();"

# 2. Check for SQL errors
psql -U postgres -d retailmart -c "\df analytics.get_*"

# 3. Re-run analytics SQL files
psql -U postgres -d retailmart -f 02_kpi_queries/sales_analytics.sql
```

---

## 📁 **Project Structure**
```
retailmart_analytics_project/
│
├── 01_setup/                                  # Database setup scripts
│   ├── create_analytics_schema.sql            # Creates analytics schema
│   └── create_metadata_tables.sql             # Creates audit/metadata tables
│
├── 02_kpi_queries/                            # Analytics modules
│   ├── sales_analytics.sql                    # Sales module (8 views, 7 JSON funcs)
│   ├── product_analytics.sql                  # Product module (5 views, 5 JSON funcs)
│   ├── customer_analytics.sql                 # Customer module (6 views, 6 JSON funcs)
│   └── store_analytics.sql                    # Store module (4 views, 4 JSON funcs)
│
├── 03_dashboard/                              # Web dashboard
│   ├── data/                                  # JSON data exports
│   │   ├── sales/                             # 7 JSON files
│   │   ├── products/                          # 5 JSON files
│   │   ├── customers/                         # 6 JSON files
│   │   └── stores/                            # 4 JSON files
│   ├── index.html                             # Dashboard HTML (200+ lines)
│   ├── dashboard.js                           # Dashboard JavaScript (985+ lines)
│   └── styles.css                             # Dashboard CSS (300+ lines)
│
├── export_all_json.sh                         # JSON export automation script
└── README.md                                  # This file
```

---

## ✨ **Features**

### **Database Layer**
- ✅ 17 Regular Views (real-time queries)
- ✅ 8 Materialized Views (pre-aggregated data)
- ✅ 22 JSON Export Functions
- ✅ 1 Global Refresh Function
- ✅ Audit logging and metadata tracking

### **Analytics Modules**
- ✅ **Sales Analytics**: Revenue trends, payment analysis, quarterly reports
- ✅ **Product Analytics**: Top products, ABC classification, inventory status
- ✅ **Customer Analytics**: CLV, RFM segmentation, churn prediction
- ✅ **Store Analytics**: Store profitability, regional comparison, employee metrics

### **Dashboard**
- ✅ 15+ Interactive Charts (Chart.js)
- ✅ 4 Data Tables
- ✅ 5 Navigation Tabs
- ✅ Real-time KPI Cards
- ✅ Responsive Design

### **Automation**
- ✅ One-command data export
- ✅ Automatic view refresh
- ✅ Cron job compatible
- ✅ Backup creation before export

---

## 📊 **Analytics Overview**

| Module | Views | Mat. Views | JSON Functions | Key Metrics |
|--------|-------|------------|----------------|-------------|
| **Sales** | 8 | 2 | 7 | Revenue, Orders, Trends |
| **Products** | 3 | 2 | 5 | Top Products, Inventory |
| **Customers** | 3 | 3 | 6 | CLV, RFM, Churn |
| **Stores** | 3 | 1 | 4 | Store Performance |
| **TOTAL** | **17** | **8** | **22** | **50+ KPIs** |

---

## 🎯 **Success Criteria**

Your dashboard is working correctly if:

- ✅ All 22 JSON files exist in `/03_dashboard/data/`
- ✅ All charts display data (no empty containers)
- ✅ All tables are populated with rows
- ✅ No errors in browser console (F12)
- ✅ KPI cards show numeric values
- ✅ Tab navigation works smoothly
- ✅ Export script completes without errors

---

## 📞 **Support & Documentation**

### **Check Database Objects**
```bash
# List all analytics views
psql -U postgres -d retailmart -c "\dv analytics.*"

# List all materialized views
psql -U postgres -d retailmart -c "\dm analytics.*"

# List all functions
psql -U postgres -d retailmart -c "\df analytics.*"
```

### **Test Individual JSON Functions**
```bash
# Test sales summary
psql -U postgres -d retailmart -c "SELECT analytics.get_executive_summary_json();"

# Test top products
psql -U postgres -d retailmart -c "SELECT analytics.get_top_products_json();"

# Test RFM segments
psql -U postgres -d retailmart -c "SELECT analytics.get_rfm_segments_json();"
```

### **View Export Logs**
```bash
# Check latest export log
tail -100 export_log_*.log

# View all logs
ls -lt export_log_*.log
```

---

## 🚀 **Quick Commands Reference**
```bash
# Run everything in one go
psql -U postgres -d retailmart -f 01_setup/create_analytics_schema.sql && \
psql -U postgres -d retailmart -f 01_setup/create_metadata_tables.sql && \
psql -U postgres -d retailmart -f 02_kpi_queries/sales_analytics.sql && \
psql -U postgres -d retailmart -f 02_kpi_queries/product_analytics.sql && \
psql -U postgres -d retailmart -f 02_kpi_queries/customer_analytics.sql && \
psql -U postgres -d retailmart -f 02_kpi_queries/store_analytics.sql && \
./export_all_json.sh refresh && \
cd 03_dashboard && python3 -m http.server 8000

# Refresh data only
./export_all_json.sh refresh

# Refresh materialized views in database
psql -U postgres -d retailmart -c "SELECT * FROM analytics.fn_refresh_all_analytics();"

# Count JSON files
find 03_dashboard/data -name "*.json" | wc -l

# Start web server
cd 03_dashboard && python3 -m http.server 8000
```

---

## 📝 **License**

This project is part of the AccioJob SQL Curriculum.

---

## 👤 **Author**

**Instructor:** Sayyed Siraj Ali  
**Course:** PostgreSQL Analytics with pgAdmin 4 & Azure Data Studio  
**Duration:** 6 Weeks | 18 Sessions  

---

## 🎉 **Congratulations!**

You now have a fully functional analytics dashboard! 

**Bookmark this page:** `http://localhost:8000`

**For any issues**, check the [Troubleshooting](#troubleshooting) section above.

---

**Last Updated:** November 2024  
**Version:** 1.0.0