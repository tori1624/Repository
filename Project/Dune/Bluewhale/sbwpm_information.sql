with token_transfers as (
    select "from" as from_address
         , "to" as to_address
         , value / power(10, 18) as value
         , evt_block_time
    from erc20_kaia.evt_Transfer as tranfers
    where contract_address = 0xf4546e1d3ad590a3c6d178d671b3bc0e8a81e27d  -- $sBWPM
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

select (round(sum(a.current_balance), 5) + 1) as sum_balance
     , (7000 - avg(b.supply)) as BWPM
     , (round(sum(a.current_balance), 5) + 1) +
       (7000 - avg(b.supply)) as total
from current_balance a, supply b
where a.address in (
    0xc39bedebbbde55278ef7cc06233bd8af2fad54ea,  -- buyback
    0xdDfbb2a4409C43E0f3Fcaa2C116459c11942f542,  -- Adol
    0x32ecdd17248938907e36832b1e7fb2936b9cc3b8  -- Team
)
;
