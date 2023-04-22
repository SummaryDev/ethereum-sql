---
title: How we query
description: Explanation of how summary.dev uses DuckDb to query blockchain data.
author: Oleg Abdrashitov
keywords: ethereum,duckdb,query,events
url: https://summary.dev
---

# How we query for blockchain data

We make a case for serving blockchain data in files of a public dataset
and analyzing it locally on the end user's computer.

---

## Existing client-server solutions

There are SaaS solutions like Dune, FlipsideCrypto, BitQuery that index
blockchain data and make it available for querying via web interfaces or
APIs. They use general purpose OLAP databases like BigQuery, Clickhouse,
Trinio, Spark.

We at **summary.dev** also started with this client-server architecture
around Amazon Redshift database, but soon realized there is a better
way.

---

## What's specific about blockchain data

- All data is public. We don't need user management and access control.
- All data is append only. We don't need to support updates.
- All events have their payload split in 4 columns encoded in hex. We
  can store them in one table with a simple schema and optimize around
  it.
- When we query for events we always filter by at least two parameters.
  We can partition data by them:
  -    event signatures (aka topic0)
     - ranges of dates
---

## Why use databases?

- If our data is public do we need to hide it in a database on some 
  remote server?
- If our data is stored in one table do we need a general purpose OLAP
  database optimized for complex joins?
- Do we need to run a database as a daemon process serving multiple 
  users?
- Are end user computers powerful enough to run OLAP queries?
- Can we bring our data close to the end user and give the user a query 
  tool to analyze it locally?
- If the data can be partitioned can we bring only the slice of data the
  user is interested in, like specific events over given date range?

---

## The answer is DuckDb, Parquet and partitioning

We store blockchain events not in database tables but in efficient
**Parquet** files with columnar format and compression.

We serve these files from a web server or S3 so that the user can
download them for querying locally. 

We organize Parquet files into folders following **Hive partitioning**
method where columns we partition by become folders, so that the user
needs to download only the files from a folder with a specific event,
and its subfolders with specific dates.

The user then queries the files he downloaded with a query tool
optimized for blockchain data with an embedded OLAP library **DuckDb**.

---

## Partitioning

Our data files are organized in folders named after event signature
hashes (topic0) and dates of the events.

When the user filters by `topic0` and a range of dates:

```sql
select * from parquet_scan('ethereum/*/*/*',hive_partitioning=1) 
where topic0='0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' 
and date between '2023-01-01' and '2023-01-03';
```

the query tool will scan only the files in the corresponding folders:

```
topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef/2023-01-01/*.parquet
                                                                         /2023-01-02/*.parquet
                                                                         /2023-01-03/*.parquet
```
---

## Partitioning logic in views

We abstract filtering and decoding of events into database views so that
users can query from views whose names are more familiar than signature 
hashes.

The **event view** `Transfer_address_from_address_to_uint256_value_d`
queries for and decodes ERC20 `Transfer` events, and hides the
complexity of scanning partitioned files:

```sql
create or replace view event."Transfer_address_from_address_to_uint256_value_d" 
as select to_address(2,topics[1]::text) "from", 
to_address(2,topics[2]::text) "to", 
to_uint256(2,data::text) "value", 
address contract_address 
from parquet_scan('./topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef/*/*',
hive_partitioning=1);
```
---

## Selecting from event views for partitioned files

A select from this **event view** for `Transfer`s emitted in 3 days is
succinct:

```sql
select * from event."Transfer_address_from_address_to_uint256_value_d" 
where date between '2023-01-01' and '2023-01-03';
```

And translates into a scan of parquet files in folder
`topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef`
and its 3 subfolders, each for every date in the given date range.

---

## Querying remotely

You can query files located on the remote file server directly, without
explicitly downloading parquet files. Note the url `s3://summary.dev`.

```sql
select * from parquet_scan('s3://summary.dev/ethereum/*/*/*',hive_partitioning=1) 
where topic0='0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' 
and date='2023-01-01'
```

or using a view

```sql
select * from event."Transfer_address_from_address_to_uint256_value_d" 
where date = '2023-01-01';
```

Both queries will scan the same parquet files in specific folders
skipping files with other events and dates. However, this query will
bring in data only temporarily. Subsequent queries will need to download
again. Such remote access may be suitable for ad hoc queries.

---

## Querying locally

For more frequent queries it makes sense to first download the data.
Note we're using the same **event view** introduced above that scans remote
parquet files.

```sql
create table erc20_transfer_2023 as 
select * from event."Transfer_address_from_address_to_uint256_value_d"
where date >= '2023-01-01' 
```

This will download all ERC20 `Transfer` events of 2023 into a local
table `erc20_transfer_2023`. Queries against this table will read the
local database file and will be very fast. However, the initial download
may take some time.

---

## Querying locally with contract views

Let's use a **contract view** to download events emitted by a specific
contract:

```sql
create table weth_transfer_2023 as 
select * from erc20.weth_evt_Transfer
where date >= '2023-01-01' 
```

This query creates a local table `weth_transfer_2023` with `Transfer`
events of WETH token in 2023. This filter is more narrow so the download
will be faster.

---

## Packaging options

We see three ways we can package our query tool:

- **cli**: one executable file with no dependencies
- **GUI** app based on an open source Rill: sql editor and charts
- **browser**: DuckDb can compile into wasm and load into a web page or a 
  browser extension

---

## Using the browser

We can compile DuckDb into **wasm** and run queries in the browser. A
web page loaded in the browser hosts the sql editor. The queries are
executed using local compute resources over a subset of data hosted on a
web server. To the end user the experience is similar to using a web
interface in a typical client-server setup, and may be preferred to
installing and running a cli.

The only drawback is inability to download the data files locally. This
is the limitation of the browser that may be overcome in the future;
another options is a browser extension which has access to local disk
and can download and store files.