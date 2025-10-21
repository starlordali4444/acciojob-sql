set search_path to daily;

CREATE table chk_ex_1(
    item text,
    price int CHECK(price>0)
);

-- Insert rows into table 'chk_ex_1' in schema '[daily]'
INSERT INTO chk_ex_1
VALUES
( -- First row: values for the columns in the list above
 'Rose',15
);

SELECT * from chk_ex_1;

-- Insert rows into table 'chk_ex_1' in schema '[daily]'
INSERT INTO chk_ex_1
VALUES
( -- First row: values for the columns in the list above
 'Rose',-15
);


create table chk_ex_2(
    status text CHECK(status in ('Active','Inactive','Pending'))
);

insert into chk_ex_2 VALUES ('Active');
insert into chk_ex_2 VALUES ('Ali');

select * from chk_ex_2;

CREATE table chk_ex_3(
    sales NUMERIC,
    mrp NUMERIC,
    CHECK(sales<=mrp)
);

INSERT INTO chk_ex_3 VALUES (100,200);
INSERT INTO chk_ex_3 VALUES (1000,200);

select * from chk_ex_3;



