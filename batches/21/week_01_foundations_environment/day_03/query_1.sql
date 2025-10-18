--  see all schemas

show search_path;


--  Select required schema

set search_path to core;

select * from dim_brand;

set search_path to hr;

select * from salary_history;

set search_path to sales;

-- selecting all the data set orders table
select * from orders;















