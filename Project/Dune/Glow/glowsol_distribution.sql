with holder_rank as (
    select token_balance_owner
         , token_balance
    from solana_utils.latest_balances
    where token_mint_address = '7wBBPnj2TA5XhB3ADm8D1odSKh9fDqAWMPaUqaMPH17e'
    order by token_balance desc
),
class as (
    select *
         , case
               when token_balance >= 0 and token_balance < 0.5 then '0-0.5 SOL'
               when token_balance >= 0.5 and token_balance < 1 then '0.5-1 SOL'
               when token_balance >= 1 and token_balance < 2 then '1-2 SOL'
               when token_balance >= 2 and token_balance < 5 then '2-5 SOL'
               when token_balance >= 5 and token_balance < 10 then '5-10 SOL'
               when token_balance >= 10 then '+10 SOL'
               end as token_class
    from holder_rank
)

select token_class
     , count(*) as num_holders
from class
group by 1
order by 1 desc
;
