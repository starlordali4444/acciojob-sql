--  ACCIO RETAILMART CLEAN (SOLUTION) SETUP SCRIPT
-- Run this from the repository root: psql -U postgres -f datasets/v3/sql/setup_accio_retailmart.sql
-- It creates a database named accio_retailmart_ (trailing underscore on purpose).
-- After loading, rename it in pgAdmin 4 to add your batch number (e.g. accio_retailmart_27 for batch 27).

\set ON_ERROR_STOP on
-- Force UTF-8 client encoding so the CSV \copy loads cleanly on any OS
-- (Windows psql defaults to a non-UTF8 codepage; this avoids needing PGCLIENTENCODING=UTF8).
\encoding UTF8
\echo 'Creating accio_retailmart_ DB...'
DO $$
BEGIN
  PERFORM pg_terminate_backend(pid)
  FROM pg_stat_activity
  WHERE datname = 'accio_retailmart_'
    AND pid <> pg_backend_pid();
EXCEPTION WHEN OTHERS THEN
  NULL; -- Ignore errors if DB doesn't exist or permissions fail
END
$$;
DROP DATABASE IF EXISTS accio_retailmart_;
CREATE DATABASE accio_retailmart_;
\connect accio_retailmart_
\echo 'Connected to accio_retailmart_'



CREATE SCHEMA IF NOT EXISTS core;

CREATE TABLE IF NOT EXISTS core.dim_date (
  date_key date PRIMARY KEY,
  day int, month int, year int, quarter int,
  day_name varchar(10), month_name varchar(10)
);

CREATE TABLE IF NOT EXISTS core.dim_region (
  region_id int PRIMARY KEY,
  region_name varchar(20),
  country varchar(50),
  state varchar(50)
);

CREATE TABLE IF NOT EXISTS core.dim_category (
  category_id int PRIMARY KEY,
  category_name varchar(50)
);

CREATE TABLE IF NOT EXISTS core.dim_brand (
  brand_id int PRIMARY KEY,
  brand_name varchar(100),
  category_id int REFERENCES core.dim_category(category_id)
);

CREATE TABLE IF NOT EXISTS core.dim_department (
  dept_id int PRIMARY KEY,
  dept_name varchar(50)
);

CREATE TABLE IF NOT EXISTS core.dim_expense_category (
  exp_cat_id int PRIMARY KEY,
  category_name varchar(50)
);


CREATE SCHEMA IF NOT EXISTS stores;

CREATE TABLE IF NOT EXISTS stores.stores (
  store_id int PRIMARY KEY,
  store_name varchar(100),
  region_id int REFERENCES core.dim_region(region_id),
  city varchar(50),
  square_ft int,
  opening_date date
);

CREATE TABLE IF NOT EXISTS stores.employees (
  employee_id int PRIMARY KEY,
  store_id int REFERENCES stores.stores(store_id),
  first_name varchar(50),
  last_name varchar(50),
  email varchar(100),
  role varchar(50),
  dept_id int REFERENCES core.dim_department(dept_id),
  joining_date date,
  salary int
);

CREATE TABLE IF NOT EXISTS stores.expenses (
  store_expense_id int PRIMARY KEY,
  store_id int REFERENCES stores.stores(store_id),
  expense_type varchar(50),
  amount numeric(12,2),
  expense_date date
);


CREATE SCHEMA IF NOT EXISTS products;

CREATE TABLE IF NOT EXISTS products.suppliers (
  supplier_id int PRIMARY KEY,
  supplier_name varchar(100),
  contact_name varchar(100),
  city varchar(50),
  email varchar(100)
);

CREATE TABLE IF NOT EXISTS products.products (
  product_id int PRIMARY KEY,
  product_name varchar(150),
  brand_id int REFERENCES core.dim_brand(brand_id),
  supplier_id int REFERENCES products.suppliers(supplier_id),
  price numeric(12,2),
  cost_price numeric(12,2)
);

CREATE TABLE IF NOT EXISTS products.inventory (
  store_id int REFERENCES stores.stores(store_id),
  product_id int REFERENCES products.products(product_id),
  quantity_on_hand int,
  reorder_level int,
  PRIMARY KEY (store_id, product_id)
);

CREATE TABLE IF NOT EXISTS products.promotions (
  promo_id int PRIMARY KEY,
  promo_name varchar(100),
  discount_percent int,
  start_date date,
  end_date date,
  active boolean
);


CREATE SCHEMA IF NOT EXISTS customers;

CREATE TABLE IF NOT EXISTS customers.customers (
  customer_id int PRIMARY KEY,
  first_name varchar(50),
  last_name varchar(50),
  email varchar(100),
  phone varchar(20),
  registration_date date,
  tier varchar(20),
  tier_updated_at timestamp
);

CREATE TABLE IF NOT EXISTS customers.addresses (
  address_id int PRIMARY KEY,
  customer_id int REFERENCES customers.customers(customer_id),
  address_line text,
  city varchar(50),
  state varchar(50),
  pincode varchar(10),
  is_default boolean
);

CREATE TABLE IF NOT EXISTS customers.reviews (
  review_id int PRIMARY KEY,
  customer_id int REFERENCES customers.customers(customer_id),
  product_id int REFERENCES products.products(product_id),
  rating int CHECK (rating BETWEEN 1 AND 5),
  review_text text,
  review_date date
);

CREATE TABLE IF NOT EXISTS customers.loyalty_points (
  loyalty_id int PRIMARY KEY,
  customer_id int REFERENCES customers.customers(customer_id),
  points_earned int,
  source varchar(50),
  date_earned date
);


CREATE SCHEMA IF NOT EXISTS sales;

CREATE TABLE IF NOT EXISTS sales.orders (
  order_id int PRIMARY KEY,
  cust_id int REFERENCES customers.customers(customer_id),
  store_id int REFERENCES stores.stores(store_id),
  order_date date,
  order_status varchar(20),
  gross_total numeric(12,2),
  discount_amount numeric(12,2),
  net_total numeric(12,2),
  payment_mode_id int
);

CREATE TABLE IF NOT EXISTS sales.order_items (
  order_item_id int PRIMARY KEY,
  order_id int REFERENCES sales.orders(order_id),
  prod_id int REFERENCES products.products(product_id),
  quantity int,
  unit_price numeric(12,2),
  gross_amount numeric(12,2),
  discount_amount numeric(12,2),
  net_amount numeric(12,2)
);

CREATE TABLE IF NOT EXISTS sales.payments (
  payment_id int PRIMARY KEY,
  order_id int REFERENCES sales.orders(order_id),
  payment_date date,
  payment_mode varchar(30),
  amount numeric(12,2)
);

CREATE TABLE IF NOT EXISTS sales.shipments (
  shipment_id int PRIMARY KEY,
  order_id int REFERENCES sales.orders(order_id),
  courier_name varchar(50),
  shipped_date date,
  delivered_date date,
  status varchar(30)
);

CREATE TABLE IF NOT EXISTS sales.returns (
  return_id int PRIMARY KEY,
  order_id int REFERENCES sales.orders(order_id),
  prod_id int REFERENCES products.products(product_id),
  return_date date,
  reason text,
  refund_amount numeric(12,2)
);


CREATE SCHEMA IF NOT EXISTS finance;

CREATE TABLE IF NOT EXISTS finance.expenses (
  expense_id int PRIMARY KEY,
  expense_date date,
  exp_cat_id int REFERENCES core.dim_expense_category(exp_cat_id),
  amount numeric(12,2),
  description text
);

CREATE TABLE IF NOT EXISTS finance.revenue_summary (
  summary_id int PRIMARY KEY,
  summary_date date,
  total_revenue numeric(12,2),
  total_orders int,
  avg_order_value numeric(12,2)
);


CREATE SCHEMA IF NOT EXISTS hr;

CREATE TABLE IF NOT EXISTS hr.attendance (
  attendance_id int PRIMARY KEY,
  employee_id int REFERENCES stores.employees(employee_id),
  attendance_date date,
  check_in timestamp,
  check_out timestamp
);

CREATE TABLE IF NOT EXISTS hr.salary_history (
  payment_id int PRIMARY KEY,
  employee_id int REFERENCES stores.employees(employee_id),
  amount numeric(12,2),
  payment_date date,
  status varchar(20)
);


CREATE SCHEMA IF NOT EXISTS marketing;

CREATE TABLE IF NOT EXISTS marketing.campaigns (
  campaign_id int PRIMARY KEY,
  campaign_name varchar(100),
  start_date date,
  end_date date,
  budget numeric(12,2)
);

CREATE TABLE IF NOT EXISTS marketing.ads_spend (
  spend_id int PRIMARY KEY,
  campaign_id int REFERENCES marketing.campaigns(campaign_id),
  spend_date date,
  amount numeric(12,2),
  platform varchar(50)
);

CREATE TABLE IF NOT EXISTS marketing.email_clicks (
  email_id int PRIMARY KEY,
  campaign_id int REFERENCES marketing.campaigns(campaign_id),
  sent_date date,
  emails_sent int,
  emails_opened int,
  emails_clicked int
);


CREATE SCHEMA IF NOT EXISTS support;

CREATE TABLE IF NOT EXISTS support.tickets (
  ticket_id int PRIMARY KEY,
  customer_id int REFERENCES customers.customers(customer_id),
  agent_id int REFERENCES stores.employees(employee_id),
  category varchar(50),
  priority varchar(20),
  status varchar(20),
  created_date timestamp,
  resolved_date timestamp,
  subject text
);


CREATE SCHEMA IF NOT EXISTS web_events;

CREATE TABLE IF NOT EXISTS web_events.page_views (
  view_id int PRIMARY KEY,
  session_id varchar(50),
  customer_id int REFERENCES customers.customers(customer_id),
  page_url varchar(255),
  view_timestamp timestamp,
  device_type varchar(20),
  os varchar(20)
);

CREATE TABLE IF NOT EXISTS web_events.events (
  event_id int PRIMARY KEY,
  view_id int REFERENCES web_events.page_views(view_id),
  event_type varchar(50),
  element_id varchar(50),
  event_timestamp timestamp
);


CREATE SCHEMA IF NOT EXISTS supply_chain;

CREATE TABLE IF NOT EXISTS supply_chain.warehouses (
  warehouse_id int PRIMARY KEY,
  name varchar(100),
  location_city varchar(50),
  region varchar(20),
  capacity_sqft int,
  manager_name varchar(50)
);

CREATE TABLE IF NOT EXISTS supply_chain.shipments (
  shipment_id int PRIMARY KEY,
  supplier_id int REFERENCES products.suppliers(supplier_id),
  warehouse_id int REFERENCES supply_chain.warehouses(warehouse_id),
  product_id int REFERENCES products.products(product_id),
  quantity int,
  shipped_date date,
  arrival_date date,
  status varchar(20)
);

CREATE TABLE IF NOT EXISTS supply_chain.inventory_snapshots (
  warehouse_id int REFERENCES supply_chain.warehouses(warehouse_id),
  product_id int REFERENCES products.products(product_id),
  snapshot_date date,
  quantity_on_hand int,
  PRIMARY KEY (warehouse_id, product_id, snapshot_date)
);


CREATE SCHEMA IF NOT EXISTS loyalty;

CREATE TABLE IF NOT EXISTS loyalty.tiers (
  tier_id int PRIMARY KEY,
  tier_name varchar(20),
  min_points int,
  max_points int,
  benefits text
);

CREATE TABLE IF NOT EXISTS loyalty.members (
  customer_id int PRIMARY KEY REFERENCES customers.customers(customer_id),
  tier_id int REFERENCES loyalty.tiers(tier_id),
  points_balance int,
  join_date date
);

CREATE TABLE IF NOT EXISTS loyalty.redemptions (
  redemption_id int PRIMARY KEY,
  customer_id int REFERENCES customers.customers(customer_id),
  reward_name varchar(100),
  points_redeemed int,
  redemption_date date
);


CREATE SCHEMA IF NOT EXISTS manufacture;

CREATE TABLE IF NOT EXISTS manufacture.production_lines (
  line_id int PRIMARY KEY,
  line_name varchar(50),
  capacity_per_hour int,
  supervisor_name varchar(50)
);

CREATE TABLE IF NOT EXISTS manufacture.work_orders (
  work_order_id int PRIMARY KEY,
  product_id int REFERENCES products.products(product_id),
  line_id int REFERENCES manufacture.production_lines(line_id),
  start_timestamp timestamp,
  end_timestamp timestamp,
  quantity_produced int,
  rejected_quantity int,
  status varchar(20)
);


CREATE SCHEMA IF NOT EXISTS payroll;

CREATE TABLE IF NOT EXISTS payroll.tax_brackets (
  min_salary numeric(12,2),
  max_salary numeric(12,2),
  tax_rate numeric(4,2)
);

CREATE TABLE IF NOT EXISTS payroll.pay_slips (
  pay_slip_id int PRIMARY KEY,
  employee_id int REFERENCES stores.employees(employee_id),
  salary_month varchar(20),
  salary_year int,
  basic_salary numeric(12,2),
  hra numeric(12,2),
  other_allowances numeric(12,2),
  pf numeric(12,2),
  professional_tax numeric(12,2),
  income_tax numeric(12,2),
  gross_salary numeric(12,2),
  net_salary numeric(12,2),
  payment_date date
);


CREATE SCHEMA IF NOT EXISTS call_center;

CREATE TABLE IF NOT EXISTS call_center.calls (
  call_id int PRIMARY KEY,
  customer_id int REFERENCES customers.customers(customer_id),
  agent_id int REFERENCES stores.employees(employee_id),
  call_start_time timestamp,
  call_duration_seconds int,
  call_reason varchar(50),
  status varchar(20)
);

CREATE TABLE IF NOT EXISTS call_center.transcripts (
  transcript_id int PRIMARY KEY,
  call_id int REFERENCES call_center.calls(call_id),
  transcript_text text,
  sentiment_score numeric(4,2)
);


CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE IF NOT EXISTS audit.application_logs (
  log_id int PRIMARY KEY,
  timestamp timestamp,
  service_name varchar(50),
  level varchar(10),
  message text,
  trace_id varchar(50)
);

CREATE TABLE IF NOT EXISTS audit.api_requests (
  request_id text,
  timestamp timestamp,
  endpoint varchar(100),
  method varchar(10),
  status_code int,
  response_time_ms int,
  user_agent text
);

CREATE TABLE IF NOT EXISTS audit.record_changes (
  change_id int PRIMARY KEY,
  table_name varchar(50),
  record_id int,
  column_name varchar(50),
  old_value text,
  new_value text,
  changed_by int REFERENCES stores.employees(employee_id),
  changed_at timestamp,
  action varchar(10)
);



-- -- New tables for Batch 26+ curriculum --

CREATE TABLE IF NOT EXISTS finance.payment_modes (
  mode_id SERIAL PRIMARY KEY,
  mode_name VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS finance.accounts (
  account_id SERIAL PRIMARY KEY,
  account_holder VARCHAR(100),
  account_type VARCHAR(20),
  balance NUMERIC(14,2),
  created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS finance.transfer_log (
  transfer_id SERIAL PRIMARY KEY,
  from_account INT REFERENCES finance.accounts(account_id),
  to_account INT REFERENCES finance.accounts(account_id),
  amount NUMERIC(14,2),
  transferred_at TIMESTAMP,
  status VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS finance.payments (
  payment_id INT PRIMARY KEY,
  order_id INT REFERENCES sales.orders(order_id),
  cust_id INT,
  amount NUMERIC(14,2),
  status VARCHAR(20),
  refund_reason TEXT,
  refunded_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS customers.wallets (
  wallet_id SERIAL PRIMARY KEY,
  cust_id INT REFERENCES customers.customers(customer_id),
  balance NUMERIC(14,2) DEFAULT 0,
  last_updated TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit.refund_log (
  refund_id SERIAL PRIMARY KEY,
  payment_id INT,
  order_id INT,
  amount NUMERIC(14,2),
  reason TEXT,
  refunded_at TIMESTAMP,
  status VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS audit.refund_failures (
  failure_id SERIAL PRIMARY KEY,
  payment_id INT,
  error_message TEXT,
  failed_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit.procedure_calls (
  call_id SERIAL PRIMARY KEY,
  proc_name VARCHAR(200),
  input_params JSONB,
  outcome VARCHAR(20),
  error_state VARCHAR(10),
  error_message TEXT,
  duration_ms INT,
  called_at TIMESTAMP
);

\echo 'Loading data from datasets/csv...'
\copy core.dim_date FROM 'datasets/v3/csv/core/dim_date.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy core.dim_region FROM 'datasets/v3/csv/core/dim_region.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy core.dim_category FROM 'datasets/v3/csv/core/dim_category.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy core.dim_brand FROM 'datasets/v3/csv/core/dim_brand.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy core.dim_department FROM 'datasets/v3/csv/core/dim_department.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy core.dim_expense_category FROM 'datasets/v3/csv/core/dim_expense_category.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy stores.stores FROM 'datasets/v3/csv/stores/stores.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy stores.employees FROM 'datasets/v3/csv/stores/employees.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy stores.expenses FROM 'datasets/v3/csv/stores/expenses.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy products.suppliers FROM 'datasets/v3/csv/products/suppliers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy products.products FROM 'datasets/v3/csv/products/products.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy products.inventory FROM 'datasets/v3/csv/products/inventory.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy products.promotions FROM 'datasets/v3/csv/products/promotions.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy customers.customers FROM 'datasets/v3/csv/customers/customers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy customers.addresses FROM 'datasets/v3/csv/customers/addresses.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy customers.reviews FROM 'datasets/v3/csv/customers/reviews.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy customers.loyalty_points FROM 'datasets/v3/csv/customers/loyalty_points.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy sales.orders FROM 'datasets/v3/csv/sales/orders.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy sales.order_items FROM 'datasets/v3/csv/sales/order_items.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy sales.payments FROM 'datasets/v3/csv/sales/payments.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy sales.shipments FROM 'datasets/v3/csv/sales/shipments.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy sales.returns FROM 'datasets/v3/csv/sales/returns.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy finance.expenses FROM 'datasets/v3/csv/finance/expenses.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy finance.revenue_summary FROM 'datasets/v3/csv/finance/revenue_summary.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy hr.attendance FROM 'datasets/v3/csv/hr/attendance.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy hr.salary_history FROM 'datasets/v3/csv/hr/salary_history.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy marketing.campaigns FROM 'datasets/v3/csv/marketing/campaigns.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy marketing.ads_spend FROM 'datasets/v3/csv/marketing/ads_spend.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy marketing.email_clicks FROM 'datasets/v3/csv/marketing/email_clicks.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy support.tickets FROM 'datasets/v3/csv/support/tickets.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy web_events.page_views FROM 'datasets/v3/csv/web_events/page_views.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy web_events.events FROM 'datasets/v3/csv/web_events/events.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy supply_chain.warehouses FROM 'datasets/v3/csv/supply_chain/warehouses.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy supply_chain.shipments FROM 'datasets/v3/csv/supply_chain/shipments.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy supply_chain.inventory_snapshots FROM 'datasets/v3/csv/supply_chain/inventory_snapshots.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy loyalty.tiers FROM 'datasets/v3/csv/loyalty/tiers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy loyalty.members FROM 'datasets/v3/csv/loyalty/members.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy loyalty.redemptions FROM 'datasets/v3/csv/loyalty/redemptions.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy manufacture.production_lines FROM 'datasets/v3/csv/manufacture/production_lines.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy manufacture.work_orders FROM 'datasets/v3/csv/manufacture/work_orders.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy payroll.tax_brackets FROM 'datasets/v3/csv/payroll/tax_brackets.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy payroll.pay_slips FROM 'datasets/v3/csv/payroll/pay_slips.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy call_center.calls FROM 'datasets/v3/csv/call_center/calls.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy call_center.transcripts FROM 'datasets/v3/csv/call_center/transcripts.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy audit.application_logs FROM 'datasets/v3/csv/audit/application_logs.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy audit.api_requests FROM 'datasets/v3/csv/audit/api_requests.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy audit.record_changes FROM 'datasets/v3/csv/audit/record_changes.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');

\copy finance.payment_modes FROM 'datasets/v3/csv/finance/payment_modes.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy finance.accounts FROM 'datasets/v3/csv/finance/accounts.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy finance.transfer_log FROM 'datasets/v3/csv/finance/transfer_log.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy finance.payments FROM 'datasets/v3/csv/finance/payments.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy customers.wallets FROM 'datasets/v3/csv/customers/wallets.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy audit.refund_log FROM 'datasets/v3/csv/audit/refund_log.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy audit.refund_failures FROM 'datasets/v3/csv/audit/refund_failures.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
\copy audit.procedure_calls FROM 'datasets/v3/csv/audit/procedure_calls.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');

ALTER TABLE sales.orders ADD CONSTRAINT fk_orders_payment_mode FOREIGN KEY (payment_mode_id) REFERENCES finance.payment_modes(mode_id);

\echo ' Setup Complete! Connected to accio_retailmart_'
\dt *.*