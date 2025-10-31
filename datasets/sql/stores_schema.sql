
CREATE SCHEMA IF NOT EXISTS stores;

CREATE TABLE IF NOT EXISTS stores.departments (
  dept_id int PRIMARY KEY,
  dept_name varchar(50)
);

CREATE TABLE IF NOT EXISTS stores.stores (
  store_id int PRIMARY KEY,
  store_name varchar(120),
  city varchar(50),
  state varchar(50),
  region varchar(20)
);

CREATE TABLE IF NOT EXISTS stores.employees (
  emp_id int PRIMARY KEY,
  emp_name varchar(100),
  role varchar(50),
  salary numeric(12,2),
  dept_id int REFERENCES stores.departments(dept_id),
  store_id int REFERENCES stores.stores(store_id)
);

CREATE TABLE IF NOT EXISTS stores.expenses (
  expense_id int PRIMARY KEY,
  store_id int REFERENCES stores.stores(store_id),
  expense_date date,
  expense_type varchar(50),
  amount numeric(12,2)
);
