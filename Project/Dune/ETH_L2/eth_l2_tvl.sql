with
    l2_tvl as (
        select
            'Mode' as chain,
            from_unixtime(cast(item['date'] as double)) as date,
            cast(item['tvl'] as double) as tvl
        from
            unnest (
                cast(
                    json_parse(
                        http_get ('https://api.llama.fi/v2/historicalChainTvl/mode')
                    ) as array (map(varchar, json))
                )
            ) as t (item) -- scroll,
        where
            from_unixtime(cast(item['date'] as double)) >= timestamp '2024-04-01'
        union all
        select
            'ZKsync' as chain,
            from_unixtime(cast(item['date'] as double)) as date,
            cast(item['tvl'] as double) as tvl
        from
            unnest (
                cast(
                    json_parse(
                        http_get (
                            'https://api.llama.fi/v2/historicalChainTvl/Zksync%20Era'
                        )
                    ) as array (map(varchar, json))
                )
            ) as t (item)
        where
            from_unixtime(cast(item['date'] as double)) >= timestamp '2024-04-01'
        union all
        select
            'Blast' as chain,
            from_unixtime(cast(item['date'] as double)) as date,
            cast(item['tvl'] as double) as tvl
        from
            unnest (
                cast(
                    json_parse(
                        http_get (
                            'https://api.llama.fi/v2/historicalChainTvl/blast'
                        )
                    ) as array (map(varchar, json))
                )
            ) as t (item)
        where
            from_unixtime(cast(item['date'] as double)) >= timestamp '2024-04-01'
        union all
        select
            'zkLink Nova' as chain,
            from_unixtime(cast(item['date'] as double)) as date,
            cast(item['tvl'] as double) as tvl
        from
            unnest (
                cast(
                    json_parse(
                        http_get (
                            'https://api.llama.fi/v2/historicalChainTvl/zkLink%20Nova'
                        )
                    ) as array (map(varchar, json))
                )
            ) as t (item)
        where
            from_unixtime(cast(item['date'] as double)) >= timestamp '2024-04-01'
        union all
        select
            'Scroll' as chain,
            from_unixtime(cast(item['date'] as double)) as date,
            cast(item['tvl'] as double) as tvl
        from
            unnest (
                cast(
                    json_parse(
                        http_get (
                            'https://api.llama.fi/v2/historicalChainTvl/scroll'
                        )
                    ) as array (map(varchar, json))
                )
            ) as t (item)
        where
            from_unixtime(cast(item['date'] as double)) >= timestamp '2024-04-01'
        /*
        union all
        select
            'Base' as chain,
            from_unixtime(cast(item['date'] as double)) as date,
            cast(item['tvl'] as double) as tvl
        from
            unnest (
                cast(
                    json_parse(
                        http_get ('https://api.llama.fi/v2/historicalChainTvl/base')
                    ) as array (map(varchar, json))
                )
            ) as t (item)
        where
            from_unixtime(cast(item['date'] as double)) >= timestamp '2024-04-01'*/
    )

select
    *
from
    l2_tvl
