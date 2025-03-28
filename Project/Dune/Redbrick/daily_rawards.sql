with first_time as (
    select "from"
         , min(block_time) as first_time
    from opbnb.transactions
    where to = 0xdf655fcdff5652cb5977773e2378d3ed8816333b -- daily reward
    group by 1
), 
new_user as (
    select date_trunc('day', first_time) as period
         , count("from") as new
    from first_time
    group by 1
),
total_user as (
    select date_trunc('day', block_time) as period
         , count(distinct "from") as dau
    from opbnb.transactions
    where to = 0xdf655fcdff5652cb5977773e2378d3ed8816333b
    group by 1
)

select period
     , dau
     , coalesce(new, 0) as new
     , dau-coalesce(new, 0) as old
     , sum(new) over(order by period asc) as total_account
     , dau*20 as point
     , sum(dau*20) over(order by period asc) as total_point
from total_user t
left join new_user n using(period)
order by period desc
;
