mkdir -p "retailmart_analytics_project"/{01_setup,02_kpi_queries,03_views,04_procedures,05_dashboard,06_documentation} \
&& touch "retailmart_analytics_project"/01_setup/{create_analytics_schema.sql,create_metadata_tables.sql} \
&& touch "retailmart_analytics_project"/02_kpi_queries/{sales_analytics.sql,product_analytics.sql,customer_analytics.sql,store_analytics.sql} \
&& touch "retailmart_analytics_project"/03_views/{materialized_views.sql,reporting_views.sql} \
&& touch "retailmart_analytics_project"/04_procedures/refresh_analytics.sql \
&& touch "retailmart_analytics_project"/05_dashboard/{index.html,styles.css,dashboard.js} \
&& touch "retailmart_analytics_project"/06_documentation/{data_dictionary.md,kpi_definitions.md}