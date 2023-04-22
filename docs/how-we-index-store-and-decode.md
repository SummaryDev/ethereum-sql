---
title: How we index, store and decode
description: Explanation of the ELT method summary.dev employs to index Ethereum.
author: Oleg Abdrashitov
keywords: ethereum,indexing,events
url: https://summary.dev
---

# Events in Ethereum

Smart contracts emit events (aka logs) which can be captured and analyzed.

Events can be searched for by their `signature` and optionally by 3
other `indexed` parameters called `topics`, while the rest of the
payload goes into the `data` field.

```js
event Transfer(address indexed from, address indexed to, uint256 value)
```

Event signature is a hash of its name and parameter types. 

```js
keccak_hash("Transfer(address,address,uint256)")
="0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
```

---

# Application Binary Interface

Parameter names are excluded from the event signature, so are their
`indexed` designations. To know where to get the values from the
payload: from `topic` fields or from `data`, we need the contract's ABI.

```json
"inputs": [
        {
            "indexed": true, "name": "from", "type": "address"
        },
        {
            "indexed": true, "name": "to", "type": "address"
        },
        {
            "indexed": false, "name": "value", "type": "uint256"
        }
    ],
"name": "Transfer",
"type": "event"
```

---

# Decode events

We can decode an event payload if we know the emitting contract's ABI.
We lookup the event's inputs by its signature in `topic0` and find that
`topic1` is parameter `from` of type `address`, `topic2` is `to`, while
`value` is in the `data` field, decoded from hex it's `389906400000000000`.

``` 
address = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
 topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
 topic1 = 0x00000000000000000000000000000000a991c429ee2ec6df19d40fe0c80088b8
 topic2 = 0x000000000000000000000000d21ab387f22d4ccb88fe8a139cd60a977706e493
 topic3 = 
   data = 0x000000000000000000000000000000000000000000000000056939ce13a6c000
```

This is a `Transfer` of `0.3899064` of ERC20 token
`0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2` from address
`0x00000000a991c429ee2ec6df19d40fe0c80088b8` to
`0xd21ab387f22d4ccb88fe8a139cd60a977706e493`.

---

# Identify contracts

It helps to know what the emitting contract at address
`0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2` is in fact WETH "Wrapped
Ether". This information is not on chain (and neither is its ABI) but is
available from Etherscan where it is usually crowd sourced. We can
identify contracts by names like `WETH` or `Swap` and labels like
`ERC20` for protocol, `aave` for application or `dex` for sector. We can
decode events when its ABI is publicly available, or after it's been
submitted by a user, thus the vast majority of events can be decoded and
identified. So far we know:

- 14k Unique event ABIs 
- 88k Event signatures
- 504k Named contracts
- 3k Contract labels 

---

# Store raw events

We index everything: capture all events and store them in their raw
undecoded format in one table.

``` 
┌──────────────────────┬──────────────────────┬──────────────────────────────────────────┬────────────────────────────────────────────────────────────────────┬─────────┬────────────────────────────────────────────────────────────────────┐
│       address        │        topic0        │                  topic1                  │                               topic2                               │ topic3  │                                data                                │
│       varchar        │       varchar        │                 varchar                  │                              varchar                               │ varchar │                              varchar                               │
├──────────────────────┼──────────────────────┼──────────────────────────────────────────┼────────────────────────────────────────────────────────────────────┼─────────┼────────────────────────────────────────────────────────────────────┤
│ 0xc02aaa39b223fe8d…  │ 0xddf252ad1be2c89b…  │ 0x00000000000000000000000000000000a991…  │ 0x000000000000000000000000d21ab387f22d4ccb88fe8a139cd60a977706e493 │         │ 0x000000000000000000000000000000000000000000000000056939ce13a6c000 │
│ 0xd7226e7b91dc6bf5…  │ 0xddf252ad1be2c89b…  │ 0x000000000000000000000000d21ab387f22d…  │ 0x00000000000000000000000000000000a991c429ee2ec6df19d40fe0c80088b8 │         │ 0x0000000000000000000000000000000000000000000d7bdab12f221218234f9b │
│ 0xc02aaa39b223fe8d…  │ 0xddf252ad1be2c89b…  │ 0x00000000000000000000000000000000a991…  │ 0x0000000000000000000000004e79d2f77a5cee2119d114b34a064a0fc28a3ae4 │         │ 0x000000000000000000000000000000000000000000000000015aa23738b25800 │
│ 0x3d9fffec81bcdc16…  │ 0xddf252ad1be2c89b…  │ 0x0000000000000000000000004e79d2f77a5c…  │ 0x00000000000000000000000000000000a991c429ee2ec6df19d40fe0c80088b8 │         │ 0x0000000000000000000000000000000000000000000000141a5729e106d2d464 │
└──────────────────────┴──────────────────────┴──────────────────────────────────────────┴────────────────────────────────────────────────────────────────────┴─────────┴────────────────────────────────────────────────────────────────────┘
```

For those events whose ABI we know we decode their payloads on the fly
when we query; other events can be decoded once their ABIs become known.

This makes our process ELT "Extract Load Transform" rather than the
traditional ETL which would capture events (extract), decode them
(transform) and store into individual tables with different schemas
(load).

---

# Query and decode events

We put the logic to decode event payloads into database views. There's
one such view for every unique event signature like `Transfer(address
indexed from, address indexed to, uint256 value)` (not the signature
hash like `0xddf252ad...`).

The view `Transfer_address_from_address_to_uint256_tokenId` selects all
`Transfer` events of all ERC20 tokens. It queries the `logs` table for
events matching its signature hash and decodes their payloads with
functions like `to_address` and `to_uint256`, according to each
parameter type:

```sql
create or replace view event."Transfer_address_from_address_to_uint256_value_d" 
as select to_address(2,topics[1]::text) "from",
to_address(2,topics[2]::text) "to",
to_uint256(2,data::text) "value", 
address contract_address 
from data.logs where topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
```

---

# Event views

Querying views named after events like

```sql
select * from Transfer_address_from_address_to_uint256_value_d
```

is more convenient than filtering by event signatures (like
`0xddf252ad...` which you'd need to remember:

```sql
select * from logs where topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'
```

The resulting columns are named as event parameters and their values are
decoded from hex:

```
┌────────────────────────────────────────────┬────────────────────────────────────────────┬─────────────────────┬────────────────────────────────────────────┐
│                    from                    │                     to                     │        value        │                  address                   │
│                  varchar                   │                  varchar                   │       int128        │                  varchar                   │
├────────────────────────────────────────────┼────────────────────────────────────────────┼─────────────────────┼────────────────────────────────────────────┤
│ 0x2e3381202988d535e8185e7089f633f7c9998e83 │ 0x1a58aa618df8f1ec282748fef6185c1a1cc2faa6 │ 1100000000000000000 │ 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 │
└────────────────────────────────────────────┴────────────────────────────────────────────┴─────────────────────┴────────────────────────────────────────────┘
```

---

# Event view differences

A similar view for ERC721 `Transfer`s is different despite having the
same signature hash passed as `topic0='0xddf252ad...`. The difference is
in the parameter name `tokenId` vs `value` in ERC20, and the fact that
it's indexed and comes from `topic3` in ERC721 not from `data` in ERC20.

```sql
create or replace view event."Transfer_address_from_address_to_uint256_tokenId" 
as select to_address(2,topics[1]::text) "from",
to_address(2,topics[2]::text) "to",
to_uint256(2,topics[3]::text) "tokenId", address contract_address 
from data.logs where topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
```

Note the ERC20 view name
`Transfer_address_from_address_to_uint256_value_d` reflects this
difference with ERC721's
`Transfer_address_from_address_to_uint256_tokenId`.

---

# Contract views

To query for `Transfer`s of a specific token, you need to filter by the
token's contract address (WETH in this case):

```sql
select * from Transfer_address_from_address_to_uint256_value_d
where contract_address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
```

This works but you'd need to remember token addresses, while it's more
convenient to use names of contracts when they're known. For these named
contracts we create contract views:

```sql
select * from erc20.weth_evt_Transfer
```

will select and decode WETH `Transfer`s with the help of
`Transfer_address_from_address_to_uint256_value_d` filtered by
WETH's contract address `0xc02aaa39...`.

---

# Contract views cover many contracts
  
Just like an event view selects events of many contracts, a contract
view can select events of many contracts as well, like
`uniswap_v2."Pair_evt_Swap"` for the many pairs of Uniswap. These
contracts share the same name `Pair` and label `uniswap_v2`. 

Some contract views select only one specific contract, like
`erc20.weth_evt_Transfer` for the only WETH token.

We have about 504k contracts which are named and labelled.

---

# Contract schemas

Many contracts known to us by their names also have labels either by the
project they belong to like `aave`, or their standard like `erc20`. To
help find contract views we group them into schemas named after labels,
so that all events of `aave` contracts can be queried by views found in
schema `aave`:

- aave."AAVEToken_evt_Approval"
- aave."AAVEToken_evt_Transfer"
- aave."AaveCollateralVaultProxy_evt_Borrow"

Note that contracts named `AAVEToken` are ERC20 and can also be found in
`erc20` schema: `erc20."AAVEToken_evt_Transfer"`. 

Contracts can have multiple labels and their views can be found in 
several schemas.

---

# Discover events and contracts

Overall we have about 

- 14k event views in `event` schema (like
  `Transfer_address_from_address_to_uint256_value_d`)
- 3k labels as contract schemas (like `aave`)
- 47k contract views in different schemas (like
  `aave."AAVEToken_evt_Transfer"`)
  
The numbers will improve with more ABIs collected and more contracts
labelled.
  
These abstractions on top of the raw event `logs` table help greatly to
discover contracts and their events.



  
