with usdf_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x5A110fC00474038f6c02E89C707D638602EA44B5 -- usdf CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x5A110fC00474038f6c02E89C707D638602EA44B5
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
asusdf_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x917AF46B3C3c6e1Bb7286B9F59637Fb7C65851Fb -- asusdf CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x917AF46B3C3c6e1Bb7286B9F59637Fb7C65851Fb
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
summary as (
    select dt
         , sum(u.amount) over(order by dt asc) as usdf_supply
         , sum(a.amount) over(order by dt asc) as asusdf_supply
    from usdf_supply u
    left join asusdf_supply a using(dt)
)

select dt
     , usdf_supply
     , asusdf_supply
     , asusdf_supply/usdf_supply as minted_ratio
from summary
order by dt desc
;
