
CREATE SCHEMA IF NOT EXISTS hr;

CREATE TABLE IF NOT EXISTS hr.attendance (
  emp_id int REFERENCES stores.employees(emp_id),
  date date,
  status varchar(10),
  PRIMARY KEY (emp_id, date)
);

CREATE TABLE IF NOT EXISTS hr.salary_history (
  emp_id int REFERENCES stores.employees(emp_id),
  effective_date date,
  salary numeric(12,2)
);
