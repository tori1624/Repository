with token_transfers as (
    select "from" as from_address
         , "to" as to_address
         , value / power(10, 18) as value
         , evt_block_time
    from erc20_kaia.evt_Transfer as tranfers
    where contract_address = 0xb3b1b54e3b9a27cee606f1018760abec4274bd35  -- $PEARL
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
            when to_address = 0x952f202b5e58058deb468cd30d081922c36bf29a then value  --PEARL Staking Contract
            else -value
        end
    ) as staking
    from token_transfers
    where from_address = 0x952f202b5e58058deb468cd30d081922c36bf29a
    or to_address = 0x952f202b5e58058deb468cd30d081922c36bf29a
),
current_io as (
    select to_address as address
         , sum(value) as balance
    from token_transfers
    group by to_address

    union all

    select from_address as address
         , -sum(value) as balance
    from token_transfers
    group by from_address
),
current_balance as (
    select address
         , sum(balance) as current_balance
    from current_io
    group by address
    having sum(balance) > 0
)

select round(sum(a.current_balance), 5) as buyback_sum
     , (round(sum(a.current_balance), 5) / avg(c.supply)) * 100 as buyback_ratio
     , avg(b.staking) as staking
     , (avg(b.staking) / avg(c.supply)) * 100 as staking_ratio
from current_balance a, staking b, supply c
where a.address in (
    0xc39bedebbbde55278ef7cc06233bd8af2fad54ea,  -- buyback
    0xdDfbb2a4409C43E0f3Fcaa2C116459c11942f542,  -- Adol
    0x32ecdd17248938907e36832b1e7fb2936b9cc3b8  -- Team
)
;
