#!/bin/bash

# ============================================================================
# FILE: export_all_json.sh
# PURPOSE: Export all analytics data as JSON files for dashboard
# USAGE: ./export_all_json.sh [refresh]
# DESCRIPTION:
#   - Exports all 22 JSON functions to organized directory structure
#   - Optional: Refresh all materialized views before export
#   - Creates timestamped backup of previous exports
#   - Logs all operations
# ============================================================================

# ----------------------------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------------------------
DB_NAME="retailmart"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

# Output directory structure
BASE_DIR="./03_dashboard/data"
SALES_DIR="${BASE_DIR}/sales"
PRODUCTS_DIR="${BASE_DIR}/products"
CUSTOMERS_DIR="${BASE_DIR}/customers"
STORES_DIR="${BASE_DIR}/stores"
LOG_FILE="./export_log_$(date +%Y%m%d_%H%M%S).log"

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ----------------------------------------------------------------------------
# HELPER FUNCTIONS
# ----------------------------------------------------------------------------

# Log function with timestamp
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Print colored message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    log "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    log "ERROR: $1"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
    log "INFO: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    log "WARNING: $1"
}

# Export JSON function
export_json() {
    local function_name=$1
    local output_file=$2
    local description=$3
    
    print_info "Exporting: $description"
    
    # Run psql command and capture output
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
         -t -A -c "SELECT analytics.${function_name}();" > "$output_file" 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "Exported: $output_file"
        return 0
    else
        print_error "Failed to export: $output_file"
        return 1
    fi
}

# Create directory if it doesn't exist
ensure_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        print_info "Created directory: $1"
    fi
}

# Backup existing files
backup_existing() {
    if [ -d "$BASE_DIR" ]; then
        BACKUP_DIR="./03_dashboard/data_backup_$(date +%Y%m%d_%H%M%S)"
        print_warning "Creating backup of existing files..."
        mv "$BASE_DIR" "$BACKUP_DIR"
        print_success "Backup created: $BACKUP_DIR"
    fi
}

# ----------------------------------------------------------------------------
# MAIN SCRIPT
# ----------------------------------------------------------------------------

echo ""
echo "============================================================================"
echo "                  RETAILMART ANALYTICS JSON EXPORT                          "
echo "============================================================================"
echo ""
log "Starting JSON export process..."

# Check if refresh flag is passed
REFRESH_FLAG=$1
if [ "$REFRESH_FLAG" == "refresh" ]; then
    print_warning "Refresh flag detected - Refreshing all materialized views..."
    echo ""
    
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
         -c "SELECT * FROM analytics.fn_refresh_all_analytics();" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        print_success "All materialized views refreshed successfully!"
    else
        print_error "Failed to refresh materialized views"
        exit 1
    fi
    echo ""
fi

# Create backup of existing files
backup_existing

# Create directory structure
print_info "Creating directory structure..."
ensure_directory "$SALES_DIR"
ensure_directory "$PRODUCTS_DIR"
ensure_directory "$CUSTOMERS_DIR"
ensure_directory "$STORES_DIR"
echo ""

# ----------------------------------------------------------------------------
# SALES MODULE (7 functions)
# ----------------------------------------------------------------------------
echo "============================================================================"
echo "                        EXPORTING SALES MODULE                              "
echo "============================================================================"
echo ""

export_json "get_executive_summary_json" \
    "${SALES_DIR}/executive_summary.json" \
    "Executive Summary KPIs"

export_json "get_monthly_trend_json" \
    "${SALES_DIR}/monthly_trend.json" \
    "Monthly Sales Trend (12 months)"

export_json "get_recent_trend_json" \
    "${SALES_DIR}/recent_trend.json" \
    "Recent 30-Day Trend"

export_json "get_dayofweek_json" \
    "${SALES_DIR}/dayofweek.json" \
    "Sales by Day of Week"

export_json "get_payment_mode_json" \
    "${SALES_DIR}/payment_mode.json" \
    "Sales by Payment Mode"

export_json "get_quarterly_sales_json" \
    "${SALES_DIR}/quarterly_sales.json" \
    "Quarterly Sales Performance"

export_json "get_weekend_weekday_json" \
    "${SALES_DIR}/weekend_weekday.json" \
    "Weekend vs Weekday Sales"

echo ""

# ----------------------------------------------------------------------------
# PRODUCTS MODULE (5 functions)
# ----------------------------------------------------------------------------
echo "============================================================================"
echo "                      EXPORTING PRODUCTS MODULE                             "
echo "============================================================================"
echo ""

export_json "get_top_products_json" \
    "${PRODUCTS_DIR}/top_products.json" \
    "Top 20 Products"

export_json "get_category_performance_json" \
    "${PRODUCTS_DIR}/category_performance.json" \
    "Category Performance"

export_json "get_brand_performance_json" \
    "${PRODUCTS_DIR}/brand_performance.json" \
    "Brand Performance (Top 20)"

export_json "get_abc_analysis_json" \
    "${PRODUCTS_DIR}/abc_analysis.json" \
    "ABC Classification"

export_json "get_inventory_status_json" \
    "${PRODUCTS_DIR}/inventory_status.json" \
    "Inventory Status Summary"

echo ""

# ----------------------------------------------------------------------------
# CUSTOMERS MODULE (6 functions)
# ----------------------------------------------------------------------------
echo "============================================================================"
echo "                     EXPORTING CUSTOMERS MODULE                             "
echo "============================================================================"
echo ""

export_json "get_top_customers_json" \
    "${CUSTOMERS_DIR}/top_customers.json" \
    "Top 50 Customers by CLV"

export_json "get_clv_tier_distribution_json" \
    "${CUSTOMERS_DIR}/clv_distribution.json" \
    "CLV Tier Distribution"

export_json "get_rfm_segments_json" \
    "${CUSTOMERS_DIR}/rfm_segments.json" \
    "RFM Customer Segments"

export_json "get_churn_risk_json" \
    "${CUSTOMERS_DIR}/churn_risk.json" \
    "Churn Risk Analysis"

export_json "get_demographics_json" \
    "${CUSTOMERS_DIR}/demographics.json" \
    "Customer Demographics"

export_json "get_geography_json" \
    "${CUSTOMERS_DIR}/geography.json" \
    "Geographic Distribution (Top 50)"

echo ""

# ----------------------------------------------------------------------------
# STORES MODULE (4 functions)
# ----------------------------------------------------------------------------
echo "============================================================================"
echo "                       EXPORTING STORES MODULE                              "
echo "============================================================================"
echo ""

export_json "get_top_stores_json" \
    "${STORES_DIR}/top_stores.json" \
    "Top 20 Stores"

export_json "get_regional_performance_json" \
    "${STORES_DIR}/regional_performance.json" \
    "Regional Performance Summary"

export_json "get_store_inventory_json" \
    "${STORES_DIR}/store_inventory.json" \
    "Store Inventory Health"

export_json "get_employee_distribution_json" \
    "${STORES_DIR}/employee_distribution.json" \
    "Employee Distribution by Store"

echo ""

# ----------------------------------------------------------------------------
# SUMMARY
# ----------------------------------------------------------------------------
echo "============================================================================"
echo "                          EXPORT COMPLETE!                                  "
echo "============================================================================"
echo ""
print_success "All JSON files exported successfully!"
echo ""
echo "📂 Files created in:"
echo "   - ${SALES_DIR}/ (7 files)"
echo "   - ${PRODUCTS_DIR}/ (5 files)"
echo "   - ${CUSTOMERS_DIR}/ (6 files)"
echo "   - ${STORES_DIR}/ (4 files)"
echo ""
echo "📋 Log file: $LOG_FILE"
echo ""
echo "🚀 Next steps:"
echo "   1. Review exported JSON files"
echo "   2. Update dashboard.js to load these files"
echo "   3. Set up cron job for automated exports:"
echo "      0 0 * * * cd /path/to/project && ./export_all_json.sh refresh"
echo ""
echo "============================================================================"
echo ""

log "JSON export process completed successfully"