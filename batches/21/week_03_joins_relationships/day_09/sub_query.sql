-- Find customers who placed at least one order.

Tables
    customers   =>  We will get customer details 
    orders      =>  

customers   =>  500
orders      =>  200

Select count(DISTINCT cust_id) from customers.customers;

Select count(DISTINCT cust_id) from sales.orders;

Select full_name from customers.customers;


Table 1  => 10
Table 2  => 20

Select  distinct c.full_name
from customers.customers c
INNER join sales.orders o
    on c.cust_id = o.cust_id;

SELECT full_name
FROM
    customers.customers
WHERE
    cust_id in (SELECT distinct cust_id  from sales.orders);

Find employees earning above the average salary.

Step 1  =>  Calculate the average salary
Step 2  =>  Compare the Calculated salary for all employees

select * from "hr"."salary_history"

select avg(salary) from "stores"."employees"
    68749.586000000000

SELECT employees.emp_name,employees.salary
from stores.employees
WHERE employees.salary > 68749.586

SELECT employees.emp_name,employees.salary
from stores.employees
WHERE employees.salary > (select avg(salary) from "stores"."employees")

Find products that were never ordered.
    Which cousins didn’t come to Diwali party this year?
        List Of All Counsins
        - Who have attended

Tables
    products.products
    sales.order_items

select products.prod_name
from products.products
WHERE
    products.prod_id not in (
        SELECT order_items.prod_id from sales.order_items
    )

Select count(DISTINCT prod_id) from products.products
Select count(DISTINCT prod_id) from sales.order_items


Find employees whose salary is above average of their department (Correlated).

Dept 
    Dept 1 
    Dept 2
    Dept 3

SELECT dept_id,avg(salary)
from
    stores.employees 
group by dept_id

SELECT emp_name,dept_id,salary
from stores.employees o_e
WHERE salary >(
    SELECT avg(i_e.salary)
    from stores.employees i_e
    WHERE
        i_e.dept_id=o_e.dept_id
)
order by o_e.dept_id

Find stores whose total sales are above the average sales across all stores.
    Which house served more food than the average across all homes in the colony?

Step 1  =>  Average sales across all the Stores
Step 2  =>  Compare the sales of each store with average store
    Data was available directly in the TABLE
    we have to transform data for our use

select * from sales.orders o


select avg(total_sales) 
from (
    select store_id,sum(total_amount) total_sales
    from sales.orders
    group by store_id
) o


select store_id,sum(total_amount) total_sales
from sales.orders
group by store_id
HAVING sum(total_amount) > 252599612.75875000



select store_id,sum(total_amount) total_sales
from sales.orders
group by store_id
HAVING sum(total_amount) > (
    select avg(total_sales) 
    from (
        select store_id,sum(total_amount) total_sales
        from sales.orders
        group by store_id
    ) o
)

select store_id,sum(total_amount) total_sales
from sales.orders
group by store_id
HAVING sum(total_amount) > (
    select avg(total_amount) 
        from sales.orders
)

Find employees who are the highest earners in their department.

SELECT emp_name,dept_id,salary
from stores.employees o_e
WHERE salary >(
    SELECT avg(i_e.salary)
    from stores.employees i_e
    WHERE
        i_e.dept_id=o_e.dept_id
)
order by o_e.dept_id

SELECT emp_name,dept_id,salary
from stores.employees o_e
WHERE salary =(
    SELECT max(i_e.salary)
    from stores.employees i_e
    WHERE
        i_e.dept_id=o_e.dept_id
)
order by o_e.dept_id

SELECT emp_name,dept_id,max(salary)
from stores.employees o_e
group by dept_id