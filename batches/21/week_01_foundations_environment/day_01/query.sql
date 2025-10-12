-- 1️⃣ Create a new database
CREATE DATABASE retailmart;
\c retailmart;

-- 2️⃣ Create first table
CREATE TABLE products (
    prod_id SERIAL PRIMARY KEY,
    prod_name VARCHAR(50),
    price NUMERIC(10,2)
);

-- 3️⃣ Insert sample data
INSERT INTO products (prod_name, price)
VALUES 
('Rice 10 kg', 550),
('Oil 5 L', 720),
('Atta 10 kg', 480);

-- 4️⃣ Retrieve data
SELECT * FROM products;

-- 5️⃣ Simple filter & sort
SELECT prod_name, price
FROM products
WHERE price > 500
ORDER BY price DESC;
