with cnt as (
select date_trunc('day', block_time) as period
     , count(*) as launched
from tokens_avalanche_c.transfers
where "from" = 0x0000000000000000000000000000000000000000
and "to" = 0x096f6df3d0dB9617771C4689338a8d663810140c
group by 1
)

select period
     , launched
     , sum(launched) over(order by period asc) as total_launched
from cnt
order by period desc
;
