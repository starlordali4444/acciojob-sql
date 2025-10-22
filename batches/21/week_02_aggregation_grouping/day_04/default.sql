set search_path to daily;

create table df_ex_1(
    id serial PRIMARY key,
    city text DEFAULT 'Banglore'
);

INSERT INTO df_ex_1 VALUES (1);
INSERT INTO df_ex_1 VALUES (2,'Lucknow');

SELECT * from df_ex_1;

CREATE table df_ex_2(
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_ text DEFAULT CURRENT_USER,
    role_ text DEFAULT CURRENT_ROLE,
    schema_ text DEFAULT CURRENT_SCHEMA
);

INSERT INTO df_ex_2 DEFAULT values;

select * from df_ex_2;