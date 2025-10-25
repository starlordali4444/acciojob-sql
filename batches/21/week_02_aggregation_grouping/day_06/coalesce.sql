WITH cte_order_items AS(
    SELECT
        *,
        CASE 
            when discount>5 THEN ROUND(discount/100,2)
            ELSE NULL
        end as discount_applied
    FROM
        "sales"."order_items"
    LIMIT
        1000
)
SELECT
    *,
    coalesce(discount_applied,avg(discount_applied))
FROM
    cte_order_items

NULLIF

WITH cte_order_items AS(
    SELECT
        *,
        CASE 
            when discount>5 THEN ROUND(discount/100,2)
            ELSE NULL
        end as discount_applied
    FROM
        "sales"."order_items"
    LIMIT
        1000
)
SELECT
    *,
    nullif(discount_applied,0.10)
FROM
    cte_order_items

Coalesce => Replacing Null with something
NULLIF   => Replacing something with NULL

select
    *
from 
    sales.order_items

select
    *,
    unit_price / NULLif(discount,0)
from 
    sales.order_items




