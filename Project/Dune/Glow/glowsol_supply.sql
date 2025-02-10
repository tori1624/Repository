with periods as (
    select period from unnest(sequence(timestamp '2025-01-31', cast(current_time as timestamp), interval '1' hour)) as t(period)
),
supply as (
    select date_trunc('hour', block_time) as period
         , sum(
               case
                   when action = 'mint' then amount / 1e9
                   when action = 'burn' then -amount / 1e9
                   else 0
               end
           ) as amount
    from tokens_solana.transfers 
    where token_mint_address = '7wBBPnj2TA5XhB3ADm8D1odSKh9fDqAWMPaUqaMPH17e'
    and (action = 'mint' or action = 'burn')
    group by 1
),
period_supply as (
    select period
         , coalesce(amount, 0) as amount
         , sum(coalesce(amount, 0)) over(order by period asc) as total_amount
    from periods
    left join supply using(period)
    order by period desc
)

select *
from period_supply
where period >= date('2025-01-31')
order by period desc
;
