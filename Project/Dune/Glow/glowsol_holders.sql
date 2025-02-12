select row_number() over(order by token_balance desc) as rank
     , row_number() over(order by token_balance asc) as number
     , token_balance_owner
     , token_balance
     , updated_at
from solana_utils.latest_balances
where token_mint_address = '7wBBPnj2TA5XhB3ADm8D1odSKh9fDqAWMPaUqaMPH17e'
and token_balance > 0
order by token_balance desc 
;
