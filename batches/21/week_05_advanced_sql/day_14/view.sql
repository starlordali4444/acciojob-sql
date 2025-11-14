Views

	CREATE VIEW view_name AS
	SELECT column1, column2, ...
	FROM table_name
	WHERE condition;

	CREATE [OR REPLACE] VIEW schema_name.view_name AS
	SELECT 
	    column_list,
	    calculated_columns
	FROM base_table(s)
	[JOIN other_tables ON conditions]
	WHERE filter_conditions
	GROUP BY grouping_columns
	HAVING aggregate_conditions
	ORDER BY sorting_columns;


-- Priya works in RetailMart's CRM team. She needs to see customer list with their regions daily for targeted campaigns.

Select 
	distinct join_date
from
	customers.customers
order by join_date desc;


create view customers.vw_active_customer_current_year as
Select 
	*
from
	customers.customers
where extract(year from join_date) = extract(year from current_date);



select * from customers.vw_active_customer_current_year

delete from customers.vw_active_customer_current_year
where cust_id =569


create schema day_14;


create table day_14.ex_1 (id int , name text);

create view day_14.vw_ex_1 as
SELECT id, name
	FROM day_14.ex_1;

select * from day_14.vw_ex_1

delete from day_14.vw_ex_1 where id = 1

create view day_14.vw_ex_2 as
SELECT id, name
	FROM day_14.ex_1
UNION ALL
SELECT id, name
	FROM day_14.ex_1;


select * from day_14.vw_ex_2;


delete from day_14.vw_ex_2 where id = 2



create view day_14.vw_ex_3 as
SELECT *
	FROM day_14.vw_ex_2
	where id = 2;


select * from day_14.vw_ex_3

delete from day_14.vw_ex_3 where id = 2



-- Amit manages RetailMart's product catalog. He needs product list with supplier information frequently.

create or replace view products.vw_product_catalogue as
Select p.*,s.supplier_name
	from products.products p
inner join products.suppliers s
	on p.supplier_id=s.supplier_id;


select * from products.vw_product_catalogue;

-- Operations team needs complete order information - customer details, store info, products, payments, shipments - all in one place.
CREATE VIEW sales.vw_order_complete_details as 
SELECT
	-- Order Information
	o.order_id,
	o.order_date,
	o.order_status,
	o.total_amount,
	--Customer Information
	c.cust_id,
	c.full_name as customer_name,
	c.city as customer_city,
	c.state as customer_state,
	c.region_name,
	-- Store Information
	s.store_id,
	s.store_name,
	s.city as store_city,
	s.state as store_state,
	s.region,
	-- Orde Items
	count(DISTINCT oi.prod_id) as unique_products,
	sum(oi.quantity) as total_items,
	sum(oi.quantity* oi.unit_price) as gross_amount,
	sum(oi.quantity* oi.discount) as total_discount,
	--Payment Information
	py.payment_id,
	py.payment_date,
	py.payment_mode,
	py.amount as payment_amount,
	--Shipment Information
	sh.shipment_id,
	sh.courier_name,
	sh.shipped_date,
	sh.delivered_date,
	sh.status as shipment_status,
	-- Custom KPI
	CASE
		WHEN sh.delivered_date IS NOT NULL
		THEN sh.delivered_date - o.order_date
		ELSE NULL
	END as delivery_days,
	CASE
		WHEN o.order_status = 'Delivered' AND sh.delivered_date <=o.order_date + INTERVAL '3 Days'
		THEN 'On Time'
		WHEN o.order_status = 'Delivered' AND sh.delivered_date > o.order_date + INTERVAL '3 Days'
		THEN 'Delayed'
		ELSE 'In Progress'
	END as delivery_performance
FROM sales.orders o
JOIN customers.customers c ON c.cust_id = o.cust_id
JOIN stores.stores s ON s.store_id = o.store_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
-- JOIN products.products p ON p.prod_id = oi.prod_id
JOIN sales.payments py ON py.order_id = o.order_id
JOIN sales.shipments sh ON sh.order_id = o.order_id
GROUP BY
	o.order_id,o.order_date,o.order_status,o.total_amount,c.cust_id,c.full_name,c.city,c.state,c.region_name,
	s.store_id,s.store_name,s.city,s.state,s.region,py.payment_id,py.payment_date,py.payment_mode,py.amount,
	sh.shipment_id,sh.courier_name,sh.shipped_date,sh.delivered_date,sh.status;

When we have to update view we cant use Update Clause however we can use Case clause to update the data.
UPDATE customers.customers
SET customer_name = 'Yogendra'
Where cust_id = 5

Case when cust_id = 5 THEN 'Yogendra'
else customer_name
end as customer_name



Select * from sales.vw_order_complete_details
where 


















