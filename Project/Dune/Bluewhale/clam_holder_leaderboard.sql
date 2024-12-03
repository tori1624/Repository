-- Tried adding staked tokens in Aqua Space, but numbers don’t align due to IL (Impermanent Loss)
-- [Enhancement Point (1)] Summing up holdings within the LP
with token_transfers as (
    select "from" as from_address
         , "to" as to_address
         , value / power(10, 18) as value
         , evt_block_time
    from erc20_kaia.evt_Transfer as tranfers
    where contract_address = 0xba9725eaccf07044625f1d232ef682216f5371c2  -- $CLAM
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
),
aWeekAgo_io as(
    select to_address as address
         , sum(value) as balance
    from token_transfers
    where evt_block_time <= now() - interval '7' day
    group by to_address

    union all

    select from_address as address
         , -sum(value) as balance
    from token_transfers
    where evt_block_time <= now() - interval '7' day
    group by from_address
),
aWeekAgo_balance as (
    select address
         , sum(balance) as aWeekAgo_balance
    from aWeekAgo_io
    group by address
    having sum(balance) > 0
),
final as(
    select a.address as address
         , round(current_balance, 5) as current_balance
         , round(aWeekAgo_balance, 5) as aWeekAgo_balance
    from current_balance a
    left join aWeekAgo_balance b
    on a.address = b.address
)

select rank() over (order by a.current_balance desc) as rank
     , a.address
     , a.current_balance
     , (a.current_balance - a.aWeekAgo_balance) as change7days
     , (a.current_balance / b.supply) as supplyPercentage
from final a, supply b
order by a.current_balance desc;
