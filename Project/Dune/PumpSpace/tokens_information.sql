with tokens_launched as (
    -- using $AVAX
    select block_time
         , "from" as creator
         , hash as tx_hash
         , from_utf8(substring(data from 229 for 32)) as name
         , from_utf8(substring(data from 293 for 32)) as ticker
         , 'AVAX' as token_used
         , value/1e18 as value
    from avalanche_c.transactions
    where "to" = 0x096f6df3d0dB9617771C4689338a8d663810140c
    and substring(data from 1 for 4) = 0x06d91d41
    and success
    
    union all

    -- using $PEARL
    select block_time
         , "from" as creator
         , hash as tx_hash
         , from_utf8(substring(data from 261 for 32)) as name
         , from_utf8(substring(data from 325 for 32)) as ticker
         , 'PEARL' as token_used
         , value/1e18 as value
    from avalanche_c.transactions
    where "to" = 0x096f6df3d0dB9617771C4689338a8d663810140c
    and substring(data from 1 for 4) = 0x7fddb4fa
    and success
),
mints as (
    select evt_tx_hash as tx_hash
         , contract_address
    from erc20_avalanche_c.evt_transfer
    where "from" = 0x0000000000000000000000000000000000000000
    and evt_block_time > cast('2024-12-22' as timestamp)
),
ownership as (
    select "to" as to_add
         , contract_address
         , sum(value/1e18) as amount
    from erc20_avalanche_c.evt_transfer
    where contract_address in (select contract_address from mints)
    and "from" = 0x096f6df3d0dB9617771C4689338a8d663810140c
    and evt_block_time > cast('2024-12-22' as timestamp)
    group by "to", contract_address
),
summary as (
    select l.block_time
         , l.name
         , l.ticker
         , m.contract_address
         , l.creator
         , l.tx_hash
    from tokens_launched l
    left join mints m on l.tx_hash = m.tx_hash
),
tokens_listed as (
    select tx_hash
         , block_time
         , contract_address
         , 'listed' as label
    from tokens_avalanche_c.transfers
    where "from" = 0x096f6df3d0dB9617771C4689338a8d663810140c
    and "to" = 0x000000000000000000000000000000000000dEaD
)

select s.block_time
     , s.name
     , s.ticker
     , s.contract_address
     , coalesce(o.amount/1e9, 0) as dev_ownership
     , case when l.label = 'listed' then 'Yes' else 'No' end as listed
     , s.creator
     , s.tx_hash
from summary s
left join ownership o on s.contract_address = o.contract_address and s.creator = o.to_add
left join tokens_listed l on s.contract_address = l.contract_address
order by 1 desc
;
