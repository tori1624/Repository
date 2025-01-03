with launched_cnt as (
select date_trunc('day', block_time) as period
     , count(*) as launched
from tokens_avalanche_c.transfers
where "from" = 0x0000000000000000000000000000000000000000
and "to" = 0x096f6df3d0dB9617771C4689338a8d663810140c
group by 1
),
listed_cnt as (
select date_trunc('day', block_time) as period
     , count(*) as listed
from tokens_avalanche_c.transfers
where "from" = 0x096f6df3d0dB9617771C4689338a8d663810140c
and "to" = 0x000000000000000000000000000000000000dEaD
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
