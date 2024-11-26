select date_trunc('day', block_time) as time
     , cast(count(*) as double) as tx_count
from kaia.transactions
where to = 0xac6bea4ff99b5a911278e431af4dc922687aac70 --aquaspace
and block_time < date_trunc('day', now())
group by 1
order by time asc
;
