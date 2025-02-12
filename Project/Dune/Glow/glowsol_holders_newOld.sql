with daily_balances as (
    select date_trunc('day', block_time) as date
         , token_balance_owner as owner
         , sum(token_balance) as token_balance
    from solana_utils.daily_balances
    where token_mint_address = '7wBBPnj2TA5XhB3ADm8D1odSKh9fDqAWMPaUqaMPH17e'
    group by 1, 2
),
holders_per_day as (
    select date
         , count(distinct owner) as total_holders
    from daily_balances
    where token_balance > 0
    group by 1
),
new_holders as (
    select db1.date
         , count(distinct db1.owner) as new_holders
    from daily_balances db1
    where token_balance > 0
    and not exists (
        select 1
        from daily_balances db2
        where db2.owner = db1.owner
        and db2.date < db1.date
    )
    group by 1
)

select h.date
     , h.total_holders as total
     , coalesce(n.new_holders, 0) as new
     , h.total_holders - coalesce(n.new_holders, 0) as old
     , sum(n.new_holders) over(order by n.date asc) as total_new
from holders_per_day h
left join new_holders n
on h.date = n.date
where h.date >= date('2025-01-31')
order by h.date desc
;
