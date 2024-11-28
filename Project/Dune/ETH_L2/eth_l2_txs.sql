with
    l2_txs as (
        select
            date_trunc('day', block_time) as time,
            cast(count(*) as double) as tx_count,
            'Mode' as chain,
            "from" as user
        from
            mode.transactions
        where
            block_time > date_trunc('day', timestamp '2024-04-01')
        group by
            1,
            4
        union all
        select
            date_trunc('day', block_time) as time,
            cast(count(*) as double) as tx_count,
            'Zksync' as chain,
            "from" as user
        from
            zksync.transactions
        where
            block_time > date_trunc('day', timestamp '2024-04-01')
        group by
            1,
            4
        union all
        select
            date_trunc('day', block_time) as time,
            cast(count(*) as double) as tx_count,
            'Blast' as chain,
            "from" as user
        from
            blast.transactions
        where
            block_time > date_trunc('day', timestamp '2024-04-01')
        group by
            1,
            4
        union all
        select
            date_trunc('day', block_time) as time,
            cast(count(*) as double) as tx_count,
            'Scroll' as chain,
            "from" as user
        from
            scroll.transactions
        where
            block_time > date_trunc('day', timestamp '2024-04-01')
        group by
            1,
            4
        /*
        union all
        select
            date_trunc('day', block_time) as time,
            cast(count(*) as double) as tx_count,
            'Base' as chain,
            "from" as user
        from
            base.transactions
        where
            block_time > date_trunc('day', timestamp '2024-04-01')
        group by
            1,
            4
        */
    )
select
    time as date,
    sum(tx_count) as transactions,
    chain,
    count(distinct user) as users
from
    l2_txs
group by
    1,
    3;
