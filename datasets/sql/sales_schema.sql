
CREATE SCHEMA IF NOT EXISTS sales;

CREATE TABLE IF NOT EXISTS sales.orders (
  order_id int PRIMARY KEY,
  cust_id int REFERENCES customers.customers(cust_id),
  store_id int REFERENCES stores.stores(store_id),
  order_date date,
  order_status varchar(20),
  total_amount numeric(12,2)
);

CREATE TABLE IF NOT EXISTS sales.order_items (
  order_item_id int PRIMARY KEY,
  order_id int REFERENCES sales.orders(order_id),
  prod_id int REFERENCES products.products(prod_id),
  quantity int,
  unit_price numeric(12,2),
  discount numeric(6,2)
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
  prod_id int REFERENCES products.products(prod_id),
  return_date date,
  reason text,
  refund_amount numeric(12,2)
);
