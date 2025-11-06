
SELECT 
    prod_name,length(prod_name)
FROM
    products.products

Extract First 5 characters from Full Name

SELECT 
    full_name,
    left(full_name,POSITION(' ' in full_name)-1),
    length(left(full_name,POSITION(' ' in full_name))),
    substring(full_name from 1 for 5),
    substr(full_name,1,5),
    SUBSTRING(full_name from POSITION(' ' in full_name) for 2) as last_name,
    POSITION(' ' in full_name),
    SUBSTRING(full_name from POSITION(' ' in full_name) + 1 for 2) as last_name,
    POSITION(' ' in full_name) + 1,
    LEFT(full_name,5),
    RIGHT(full_name,5)

FROM
    customers.customers

SELECT
    -- concat(full_name, ' is from ',city,',',state),
    -- lower(full_name),
    -- upper(full_name),
    -- initcap(lower(full_name)),
    -- split_part(concat(full_name, ' is from ',city,',',state),' ',5),
    'Siraj',
    unnest(string_to_array('laptop|laptop|mobile|desktop|desktop|laptop|laptop|mobile|desktop|desktop','|'))
    -- unnest(string_to_array(concat(full_name, ' is from ',city,',',state),' '))
FROM
    customers.customers
limit 7

SELECT
    '  Siraj  ',
    TRIM('  Siraj  '),
    LTRIM('  Siraj  '),
    RTRIM('  Siraj  '),
    TRIM(both 'x' from 'xxSirajxx')

SELECT
    replace('Siraj Ali','i','*')

SELECT  
    *,
    concat_ws('@',full_name,gender,age,city,state),
    reverse(full_name)
FROM
    customers.customers
limit 7

regexp_replace

SELECT
    regexp_replace('qwe9876545','[^0-9]','','g'),
    regexp_replace('!@#@#@Siraj@#*&(&^*&%12345)','[^a-zA-Z0-9]','','g')

SELECT
    cust_id,
    lpad(cast(cust_id as varchar),5,'0'),
    rpad(cast(cust_id as varchar),5,'0'),
    cast(lpad(cast(cust_id as varchar),5,'0') as int),
    lpad(region_name,10,'$'),
    
FROM
customers.customers

SELECT
    *
FROM
customers.customers

