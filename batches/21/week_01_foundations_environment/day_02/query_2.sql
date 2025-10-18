-- customer_orders(cust_id,cust_name,city,product_1,price_1,product_2,price_2)

set search_path to daily;

create table employee_projects_1nf(
	emp_id int,
	emp_name varchar(50),
	dept_name varchar(30),
	project_name varchar(50),
	client_name varchar(50)	
); 

INSERT INTO employee_projects_1NF VALUES
(101, 'Rahul Sharma', 'IT', 'Payroll System', 'Infosys'),
(101, 'Rahul Sharma', 'IT', 'HR Portal', 'TCS'),
(102, 'Neha Verma', 'HR', 'Recruitment App', 'Wipro');

Select * from employee_projects_1NF;


create table employees (
	emp_id serial primary key,
	emp_name varchar(50),
	dept_name varchar(30)
);

create table projects(
	project_id serial primary key,
	project_name varchar(50),
	clent_name varchar(30)
);

create table emp_project_map(
	emp_id int references employees(emp_id),
	project_id int references projects(project_id)
);














