with holder as (
    select address
         , sum(counts) as nft_balance
    from 
        (select "from" as address
              , -1 as counts
        from erc721_ethereum.evt_transfer
        where contract_address = 0xf98943AfC628De81E406cB5891FeD1813A44378C -- redbrick land
        
        union all
        
        select "to" as address
             , 1 as counts
        from erc721_ethereum.evt_transfer
        where contract_address = 0xf98943AfC628De81E406cB5891FeD1813A44378C
        ) nft
    group by address
)


select row_number() over(order by nft_balance desc) as rank
     , address
     , nft_balance
     , row_number() over(order by nft_balance asc) as number
from holder
where address <> 0x0000000000000000000000000000000000000000
and nft_balance > 0
order by rank asc 
;
