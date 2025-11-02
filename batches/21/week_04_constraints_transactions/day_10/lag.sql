Compare store’s profit with previous day.

SELECT
    store_id,summary_date,net_profit,
    lag(net_profit) OVER(PARTITION  BY store_id ORDER by summary_date) as prev_month_profit,
    round(((net_profit-lag(net_profit,1,0) OVER(PARTITION  BY store_id ORDER by summary_date))/net_profit)*100,2) as change
FROM
    finance.revenue_summary;

Flag stores with 3-month continuous loss.

with monthly_summary as (
    SELECT
        store_id,summary_date,
        lag(net_profit,2,0) OVER(PARTITION by store_id ORDER BY summary_date) "month_-2_net_profit",
        lag(net_profit,1,0) OVER(PARTITION by store_id ORDER BY summary_date) previous_month_net_profit,net_profit
    FROM
        finance.revenue_summary
)
select *,
    CASE
        WHEN net_profit<previous_month_net_profit AND previous_month_net_profit< "month_-2_net_profit" THEN 'Profit Drop 3 Months'
        ELSE 'Stable'
    END as alert
from monthly_summary


Select ((15*((100*3)+(100*7)+(100*15)+(100*45)))/60)/24,365*4


Windows

EXISTS
ANY
ALL
EXCEPT

