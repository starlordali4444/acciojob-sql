-- DDL Create

create table products(
	prod_id serial PRIMARY KEY,
	prod_name varchar(50),
	category varchar(30),
	price numeric(10,2),
	discount real,
	stock int
);

create table daily.products(
	prod_id serial PRIMARY KEY,
	prod_name varchar(50),
	category varchar(30),
	price numeric(10,2),
	discount real,
	stock int
);

insert into products (prod_name,category,price,discount,stock)
values('Basmati Rice 10 kg','Grocery','550.75',0.05,200);

-- DML 
-- insert into <schema>.<table> (prod_name,category,price,discount,stock)
-- values('Basmati Rice 10 kg','Grocery',550.75,0.05,200)
-- Ctrl /

insert into daily.products (prod_name,category,price,discount,stock)
values('Basmati Rice 2 kg','Grocery',5000.5634,0.05,200);

-- Switch Schema
set search_path to daily;

-- DQL 
Select * from products;

create table customers (
	cust_id serial primary key,
	name varchar(50) not null,
	city varchar(30),
	address text
);

-- Date Time

create table orders (
	order_id serial primary key,
	cust_id int,
	order_date date default current_date,
	delivery_timestamp timestamp default NOW(),
	expected_delivery interval
);

insert into orders (cust_id,expected_delivery)
values(1,Interval '3 days');

Select * from orders;






















