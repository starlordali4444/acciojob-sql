#!/bin/bash
# ============================================================================
# FILE: 05_refresh/export_all_json.sh
# PROJECT: RetailMart V3 Enterprise Analytics Platform
# PURPOSE: Export all analytics data as JSON files for dashboard consumption
# AUTHOR: Sayyed Siraj Ali
# VERSION: 3.0 (RetailMart V3)
# DATABASE: accio_retailmart_NN (PostgreSQL 18)
#
# USAGE:
#   chmod +x export_all_json.sh
#   ./export_all_json.sh [output_directory]
#   ./export_all_json.sh --refresh [output_directory]
#
#   To avoid password prompts, either:
#   1. Set PGPASSWORD: export PGPASSWORD=yourpassword && ./export_all_json.sh
#   2. Create ~/.pgpass file: localhost:5432:*:postgres:yourpassword
#      Then: chmod 600 ~/.pgpass
#   3. Use peer/trust auth in pg_hba.conf (local dev only)
# ============================================================================

set -e

# Configuration
# Point this at YOUR RetailMart V3 database. Either export PGDATABASE
# (e.g. export PGDATABASE=accio_retailmart_26) or replace NN below with your batch number.
DB_NAME="${PGDATABASE:-accio_retailmart_26}"
DB_USER="${PGUSER:-postgres}"
OUTPUT_DIR="${2:-${1:-./06_dashboard/data}}"
LOG_DIR="./05_refresh/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/export_log_${TIMESTAMP}.txt"

# Prompt for password ONCE if not already set
if [ -z "$PGPASSWORD" ]; then
    echo -n "Enter PostgreSQL password for user '$DB_USER': "
    read -s PGPASSWORD
    echo ""
    export PGPASSWORD
fi

# Handle --refresh flag
REFRESH_FIRST=false
if [ "$1" == "--refresh" ]; then
    REFRESH_FIRST=true
    OUTPUT_DIR="${2:-./06_dashboard/data}"
fi

# Create directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

echo "============================================================================" | tee "$LOG_FILE"
echo "  RetailMart V3 Analytics — JSON Export" | tee -a "$LOG_FILE"
echo "  Database: $DB_NAME" | tee -a "$LOG_FILE"
echo "  Output: $OUTPUT_DIR" | tee -a "$LOG_FILE"
echo "  Started: $(date)" | tee -a "$LOG_FILE"
echo "============================================================================" | tee -a "$LOG_FILE"

# Test connection first
if ! psql -d "$DB_NAME" -U "$DB_USER" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ Cannot connect to database '$DB_NAME' as user '$DB_USER'"
    echo "   Check your credentials and try again."
    exit 1
fi
echo "  ✓ Database connection verified" | tee -a "$LOG_FILE"

# Refresh if requested
if [ "$REFRESH_FIRST" = true ]; then
    echo "" | tee -a "$LOG_FILE"
    echo "Refreshing materialized views..." | tee -a "$LOG_FILE"
    psql -d "$DB_NAME" -U "$DB_USER" -c "SELECT * FROM analytics.fn_refresh_all_analytics();" 2>&1 | tee -a "$LOG_FILE"
    echo "✓ Refresh complete" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "Exporting JSON data..." | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Export function helper
export_json() {
    local func_name=$1
    local file_name=$2
    local start_time=$(date +%s%N 2>/dev/null || date +%s)

    psql -d "$DB_NAME" -U "$DB_USER" -t -A -c "SELECT $func_name();" > "$OUTPUT_DIR/$file_name" 2>/dev/null

    local end_time=$(date +%s%N 2>/dev/null || date +%s)
    local duration=$(( (end_time - start_time) / 1000000 ))
    local size=$(wc -c < "$OUTPUT_DIR/$file_name" 2>/dev/null || echo "0")

    if [ -s "$OUTPUT_DIR/$file_name" ]; then
        echo "  ✓ $file_name (${size} bytes, ${duration}ms)" | tee -a "$LOG_FILE"
    else
        echo "  ✗ $file_name — EMPTY OR FAILED" | tee -a "$LOG_FILE"
    fi
}

# ── Tab 1: Executive ──
echo "[1/10] Executive..." | tee -a "$LOG_FILE"
export_json "analytics.get_executive_summary_json" "executive_summary.json"

# ── Tab 2: Sales ──
echo "[2/10] Sales..." | tee -a "$LOG_FILE"
export_json "analytics.get_monthly_trend_json" "monthly_trend.json"
export_json "analytics.get_recent_trend_json" "recent_trend.json"
export_json "analytics.get_dayofweek_json" "dayofweek.json"
export_json "analytics.get_payment_mode_json" "payment_mode.json"
export_json "analytics.get_quarterly_sales_json" "quarterly_sales.json"
export_json "analytics.get_weekend_weekday_json" "weekend_weekday.json"
export_json "analytics.get_order_status_json" "order_status.json"

# ── Tab 3: Customers ──
echo "[3/10] Customers..." | tee -a "$LOG_FILE"
export_json "analytics.get_top_customers_json" "top_customers.json"
export_json "analytics.get_clv_tier_distribution_json" "clv_tiers.json"
export_json "analytics.get_rfm_segments_json" "rfm_segments.json"
export_json "analytics.get_churn_risk_json" "churn_risk.json"
export_json "analytics.get_registration_trends_json" "registration_trends.json"
export_json "analytics.get_geography_json" "geography.json"
export_json "analytics.get_loyalty_overview_json" "loyalty_overview.json"

# ── Tab 4: Products ──
echo "[4/10] Products..." | tee -a "$LOG_FILE"
export_json "analytics.get_top_products_json" "top_products.json"
export_json "analytics.get_category_performance_json" "category_performance.json"
export_json "analytics.get_brand_performance_json" "brand_performance.json"
export_json "analytics.get_abc_analysis_json" "abc_analysis.json"
export_json "analytics.get_inventory_status_json" "inventory_status.json"

# ── Tab 5: Stores ──
echo "[5/10] Stores..." | tee -a "$LOG_FILE"
export_json "analytics.get_top_stores_json" "top_stores.json"
export_json "analytics.get_regional_performance_json" "regional_performance.json"
export_json "analytics.get_store_inventory_json" "store_inventory.json"
export_json "analytics.get_employee_distribution_json" "employee_distribution.json"

# ── Tab 6: Operations ──
echo "[6/10] Operations..." | tee -a "$LOG_FILE"
export_json "analytics.get_operations_summary_json" "operations_summary.json"
export_json "analytics.get_delivery_performance_json" "delivery_performance.json"
export_json "analytics.get_courier_comparison_json" "courier_comparison.json"
export_json "analytics.get_return_analysis_json" "return_analysis.json"
export_json "analytics.get_pending_shipments_json" "pending_shipments.json"
export_json "analytics.get_support_overview_json" "support_overview.json"
export_json "analytics.get_call_center_json" "call_center.json"

# ── Tab 7: Marketing ──
echo "[7/10] Marketing..." | tee -a "$LOG_FILE"
export_json "analytics.get_marketing_summary_json" "marketing_summary.json"
export_json "analytics.get_campaign_performance_json" "campaign_performance.json"
export_json "analytics.get_channel_performance_json" "channel_performance.json"
export_json "analytics.get_email_engagement_json" "email_engagement.json"
export_json "analytics.get_web_analytics_json" "web_analytics.json"

# ── Tab 8: Finance & HR ──
echo "[8/10] Finance & HR..." | tee -a "$LOG_FILE"
export_json "analytics.get_finance_summary_json" "finance_summary.json"
export_json "analytics.get_hr_overview_json" "hr_overview.json"
export_json "analytics.get_payroll_summary_json" "payroll_summary.json"

# ── Tab 9: Audit & Compliance ──
echo "[9/10] Audit & Compliance..." | tee -a "$LOG_FILE"
export_json "analytics.get_audit_overview_json" "audit_overview.json"
export_json "analytics.get_api_performance_json" "api_performance.json"

# ── Tab 10: Supply Chain ──
echo "[10/10] Supply Chain & Manufacturing..." | tee -a "$LOG_FILE"
export_json "analytics.get_supply_chain_json" "supply_chain.json"
export_json "analytics.get_manufacturing_json" "manufacturing.json"

# ── Alerts ──
echo "[Bonus] Alerts..." | tee -a "$LOG_FILE"
export_json "analytics.get_all_alerts_json" "alerts.json"

# Clean up password from environment
unset PGPASSWORD

echo "" | tee -a "$LOG_FILE"
echo "============================================================================" | tee -a "$LOG_FILE"
echo "  Export Complete!" | tee -a "$LOG_FILE"
echo "  Files: $(ls -1 "$OUTPUT_DIR"/*.json 2>/dev/null | wc -l) JSON files exported" | tee -a "$LOG_FILE"
echo "  Total Size: $(du -sh "$OUTPUT_DIR" | cut -f1)" | tee -a "$LOG_FILE"
echo "  Finished: $(date)" | tee -a "$LOG_FILE"
echo "============================================================================" | tee -a "$LOG_FILE"