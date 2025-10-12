\c retailmart;
\copy sales.orders      FROM 'datasets/csv/sales/orders.csv'      CSV HEADER;
\copy sales.order_items FROM 'datasets/csv/sales/order_items.csv' CSV HEADER;
\copy sales.payments    FROM 'datasets/csv/sales/payments.csv'    CSV HEADER;
\copy sales.shipments   FROM 'datasets/csv/sales/shipments.csv'   CSV HEADER;
\copy sales.returns     FROM 'datasets/csv/sales/returns.csv'     CSV HEADER;
