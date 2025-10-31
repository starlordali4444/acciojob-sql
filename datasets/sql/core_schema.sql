
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
  category_name varchar(50)
);
