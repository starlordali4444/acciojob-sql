\c retailmart;
\copy core.dim_date    FROM 'datasets/csv/core/dim_date.csv'    CSV HEADER;
\copy core.dim_region  FROM 'datasets/csv/core/dim_region.csv'  CSV HEADER;
\copy core.dim_category FROM 'datasets/csv/core/dim_category.csv' CSV HEADER;
\copy core.dim_brand   FROM 'datasets/csv/core/dim_brand.csv'   CSV HEADER;
