-- forked from @whale_hunter/GRND Holder Leaderboard (https://dune.com/queries/4204010)
WITH
  config AS (
    SELECT
      'kaia' AS blockchain,
      0x19aac5f612f524b754ca7e7c41cbfa2e981a4432 AS wkaiaAddress,
      0xba9725eaccf07044625f1d232ef682216f5371c2 AS tokenAddress,
      TIMESTAMP '2021-09-24' AS deploymentTimestamp,
      18 AS decimals,
      'day' AS granularity,
      NULL AS pairAddress
  ),
  transferEvents AS (
    SELECT
      evt_block_time,
      "from",
      to,
      value / POWER(10, decimals) AS value
    FROM
      erc20_kaia.evt_Transfer AS tranfers
      JOIN config ON (
        contract_address = tokenAddress
        AND evt_block_time >= deploymentTimestamp
      )
  ),
  supply AS (
    SELECT
      SUM(
        IF(
          "from" = 0x0000000000000000000000000000000000000000,
          value,
          - value
        )
      ) AS supply
    FROM
      transferEvents
    WHERE
      "from" = 0x0000000000000000000000000000000000000000
      OR to = 0x0000000000000000000000000000000000000000
  ),
  transfersUpUntil7DaysAgo AS (
    (
      SELECT
        "to" AS address,
        SUM(CAST(value AS INT256)) AS balance
      FROM
        transferEvents
      WHERE
        evt_block_time <= NOW() - INTERVAL '7' day
      GROUP BY
        "to"
    )
    UNION ALL
    (
      SELECT
        "from" AS address,
        - SUM(CAST(value AS INT256)) AS balance
      FROM
        transferEvents
      WHERE
        "from" != 0x0000000000000000000000000000000000000000
        AND evt_block_time <= NOW() - INTERVAL '7' day
      GROUP BY
        "from"
    )
  ),
  balances7DaysAgo AS (
    SELECT
      RANK() OVER (
        ORDER BY
          SUM(balance) DESC
      ) AS holderRank,
      address,
      SUM(balance) as balance
    FROM
      transfersUpUntil7DaysAgo
    GROUP BY
      address
    HAVING
      SUM(balance) > CAST(0 AS INT256)
  ),
  transfersUpUntil1DayAgo AS (
    (
      SELECT
        "to" AS address,
        SUM(CAST(value AS INT256)) AS balance
      FROM
        transferEvents
      WHERE
        evt_block_time <= NOW() - INTERVAL '1' day
      GROUP BY
        "to"
    )
    UNION ALL
    (
      SELECT
        "from" AS address,
        - SUM(CAST(value AS INT256)) AS balance
      FROM
        transferEvents
      WHERE
        "from" != 0x0000000000000000000000000000000000000000
        AND evt_block_time <= NOW() - INTERVAL '1' day
      GROUP BY
        "from"
    )
  ),
  balances1DayAgo AS (
    SELECT
      RANK() OVER (
        ORDER BY
          SUM(balance) DESC
      ) AS holderRank,
      address,
      SUM(balance) as balance
    FROM
      transfersUpUntil1DayAgo
    GROUP BY
      address
    HAVING
      SUM(balance) > CAST(0 AS INT256)
  ),
  transfers AS (
    (
      SELECT
        "to" AS address,
        SUM(CAST(value AS INT256)) AS balance
      FROM
        transferEvents
      GROUP BY
        "to"
    )
    UNION ALL
    (
      SELECT
        "from" AS address,
        - SUM(CAST(value AS INT256)) AS balance
      FROM
        transferEvents
      WHERE
        "from" != 0x0000000000000000000000000000000000000000
      GROUP BY
        "from"
    )
  ),
  currentBalances AS (
    SELECT
      RANK() OVER (
        ORDER BY
          SUM(balance) DESC
      ) AS holderRank,
      address,
      SUM(balance) as balance
    FROM
      transfers
    GROUP BY
      address
    HAVING
      SUM(balance) > CAST(0 AS INT256)
  ),
  lastestPrice as (
    SELECT
      (reserve1 / POWER(10, 18)) / (reserve0 / POWER(10, decimals)) AS priceWKAIA
    FROM
      uniswap_v2_ethereum.Pair_evt_Sync
      JOIN config ON contract_address = pairAddress
    ORDER BY
      evt_block_time DESC,
      evt_index DESC
    LIMIT
      1
  ),
  wkaiaUSDPrices AS (
    SELECT
      price AS wkaiaUSD
    FROM
      prices.usd AS prices
      JOIN config ON (
        prices.blockchain = config.blockchain
        AND contract_address = wkaiaAddress
      )
    ORDER BY
      minute DESC
    LIMIT
      1
  ),
  holderLeaderboard AS (
    SELECT
      currentBalances.holderRank AS holderRank,
      balances1DayAgo.holderRank AS holderRank1DayAgo,
      balances7DaysAgo.holderRank AS holderRank7DaysAgo,
      COALESCE(
        ens.reverse_latest.name,
        labels.contracts.name,
        labels.cex_ethereum.name,
        CAST(currentBalances.address AS VARCHAR)
      ) AS holder,
      CONCAT(
        '<a href="https://debank.com/profile/',
        CAST(currentBalances.address AS VARCHAR),
        '?t=1688542931974&r=65920" target=_blank">',
        COALESCE(
          ens.reverse_latest.name,
          labels.contracts.name,
          labels.cex_ethereum.name,
          CAST(currentBalances.address AS VARCHAR)
        ),
        '</a>'
      ) AS holder_url,
      currentBalances.balance AS balance,
      COALESCE(balances1DayAgo.balance, 0) AS balance1DayAgo,
      COALESCE(balances7DaysAgo.balance, 0) AS balance7DaysAgo,
      --currentBalances.balance * priceWKAIA * wkaiaUSD AS balanceInUSD,
      currentBalances.balance / supply AS percentageFractionOfTotal,
      COALESCE(balances1DayAgo.balance, 0) / supply AS percentageFractionOfTotal1DayAgo,
      COALESCE(balances7DaysAgo.balance, 0) / supply AS percentageFractionOfTotal7DaysAgo,
      currentBalances.address AS holderAddress,
      IF(labels.cex_ethereum.name IS NOT NULL, 'CEX', NULL) AS type,
      currentBalances.address = 0xe0eb63b4e18ff1e646ab7e37510e6eaf287ade3d AS isVested -- Team
    FROM
      currentBalances
      LEFT JOIN balances1DayAgo ON currentBalances.address = balances1DayAgo.address
      LEFT JOIN balances7DaysAgo ON currentBalances.address = balances7DaysAgo.address
      --CROSS JOIN lastestPrice
      --CROSS JOIN wkaiaUSDPrices
      CROSS JOIN supply
      LEFT JOIN ens.reverse_latest ON ens.reverse_latest.address = currentBalances.address
      LEFT JOIN labels.contracts ON (
        currentBalances.address = labels.contracts.address
        AND labels.contracts.blockchain = 'kaia'
      )
      LEFT JOIN labels.cex_ethereum ON currentBalances.address = labels.cex_ethereum.address
  ),
  totalNumberOfHolders AS (
    SELECT
      COUNT(DISTINCT (holderAddress)) AS totalNumberOfHolders
    FROM
      holderLeaderboard
  )
SELECT
  holderRank,
  holderRank1DayAgo,
  IF(
    holderRank1DayAgo IS NULL,
    NULL,
    holderRank1DayAgo - holderRank
  ) AS holderRank1dChange,
  holderRank7DaysAgo,
  IF(
    holderRank7DaysAgo IS NULL,
    NULL,
    holderRank7DaysAgo - holderRank
  ) AS holderRank7dChange,
  holder,
  holder_url,
  balance,
  balance1DayAgo,
  balance - balance1DayAgo AS balance1dChange,
  balance7DaysAgo,
  balance - balance7DaysAgo AS balance7dChange,
  --balanceInUSD,
  percentageFractionOfTotal,
  percentageFractionOfTotal1DayAgo,
  percentageFractionOfTotal - percentageFractionOfTotal1DayAgo AS percentageFractionOfTotal1DayChange,
  percentageFractionOfTotal7DaysAgo,
  percentageFractionOfTotal - percentageFractionOfTotal7DaysAgo AS percentageFractionOfTotal7DayChange,
  holderAddress,
  type,
  isVested,
  totalNumberOfHolders,
  SUM(balance) OVER (
    ORDER BY
      holderRank
  ) AS cumulative_balance
FROM
  holderLeaderboard,
  totalNumberOfHolders
ORDER BY
  balance DESC
