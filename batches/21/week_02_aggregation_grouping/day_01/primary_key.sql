set search_path to daily;

-- Primary Key => UNIQUE + NOT NULL + SERIAL

-- if we have created a table => table_1  -> id not null,unique | table_2 -> id primary key |  => Indexing | Refrencing | One Primary per table

-- Example 1 => Simple Primary Key
CREATE TABLE pk_ex_1(
    id serial primary key,
    name TEXT
);

INSERT INTO pk_ex_1 (name) VALUES('ram');
insert into pk_ex_1 (id,name) VALUES(2,'Rohan_dup');
insert into pk_ex_1 (id,name) VALUES(NULL,'Rohan_dup');

SELECT * from pk_ex_1;

-- Example 2  => Composite Primary Key

create TABLE pk_ex_2(
    order_id int,
    line_no int,
    item text,
    PRIMARY KEY(order_id,line_no)
);

INSERT INTO pk_ex_2 VALUES (1,1,'Atta');
INSERT INTO pk_ex_2 VALUES (1,2,'Atta_10'),(2,1,'Atta_20');

SELECT * from pk_ex_2;
