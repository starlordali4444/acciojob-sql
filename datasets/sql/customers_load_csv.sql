\c retailmart;
\copy customers.customers     FROM 'datasets/csv/customers/customers.csv'     CSV HEADER;
\copy customers.addresses     FROM 'datasets/csv/customers/addresses.csv'     CSV HEADER;
\copy customers.reviews       FROM 'datasets/csv/customers/reviews.csv'       CSV HEADER;
\copy customers.loyalty_points FROM 'datasets/csv/customers/loyalty_points.csv' CSV HEADER;
