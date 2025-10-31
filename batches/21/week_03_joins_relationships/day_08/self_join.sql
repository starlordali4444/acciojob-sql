Shows employees working in the same department.

Identify
    required Columns
        emp_name, dept
    required tables
        employees, department
    transform the data

select * from stores.employees;
clerk => assistant manager
assitant manager => assistant manager

COLUMN => reports_to

select dept_id,emp_name 
from stores.employees
ORDER BY dept_id,emp_name;


SELECT
    a.emp_id,
    a.emp_name,
    a.role,
    b.emp_name as manager,
    b.role as manager_role,
    a.dept_id
FROM
    stores.employees a
JOIN
    stores.employees b
ON
    a.dept_id=b.dept_id             -- 15 Lakh
    AND a.emp_id <> b.emp_id        -- 13 Lakh
    and a.role <> b.role            -- 10 Lakh
    and a.store_id = b.store_id     -- 6.5 k
ORDER BY
    a.dept_id,a.emp_name
LIMIT
    100;

-- Create the employees table
CREATE TABLE daily.employee (
    emp_id      SERIAL PRIMARY KEY,
    emp_name    VARCHAR(100) NOT NULL,
    role        VARCHAR(50)  NOT NULL,
    salary      NUMERIC(10,2),
    dept_id     INT,
    store_id    INT,
    reports_to  INT
);

INSERT INTO daily.employee (emp_name, role, salary, dept_id, store_id, reports_to) VALUES
('Muskan Subramaniam', 'Inventory Clerk', 69019.00, 4, 1, NULL),     -- Top-level (no manager)
('Lokesh Mehta', 'Sales Executive', 69583.00, 3, 9, 1),
('Nikhil Zaveri', 'Customer Service Rep', 107287.00, 2, 135, 1),
('Preeti Bedi', 'Cashier', 45924.00, 6, 8, 2),
('Anjali Ali', 'Marketing Associate', 62008.00, 1, 77, 2),
('Urvi Subramanian', 'Customer Service Rep', 99221.00, 3, 29, 3),
('Tanmay Patel', 'Store Manager', 88610.00, 1, 165, 3),
('Lokesh Shetty', 'Cashier', 114161.00, 1, 162, 5),
('Suraj Parmar', 'HR Executive', 45867.00, 2, 187, 5),
('Omkar Shah', 'Customer Service Rep', 73270.00, 3, 99, 4),
('Pankaj Tandon', 'Finance Executive', 22655.00, 2, 166, 8);

select * from daily.employee;

SELECT
    e.emp_name,
    e.role,
    m.emp_name as manager,
    m.role as manager_role,
    m.emp_id as manager_id,
    e.reports_to as emp_manager_id
FROM    
    daily.employee e
JOIN
    daily.employee m
ON
    e.reports_to=m.emp_id

-- Finds pairs of cities in the same state.
UP
    Lucknow
    Kanpur
    Agra

    Lucknow - Lucknow
    Lucknow - Kanpur
    Lucknow - Agra

    Kanpur - Kanpur
    Kanpur - Agra
    Kanpur - Lucknow


SELECT * from customers.addresses limit 10;

cell Address    => unique identifier for each cell
A1 => Siraj

with combined_data as (
    select
        c1.city as c1_city,c2.city as c2_city
    FROM    
        customers.addresses c1
    JOIN
        customers.addresses c2
    ON
        c1.state = c2.state
        AND c1.city < c2.city
)
select distinct count(*) from combined_data

WITH
    distinct_city as(
        select distinct state,city from customers.addresses
    )
select
    c1.city,c2.city
FROM    
    distinct_city c1
JOIN
    distinct_city c2
ON
    c1.state = c2.state
    AND c1.city < c2.city

Identifies senior–junior pairs within each department.

select * from stores.employees;

Fresher 0 1st Jan 2026
11 Yrs    1st Jan 2026

SELECT
    s.emp_name as s_emp_name,
    s.salary as s_salary,
    j.emp_name j_emp_name,
    j.salary as j_salary
FROM
    stores.employees s
JOIN
    stores.employees j
ON
    s.dept_id = j.dept_id
    AND s.store_id = j.store_id
    AND s.salary > j.salary
ORDER BY
    s_emp_name

