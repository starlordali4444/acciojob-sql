SELECT
    current_date,
    current_time,
    CURRENT_TIMESTAMP,
    now(),
    date_trunc('year',CURRENT_TIMESTAMP) as first_day_of_year,
    date_trunc('month',CURRENT_TIMESTAMP),
    date_trunc('day',CURRENT_TIMESTAMP),
    date_trunc('hour',CURRENT_TIMESTAMP),
    date_trunc('minute',CURRENT_TIMESTAMP)

SELECT
    to_date('2025-11-10','YYYY-MM-DD'),
    to_date('10-11-2025','DD-MM-YYYY'),
    to_timestamp('21:23:45 10-11-2025','MI:HH24:SS MM-DD-YYYY'),
    age(CURRENT_DATE,'2002-12-07'),
    CURRENT_DATE + INTERVAL '1 year 10 months 10 hour 26 minute'