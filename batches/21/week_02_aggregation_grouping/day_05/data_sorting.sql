-- ORDER BY

-- Show all the customers name in alphabetic ORDER

SELECT 
    DISTINCT full_name
FROM
    customers.customers

SELECT 
    DISTINCT full_name
FROM
    customers.customers
ORDER BY
    full_name

-- Give unique customer name in descending Order
SELECT 
    DISTINCT full_name
FROM
    customers.customers
ORDER BY
    full_name DESC

-- Select first 5 customer name

SELECT 
    DISTINCT full_name
FROM
    customers.customers
LIMIT 5

-- Select First 5 customer in ascending order
SELECT 
    DISTINCT full_name
FROM
    customers.customers
ORDER BY
    full_name
LIMIT 5

-- Select First 5 customer in descending order
SELECT 
    DISTINCT full_name
FROM
    customers.customers
ORDER BY
    full_name DESC
LIMIT 5


-- Select unique combination of State and city

SELECT 
    DISTINCT state,city
FROM
    customers.customers

-- Select unique combination of State and city in order
    -- State in ascending
    -- City in descending

SELECT 
    DISTINCT state,city
FROM
    customers.customers
ORDER BY
    state ASC,
    city DESC

-- Select customers from id 6 to 10
SELECT 
    *
FROM
    customers.customers
LIMIT 5
OFFSET 5

-- Select customers from id 51 to 100
SELECT 
    *
FROM
    customers.customers
LIMIT 50
OFFSET 50


-- Sorting
--     LIMIT
--         ASC
--         DESC
--     OFFSET Tell from which record we have to start