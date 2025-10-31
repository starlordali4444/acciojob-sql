

select * from customers.customers
    -- ROWS    =>  50000
    -- Columns =>  8
UNION ALL
select * from customers.addresses
    -- ROWS    =>  74892
    -- Columns =>  7


select state,city from customers.customers
union all
select state,city from customers.addresses

select city,state from customers.customers
union all
select state,city from customers.addresses

give me unique combination of state and city from address and customers

select distinct state,city from customers.customers
union all
select distinct state,city from customers.addresses

select state,city from customers.customers
union 
select state,city from customers.addresses


-- → Lists all products with order/return status.

select distinct prod_id,'Ordered' as status from sales.order_items
UNION ALL
select distinct prod_id,'Returned' as status from sales.returns

select distinct prod_id,'Ordered' as status from sales.order_items
UNION
select distinct prod_id,'Returned' as status from sales.returns

select distinct 'Ordered' as status,prod_id from sales.order_items
UNION
select distinct prod_id,'Returned' as status from sales.returns

-- Merges active buyers and reviewers for marketing insights.

select * from customers.customers

select distinct cust_id,'Active Buyer' as cust_type from sales.orders --47518
UNION ALL
select distinct cust_id,'Active Reviewer' as cust_type  from customers.reviews --22562


select cust_id,'Active Buyer' as cust_type from sales.orders --150000
UNION
select cust_id,'Active Reviewer' as cust_type  from customers.reviews --30000

select cust_id,'Active Buyer' as cust_type from sales.orders --150000
UNION ALL
select cust_id,'Active Reviewer' as cust_type  from customers.reviews --30000



select 'Total' as Cust_Type,COUNT(distinct cust_id) as No_Of_Customers from customers.customers
UNION
select 'Active Buyer' as Cust_type,COUNT(distinct cust_id) as No_Of_Customers from sales.orders --47518
UNION
select 'Active Reviewer' as Cust_type,COUNT(distinct cust_id) as No_Of_Customers  from customers.reviews --22562










