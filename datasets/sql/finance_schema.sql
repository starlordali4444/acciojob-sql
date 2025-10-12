
CREATE SCHEMA IF NOT EXISTS finance;

CREATE TABLE IF NOT EXISTS finance.expenses (
  expense_id int PRIMARY KEY,
  store_id int REFERENCES stores.stores(store_id),
  expense_date date,
  category varchar(50),
  amount numeric(12,2)
);

CREATE TABLE IF NOT EXISTS finance.revenue_summary (
  summary_date date,
  store_id int REFERENCES stores.stores(store_id),
  total_sales numeric(14,2),
  total_expenses numeric(14,2),
  net_profit numeric(14,2)
);
