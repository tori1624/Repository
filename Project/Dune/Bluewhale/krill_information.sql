with token_transfers as (
    select "from" as from_address
         , "to" as to_address
         , value / power(10, 18) as value
         , evt_block_time
    from erc20_kaia.evt_Transfer as tranfers
    where contract_address = 0x83bc9fe9eebfeb1ad4178ac5e7445dc6a7e95718  -- $KRILL
),
supply as (
    select sum(
        case 
            when from_address = 0x0000000000000000000000000000000000000000 then value
            else -value
        end
    ) as supply
    from token_transfers
    where from_address = 0x0000000000000000000000000000000000000000
    or to_address = 0x0000000000000000000000000000000000000000
),
staking as (
    select sum(
        case 
            when to_address = 0x68e83e5300594e664701aa38a1d80f9524ca82d8 then value  -- KRILL Staking Contract
            else -value
        end
    ) as staking
    from token_transfers
    where from_address = 0x68e83e5300594e664701aa38a1d80f9524ca82d8
    or to_address = 0x68e83e5300594e664701aa38a1d80f9524ca82d8
),
burn as (
    select to_address as address
         , sum(value) as burn
    from token_transfers
    where to_address = 0x000000000000000000000000000000000000dead
    group by to_address
)

select c.burn as burn
     , (c.burn / a.supply) * 100 as burn_ratio
     , b.staking as staking
     , (b.staking / a.supply) * 100 as staking_ratio
from supply a, staking b, burn c
;
