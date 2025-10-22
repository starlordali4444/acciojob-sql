-- selecting all the rows

select * 
    from products.products;

-- Select only those rows where price >2000

SELECT
    *
FROM products.products
    where price >2000;

-- select all the products for Electronics and price <5000

SELECT
    *
FROM products.products
    WHERE price <5000 and category = 'Electronics';

-- All the customers from Punjab
select
    *
FROM customers.customers
    where state = 'Punjab';

-- All the customers not from Punjab
select
    *
FROM customers.customers
    where state <> 'Punjab';

select
    *
FROM customers.customers
    where state != 'Punjab';

select
    *
FROM customers.customers
    where not state='Punjab';

-- All the customers from delhi or mumbai

select
    *
FROM customers.customers
    where city='Delhi' or city ='Mumbai';

select
    *
FROM customers.customers
    where city='Delhi' or city ='Mumbai' or city = 'Imphal' or city = 'Bhopal' or city = 'Thane';

select
    *
FROM customers.customers
    where city in ('Delhi','Mumbai','Imphal','Bhopal','Thane');

select
    *
FROM customers.customers
    where city not in ('Delhi','Mumbai','Imphal','Bhopal','Thane');



select
    DISTINCT city
FROM customers.customers;

BETWEEN
LIKE
IS NULL
LIMIT OFFSET