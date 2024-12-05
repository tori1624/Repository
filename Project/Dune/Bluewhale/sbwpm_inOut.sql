with contract_address as (
    select address as contract_address
    from kaia.creation_traces
),
swap_address as(
    select address as swap_address
    from kaia.creation_traces
    where address = 0xac6bea4ff99b5a911278e431af4dc922687aac70  -- smart swap (aqua space)
    or "from" in (
        0x1d34aeb1835952545c3c63f189bd494111702b22,  -- SwapScanner Deployer
        0xd35eafcd46ccb93c6eeffe79dfe205663a8e1304,  -- SwapScanner Deployer
        0xdff9e057f12c54ec49e02be401018e8334b8ba16,  -- SwapScanner Deployer
        0xf50782a24afcb26acb85d086cf892bfffb5731b5  -- SwapScanner
    )
),
token_transfers as (
    select "from" as from_address
         , "to" as to_address
         , value / power(10, 18) as value
         , evt_block_time
    from erc20_kaia.evt_Transfer as tranfers
    where contract_address = 0xf4546e1d3ad590a3c6d178d671b3bc0e8a81e27d  -- $sBWPM
),
aDay_in as (
    select to_address as address
         , sum(value) as aDay_in
    from token_transfers
    where evt_block_time >= now() - interval '1' day
    and to_address not in (select contract_address from contract_address)
    and from_address in (select swap_address from swap_address)
    group by to_address
),
aDay_out as (
    select from_address as address
         , -sum(value) as aDay_out
    from token_transfers
    where evt_block_time >= now() - interval '1' day
    and from_address not in (select contract_address from contract_address)
    and to_address in (select swap_address from swap_address)
    group by from_address
),
aWeek_in as (
    select to_address as address
         , sum(value) as aWeek_in
    from token_transfers
    where evt_block_time >= now() - interval '7' day
    and to_address not in (select contract_address from contract_address)
    and from_address in (select swap_address from swap_address)
    group by to_address
),
aWeek_out as (
    select from_address as address
         , -sum(value) as aWeek_out
    from token_transfers
    where evt_block_time >= now() - interval '7' day
    and from_address not in (select contract_address from contract_address)
    and to_address in (select swap_address from swap_address)
    group by from_address
),
final as (
    select coalesce(a.address, b.address, c.address, d.address) as address
         , coalesce(a.aDay_in, 0) as aDay_in
         , coalesce(b.aDay_out, 0) as aDay_out
         , coalesce(c.aWeek_in, 0) as aWeek_in
         , coalesce(d.aWeek_out, 0) as aWeek_out
    from aDay_in a
    full outer join aDay_out b on a.address = b.address
    full outer join aWeek_in c on coalesce(a.address, b.address) = c.address
    full outer join aWeek_out d on coalesce(a.address, b.address, c.address) = d.address
)

select *
from final
where address != 0x0000000000000000000000000000000000000000
;
