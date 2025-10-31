\c retailmart;
\copy products.suppliers  FROM 'datasets/csv/products/suppliers.csv'  CSV HEADER;
\copy products.products   FROM 'datasets/csv/products/products.csv'   CSV HEADER;
\copy products.inventory  FROM 'datasets/csv/products/inventory.csv'  CSV HEADER;
\copy products.promotions FROM 'datasets/csv/products/promotions.csv' CSV HEADER;
