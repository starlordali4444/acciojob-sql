\c retailmart;
\copy hr.attendance     FROM 'datasets/csv/hr/attendance.csv'     CSV HEADER;
\copy hr.salary_history FROM 'datasets/csv/hr/salary_history.csv' CSV HEADER;
