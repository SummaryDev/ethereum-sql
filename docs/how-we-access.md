---
title: How we access blockchain data
description: Explanation of how summary.dev provides access to blockchain data.
author: Oleg Abdrashitov
keywords: ethereum,indexing,events,sql,charts,dashboards
url: https://summary.dev
---

# How we access blockchain data

Show how **summary.dev** gives access to blockchain data with SQL
queries and visualizations.

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

---

## Command line

CLI query tool provides a quick way to query blockchain data with SQL.
It can query parquet files on a remote server and on the local disk, and
query tables in the local database.

![bg right](images/cli.png)

---

## Rill

CLI query tool provides a quick way to query blockchain data with SQL.
It can query parquet files on a remote server and on the local disk, and
query tables in the local database.

![bg right](images/rill.png)

---

## SQL Editor

We open access to blockchain data via popular Business Intelligence
tools like Redash with a convenient SQL Editor.

![bg right](images/redash.png)

---

## Charts

Build charts from query results.

![bg right](images/redash-pie-chart.png)

---

## Dashboards

Build dashboards from charts.

![bg right](images/redash-dashboard.png)



  
