set search_path to daily;

-- Table_1
--     There was a Boy | Column | Primary Key
--         Brother => Sister-in-law
--         Sister  => Sister-in-law

-- Table_2
-- There was a Girl    | Column | FOREIGN Key
--     Sister  => Brother-in-law
--     Brother => Brother-in-law

-- Marriage

-- Boy => Girl | Husband => Wife

-- DATABASE
--     SCHEMA
--         Order
--             order_id        |   PRIMARY KEY
--             amount
--             product_id      |   FOREIGN KEY
--             customer_id     |   FOREIGN KEY
--         Product
--             product_id      |   PRIMARY KEY
--             product_name
--         Customer
--             id              |   PRIMARY KEY
--             name

CREATE TABLE fk_parent(
    id serial PRIMARY key,
    name text
);

CREATE TABLE fk_child(
    cid serial PRIMARY KEY,
    pid int REFERENCES fk_parent(id)
);

INSERT INTO fk_parent (name)  VALUES('Ali');

SELECT * from fk_parent;

INSERT INTO fk_child (pid) VALUES (4);
update fk_child 
    set pid = 1;

select * from fk_child;






