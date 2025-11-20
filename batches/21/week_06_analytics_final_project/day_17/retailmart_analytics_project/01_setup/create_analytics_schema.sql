-- File: 01_setup/create_analytics_schema.sql

-- Create a dedicated workspace for analytics
CREATE SCHEMA IF NOT EXISTS analytics;

-- Let everyone see the results
GRANT USAGE ON SCHEMA analytics TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO PUBLIC;

SELECT 'Analytics schema created!' as status;

--127.0.0.1