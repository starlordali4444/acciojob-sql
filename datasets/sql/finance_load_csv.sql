\c retailmart;
\copy finance.expenses        FROM 'datasets/csv/finance/expenses.csv'        CSV HEADER;
\copy finance.revenue_summary FROM 'datasets/csv/finance/revenue_summary.csv' CSV HEADER;
