--  see all schemas

show search_path;


--  Select required schema

set search_path to core;

select * from dim_brand;

set search_path to hr;

select * from salary_history;

set search_path to sales;

-- selecting all the data set orders table
select 				-- select the columns
	*  				-- * => all / all columns
from orders;		-- from selectes the table



--  select only order_id, order_status, total_amount
select
	order_id,order_status,total_amount
from orders;


-- select order_status, order_id, total_amount
select
	order_status,order_id,total_amount
from orders;


-- select order_status, order_id, total_amount order them accordingly to order_status

select
	order_status,

















