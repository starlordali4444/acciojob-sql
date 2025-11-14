CREATE SCHEMA day_11;

Placing an order

CREATE TABLE day_11.retail_orders (
    order_id int PRIMARY key,
    cust_id text,
    amount NUMERic(10,2)
);

SELECT * FROM day_11.retail_orders;

-- Step 1
BEGIN;

-- Step 2
INSERT INTO day_11.retail_orders VALUES (1,'Ramesh',1200.00);

-- Step 3
COMMIT;

INSERT INTO day_11.retail_orders VALUES (2,'Ram',1100.00);

DELETE FROM day_11.retail_orders where order_id =1

BEGIN;

DELETE FROM day_11.retail_orders where order_id =1;

ROLLBACK;


set search_path to day_11;

show search_path;

CREATE TABLE retail_payments(
    pay_id int PRIMARY KEY,
    order_id int,
    pay_mode VARCHAR(20),
    amount NUMERIC(10,2)
);

SELECT * FROM retail_orders;
SELECT * FROM retail_payments;

-- transaction Started
BEGIN;
--  Order Placed
INSERT INTO day_11.retail_orders VALUES (3,'Arpit',900.00);
-- Inserted the details
SAVEPOINT after_order;
-- Savepoint created for order
INSERT INTO retail_payments VALUES (101,3,'UPI',900.00);
-- inserted payment information
-- Payment failed
ROLLBACK TO after_order;

COMMIT;


CREATE TABLE retail_inventory (
    prod_id int PRIMARY KEY,
    stock int
);

SELECT * FROM retail_orders;
SELECT * FROM retail_payments;
SELECT * FROM retail_inventory;

INSERT INTO retail_inventory VALUES (1,50);

-- Begin TRANSACTION
BEGIN;

UPDATE retail_inventory
    SET stock =stock-5
    WHERE prod_id=1;

INSERT INTO retail_orders VALUES (4,'Archana',5000.00);

COMMIT;

BEGIN;

SAVEPOINT before_scan;

UPDATE retail_inventory
    SET stock =stock-5
    WHERE prod_id=1;

INSERT INTO retail_orders VALUES (5,'Arun',5000.00);

ROLLBACK to before_scan;

COMMIT;

SELECT * FROM test_table

BEGIN;

CREATE TABLE test_table(id int);

COMMIT;

-- Transactions in SQL are like Indian weddings
--     there’s a BEGIN (engagement)
--     SAVEPOINT (mehndi, haldi checkpoints)
--     COMMIT (wedding done)
--     ROLLBACK (if families fight before the pheras 😂)

-- once you reach CREATE MARRIAGE TABLE, my friend, that’s DDL — no rollback!” 💍🔥


SELECT * from test_acid_demo;