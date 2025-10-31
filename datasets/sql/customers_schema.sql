
CREATE SCHEMA IF NOT EXISTS customers;

CREATE TABLE IF NOT EXISTS customers.customers (
  cust_id int PRIMARY KEY,
  full_name varchar(100),
  gender char(1),
  age int,
  city varchar(50),
  state varchar(50),
  join_date date,
  region_name varchar(20)
);

CREATE TABLE IF NOT EXISTS customers.addresses (
  address_id int PRIMARY KEY,
  cust_id int REFERENCES customers.customers(cust_id),
  address_type varchar(20),
  street varchar(100),
  city varchar(50),
  state varchar(50),
  postal_code varchar(10)
);

CREATE TABLE IF NOT EXISTS customers.reviews (
  review_id int PRIMARY KEY,
  cust_id int REFERENCES customers.customers(cust_id),
  prod_id int,
  rating int CHECK (rating BETWEEN 1 AND 5),
  review_date date,
  review_text text
);

CREATE TABLE IF NOT EXISTS customers.loyalty_points (
  cust_id int PRIMARY KEY REFERENCES customers.customers(cust_id),
  total_points int,
  last_updated date
);
