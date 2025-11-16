-- File: 04_procedures/refresh_analytics.sql

-- ============================================
-- AUTOMATED ANALYTICS REFRESH PROCEDURES
-- ============================================

-- ---------------------------------------------
-- 1. REFRESH ALL MATERIALIZED VIEWS
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION analytics.fn_refresh_all_materialized_views()
RETURNS TABLE(
    view_name TEXT,
    status TEXT,
    execution_time INTERVAL,
    refreshed_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    v_view_name TEXT;
BEGIN
    -- Refresh mv_monthly_sales_dashboard
    v_view_name := 'mv_monthly_sales_dashboard';
    start_time := CLOCK_TIMESTAMP();
    
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_monthly_sales_dashboard;
        end_time := CLOCK_TIMESTAMP();
        
        view_name := v_view_name;
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        view_name := v_view_name;
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- Refresh mv_top_products
    v_view_name := 'mv_top_products';
    start_time := CLOCK_TIMESTAMP();
    
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_top_products;
        end_time := CLOCK_TIMESTAMP();
        
        view_name := v_view_name;
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        view_name := v_view_name;
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- Refresh mv_customer_lifetime_value
    v_view_name := 'mv_customer_lifetime_value';
    start_time := CLOCK_TIMESTAMP();
    
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_customer_lifetime_value;
        end_time := CLOCK_TIMESTAMP();
        
        view_name := v_view_name;
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        view_name := v_view_name;
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- Refresh mv_rfm_analysis
    v_view_name := 'mv_rfm_analysis';
    start_time := CLOCK_TIMESTAMP();
    
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_rfm_analysis;
        end_time := CLOCK_TIMESTAMP();
        
        view_name := v_view_name;
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        view_name := v_view_name;
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- Refresh mv_cohort_retention
    v_view_name := 'mv_cohort_retention';
    start_time := CLOCK_TIMESTAMP();
    
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_cohort_retention;
        end_time := CLOCK_TIMESTAMP();
        
        view_name := v_view_name;
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        view_name := v_view_name;
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- Refresh mv_abc_analysis
    v_view_name := 'mv_abc_analysis';
    start_time := CLOCK_TIMESTAMP();
    
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_abc_analysis;
        end_time := CLOCK_TIMESTAMP();
        
        view_name := v_view_name;
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        view_name := v_view_name;
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- Refresh mv_store_performance
    v_view_name := 'mv_store_performance';
    start_time := CLOCK_TIMESTAMP();
    
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_store_performance;
        end_time := CLOCK_TIMESTAMP();
        
        view_name := v_view_name;
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        view_name := v_view_name;
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- Refresh mv_executive_summary
    v_view_name := 'mv_executive_summary';
    start_time := CLOCK_TIMESTAMP();
    
    BEGIN
        REFRESH MATERIALIZED VIEW analytics.mv_executive_summary;
        end_time := CLOCK_TIMESTAMP();
        
        view_name := v_view_name;
        status := 'SUCCESS';
        execution_time := end_time - start_time;
        refreshed_at := end_time;
        RETURN NEXT;
        
    EXCEPTION WHEN OTHERS THEN
        view_name := v_view_name;
        status := 'FAILED: ' || SQLERRM;
        execution_time := INTERVAL '0';
        refreshed_at := CLOCK_TIMESTAMP();
        RETURN NEXT;
    END;
    
    -- Update metadata
    UPDATE analytics.kpi_metadata
    SET last_refreshed = CURRENT_TIMESTAMP;
    
END;
$$;

-- Execute the refresh
SELECT * FROM analytics.fn_refresh_all_materialized_views();


SELECT 'Analytics Refresh Procedures Created Successfully!' as status;