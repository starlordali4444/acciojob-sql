-- Show selected database
select current_database();

-- Show selected Schema
show search_path;

-- Change the schema
set search_path to daily;

-- NOT NULL
--  Example 1 => Basic not null

drop table if exists nn_ex_1;
create table nn_ex_1(
	id serial primary key,
	dept_name varchar(50) not null
);

-- Insert Rows
insert into nn_ex_1 (dept_name) values('HR');		-- ✅ ok
insert into nn_ex_1 (dept_name) values(NULL);		-- ❌ not null violation

select * from nn_ex_1;

-- Example 2 => Multiple not null columns

drop table if exists nn_ex_2;
create table nn_ex_2(
	name text not null,
	email text not null,
	city text	
);

insert into nn_ex_2 values ('Ali','ali.shiraj@gmail.com');		-- ✅ ok
insert into nn_ex_2 values (NULL,'a@b.com','Mumbai');			-- ❌ not null violation
insert into nn_ex_2 values ('Lucknow','Ali','ali.shiraj@gmail.com');

select * from nn_ex_2;


-- Example 3 => Add Not null Later

create table nn_ex_3(phone text);

insert into nn_ex_3 values(NULL),('98745613');

update nn_ex_3
	set phone = 'unknown'
	where phone is null;


select 
	*
from nn_ex_3
	where phone is null;

-- Change the structure of the table
alter table nn_ex_3 alter column phone set not null;

-- Example 4 => not null + Default

create table nn_ex_4(
	created_on timestamp not null default current_timestamp
);

insert into nn_ex_4 default values;

select 
	*
from 
	nn_ex_4;




