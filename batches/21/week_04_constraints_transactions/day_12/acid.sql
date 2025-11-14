
set search_path to day_11;

BEGIN;

CREATE TABLE test_acid_demo(
    id int PRIMARY key,
    name varchar(20)
);

INSERT INTO test_acid_demo VALUES (1,'Ali'),(2,'Rahul');

SELECT * from test_acid_demo;

ROLLBACK;

COMMIT;