-- File: 01_setup/create_metadata_tables.sql

-- ============================================
-- CREATE METADATA AND AUDIT TABLES
-- ============================================

\echo 'Creating metadata and audit tables...'

-- Create metadata table to track KPIs and refresh status
CREATE TABLE IF NOT EXISTS analytics.kpi_metadata (
    kpi_id SERIAL PRIMARY KEY,
    kpi_name VARCHAR(100) UNIQUE NOT NULL,
    kpi_category VARCHAR(50),
    description TEXT,
    source_tables TEXT,
    refresh_frequency VARCHAR(20),
    last_refreshed TIMESTAMP,
    row_count BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT CURRENT_USER
);

-- Create audit log table
CREATE TABLE IF NOT EXISTS analytics.audit_log (
    log_id SERIAL PRIMARY KEY,
    operation VARCHAR(50),
    table_name VARCHAR(100),
    rows_affected BIGINT,
    execution_time INTERVAL,
    status VARCHAR(20),
    error_message TEXT,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    executed_by VARCHAR(50) DEFAULT CURRENT_USER
);

-- Insert initial metadata for tracking
INSERT INTO analytics.kpi_metadata (kpi_name, kpi_category, description, refresh_frequency)
VALUES 
    ('Sales Performance Dashboard', 'Sales', 'Monthly and daily sales trends with YoY comparison', 'Daily'),
    ('Product Performance Analysis', 'Products', 'Top products, categories, and inventory metrics', 'Daily'),
    ('Customer Retention Metrics', 'Customers', 'RFM analysis, churn prediction, and lifetime value', 'Weekly'),
    ('Store Performance Scorecard', 'Stores', 'Store-wise revenue, expenses, and profitability', 'Daily'),
    ('Executive Summary', 'Executive', 'High-level KPIs for management dashboard', 'Hourly')
ON CONFLICT (kpi_name) DO NOTHING;

-- Create helper function to log operations
CREATE OR REPLACE FUNCTION analytics.log_operation(
    p_operation VARCHAR,
    p_table_name VARCHAR,
    p_rows_affected BIGINT,
    p_execution_time INTERVAL,
    p_status VARCHAR,
    p_error_message TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO analytics.audit_log (
        operation, 
        table_name, 
        rows_affected, 
        execution_time, 
        status, 
        error_message
    )
    VALUES (
        p_operation, 
        p_table_name, 
        p_rows_affected, 
        p_execution_time, 
        p_status, 
        p_error_message
    );
END;
$$ LANGUAGE plpgsql;

\echo 'Metadata and audit tables created successfully!'