SHOW search_path;
set search_path to daily;

-- Unique Constriants

CREATE TABLE uq_ex_1(
    phone TEXT UNIQUE
);

INSERT INTO uq_ex_1 VALUES('9999'),('88888');

SELECT *
FROM uq_ex_1;

INSERT INTO uq_ex_1 VALUES('9999');
INSERT INTO uq_ex_1 VALUES(NULL);
INSERT INTO uq_ex_1 VALUES('Ali'),('ali');
