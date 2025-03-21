with addLP_hash_as as (
    select hash
    from bnb.transactions
    where substring(data from 1 for 4) = 0x0b4c7e4d -- add liquidity
    and to = 0xd791Be03A4E0E4B9be62adAc8a5Cd4aE2813A2d6 -- asUSDF/USDF
),
rmvLP_hash_as as (
    select hash
    from bnb.transactions
    where substring(data from 1 for 4) = 0x5b36389c -- remove liquidity
    and to = 0xd791Be03A4E0E4B9be62adAc8a5Cd4aE2813A2d6
),
addLP_hash_dt as (
    select hash
    from bnb.transactions
    where substring(data from 1 for 4) = 0x0b4c7e4d 
    and to = 0x176f274335c8B5fD5Ec5e8274d0cf36b08E44A57 -- USDF/USDT
),
rmvLP_hash_dt as (
    select hash
    from bnb.transactions
    where substring(data from 1 for 4) = 0x5b36389c
    and to = 0x176f274335c8B5fD5Ec5e8274d0cf36b08E44A57
),
lp_supply_as as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x5A110fC00474038f6c02E89C707D638602EA44B5
        and evt_tx_hash in (select hash from addLP_hash_as)
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x5A110fC00474038f6c02E89C707D638602EA44B5
        and evt_tx_hash in (select hash from rmvLP_hash_as)
        ) as raw 
    group by 1
),
lp_supply_dt as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x5A110fC00474038f6c02E89C707D638602EA44B5
        and evt_tx_hash in (select hash from addLP_hash_dt)
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x5A110fC00474038f6c02E89C707D638602EA44B5
        and evt_tx_hash in (select hash from rmvLP_hash_dt)
        ) as raw 
    group by 1
),
pendle as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x0f47aee96fae2558b0081c8d2dffbb8512397e23 -- sy-usdf CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x0f47aee96fae2558b0081c8d2dffbb8512397e23
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
summary as (
    select dt
         , sum(d.amount) over(order by dt asc) as USDF_USDT
         , sum(a.amount) over(order by dt asc) as asUSDF_USDF
         , sum(p.amount) over(order by dt asc) as Pendle
    from lp_supply_dt d
    left join lp_supply_as a using(dt)
    left join pendle p using(dt)
)


select *
     , USDF_USDT + asUSDF_USDF + Pendle as total_liquidity
from summary
order by dt desc
;
