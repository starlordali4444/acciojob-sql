\c retailmart;
\copy stores.departments FROM 'datasets/csv/stores/departments.csv' CSV HEADER;
\copy stores.stores      FROM 'datasets/csv/stores/stores.csv'      CSV HEADER;
\copy stores.employees   FROM 'datasets/csv/stores/employees.csv'   CSV HEADER;
\copy stores.expenses    FROM 'datasets/csv/stores/expenses.csv'    CSV HEADER;
