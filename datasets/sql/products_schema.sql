
CREATE SCHEMA IF NOT EXISTS products;

CREATE TABLE IF NOT EXISTS products.suppliers (
  supplier_id int PRIMARY KEY,
  supplier_name varchar(100)
);

CREATE TABLE IF NOT EXISTS products.products (
  prod_id int PRIMARY KEY,
  prod_name varchar(150),
  category varchar(50),
  brand varchar(50),
  supplier_id int REFERENCES products.suppliers(supplier_id),
  price numeric(12,2)
);

CREATE TABLE IF NOT EXISTS products.inventory (
  store_id int,
  prod_id int REFERENCES products.products(prod_id),
  stock_qty int,
  last_updated date,
  PRIMARY KEY (store_id, prod_id)
);

CREATE TABLE IF NOT EXISTS products.promotions (
  promo_id int PRIMARY KEY,
  promo_name varchar(50),
  start_date date,
  end_date date,
  discount_percent numeric(6,2)
);
