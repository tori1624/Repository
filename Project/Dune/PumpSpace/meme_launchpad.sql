with launched_tokens as (
    -- using $AVAX
    select block_time
    from avalanche_c.transactions
    where "to" = 0x096f6df3d0dB9617771C4689338a8d663810140c
    and substring(data from 1 for 4) = 0x06d91d41
    and success
    
    union all

    -- using $PEARL
    select block_time
    from avalanche_c.transactions
    where "to" = 0x096f6df3d0dB9617771C4689338a8d663810140c
    and substring(data from 1 for 4) = 0x7fddb4fa
    and success
),
launched_cnt as (
    select date_trunc('day', block_time) as period
         , count(*) as launched
    from launched_tokens
    group by 1
),
listed_tokens as (
    select block_time
    from tokens_avalanche_c.transfers
    where "from" = 0x096f6df3d0dB9617771C4689338a8d663810140c
    and "to" = 0x000000000000000000000000000000000000dEaD
),
listed_cnt as (
    select date_trunc('day', block_time) as period
         , count(*) as listed
    from listed_tokens
    group by 1
)

select period
     , coalesce(launched, 0) as launched
     , sum(launched) over(order by period asc) as total_launched
     , coalesce(listed, 0) as listed
     , sum(listed) over(order by period asc) as total_listed
from launched_cnt a
left join listed_cnt b using(period)
order by period desc
;
