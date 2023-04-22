---
title: Howe we query
description: Explanation of why summary.dev uses DuckDb to query blockchain data.
author: Oleg Abdrashitov
keywords: ethereum,duckdb,query,events
url: https://summary.dev
---

# Existing solutions

There are SaaS solutions that index blockchain data and make it
available for querying via web interfaces or APIs. They use powerful
OLAP databases like BigQuery, Clickhouse, Trinio, Spark.

We also started with this architecture around Amazon Redshift
database.

---

# What's specific about blockchain data

- All data is public. Do we need user management and access control?
- All data is append only. No need to support updates. 
- All events conform to the same format. We can use one table with simple
schema where only 4 columns (topics 1-3, data) carry data. Can we
optimize our database around it?
- When we query for events we always filter by at least two parameters.
  Can we partition data by them?
     - event signatures (topic0)
     - ranges of dates
---

# Why use databases?

- If our data is public do we need to hide it in a database on some 
  remote server?
- If our data has rigid and simple schema do need a general purpose OLAP
database optimized for complex joins?
- Do we need to run a database as some daemon process serving multiple
  users?
- What if we bring our data close to the end user and give the user a
  tool to query it locally?
- If the data can be partitioned can we bring only the slice of data the
  user is interested in, like specific events over given date range?

---

# The answer is

DuckDb, Parquet and Hive partitioning.

We store blockchain events not in database tables but in efficient
**Parquet** files with columnar format and compression.

We serve these files from a web server or S3 so that the user can
download them for querying locally, or access them remotely with http
range requests. Furthermore, we organize Parquet files into folders
following **Hive partitioning** method where columns we partition by
become folders, so that the user can download only the files he's
interested in, from a folder with a specific event and its subfolders
with specific dates.

The user queries the files he downloaded, containing the events he's
interested in. The query tool is built with an OLAP **DuckDb** library
and is optimized for blockchain data.

---

# Partitioning

Our data files are organized in folders by event signature hashes
(topic0) and dates. When the user filters by `topic0` and a range of
dates:

```sql
select * from parquet_scan('./*/*/*',hive_partitioning=1) 
where topic0='0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' 
and date between '2023-01-01' and '2023-01-03' limit 10;
```

the query tool will scan only the files in the corresponding folders:

```
topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef/2023-01-01/*.parquet
                                                                         /2023-01-02/*.parquet
                                                                         /2023-01-03/*.parquet
```
---

# Partitioning and views

We abstract filtering and decoding of events into event and contract
views so that users query with views named after events and contracts.
This view queries for and decodes ERC20 `Transfer`s:

```sql
create or replace view event."Transfer_address_from_address_to_uint256_value_d" 
as select to_address(2,topics[1]::text) "from", 
to_address(2,topics[2]::text) "to", 
to_uint256(2,data::text) "value", address contract_address 
from parquet_scan('./topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef/*/*',hive_partitioning=1);
```

A select from this view:

```sql
select * from event."Transfer_address_from_address_to_uint256_value_d" 
where date between '2023-01-01' and '2023-01-03' limit 10;
```

Will translate into a scan of parquet files in folder
`topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef`
and its 3 subfolders each for every date in the given date range.

---

# Querying remotely

You can query files located on the remote file server directly:

```sql
select * from parquet_scan('s3://summary.dev/data/*/*/*',hive_partitioning=1) 
where topic0='0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' 
and date='2023-01-01'
```

or using a view

```sql
select * from event."Transfer_address_from_address_to_uint256_value_d" 
where date = '2023-01-01';
```

Both queries will access the same parquet files in specific folders
avoiding downloading files with other events and dates.

However, this access will bring in parquet files only temporarily. 
Subsequent queries will need to download them again. Such remote access
may be suitable for one off queries.

---

# Querying locally

For more frequent analysis it makes sense to download the data:

```sql
create table erc20_transfer_2023 as select * from event."Transfer_address_from_address_to_uint256_value_d"
where date >= '2023-01-01' 
```

This will download all ERC20 `Transfer` events of 2023 into a local
table. Queries against this table will read the local database file and
will be extremely fast. However, the initial download during table
creation may take some time.

```sql
create table weth_transfer_2023 as select * from erc20.weth_evt_Transfer
where date >= '2023-01-01' 
```

This query creates a local table with the `Transfer`s of WETH token in
2023. The filter is even more narrow as it downloads only a subset of
`Transfer` events, and the download will be faster.

