# SQL for Ethereum

This repo hosts tools to help analyze data of EVM compatible blockchains
by databases Postgres, Amazon Redshift, DuckDb.

- User defined SQL functions to parse ABI encoded data emitted by smart
contracts.
- Utilities to parse ABI files to extract event metadata and create SQL
scripts to decode onchain data.

## ABI functions

Smart contracts notify their clients by emitting event logs with
payloads encoded according to the ABI
[spec](https://docs.soliditylang.org/en/develop/abi-spec.html). Their
attributes are encoded as hex and passed in three fields called *topics*
and one field *data*. The first topic is a hash of the event name and
types of its attributes.

A `Transfer` event for example, carries `to`, `from` as addresses and
`amount` as uint256, packed in a log like this:

```json
{
  "address": "0xcd3b51d98478d53f4515a306be565c6eebef1d58",
  "topics": [
    "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
    "0x0000000000000000000000000000000000000000000000000000000000000000",
    "0x000000000000000000000000f78031c993afb43e79f017938326ff34418ec36e"
  ],
  "data": "0x000000000000000000000000000000000000000000000000aad50c474db4eb50"
}
```

Here 

- topic0 is the hash of `Transfer(address,address,uint256)`
- topic1 is `from` address `0x0000000000000000000000000000000000000000`
- topic2 is `to` address `0xf78031c993afb43e79f017938326ff34418ec36e`
- data is `value` uint256 `12309758656873032448`

We store events as raw encoded logs in relational databases like
Postgres or Redshift, or in Parquet files. Their encoded attributes
however are impossible to analyze: we need to sum up number attributes
and read addresses and text, so we need to decode them in our queries.
Fortunately, databases have rich libraries of built in functions that
can be combined into user defined functions to decode these values by
following the ABI spec.

To decode the `value` attribute we use function `to_uint256`

```sql
select to_uint256(2, '0x000000000000000000000000000000000000000000000000aad50c474db4eb50')
```

to get its decimal representation `12309758656873032448` which can now 
be used in calculations.

This function `to_uint256` uses functions

- for Postgres: concat, substring, lpad and casts to bit(64) and bigint;
  see [functions-postgres.sql](./functions-postgres.sql)
- for Redshift: substring, strol; see
  [functions-redshift.sql](./functions-redshift.sql)
  
Postgres and Redshift functions differ so we define low level functions
like `to_uint256` separately and then base on them high level functions
like `to_array`. To create the full library we need to create low
functions specific to our database with
[functions-postgres.sql](./functions-postgres.sql) then high functions
with [functions.sql](./functions.sql).

The library has functions to decode the vast majority of attribute
types:

- to_uint256, to_uint128, to_uint64, to_in64, to_int32 etc.
- to_address, to_string, to_bytes
- to_array, to_fixed array

and others.

They correspond to types defined by the ABI spec:

- address to_address()
- uint256 to_uint256()
- string to_string()
- uint256[] to_array('uint256')
- address[] to_array('address')
- address[2] to_fixed_array('address', 2)

and so on. For the full list see `supportedTypesDict` in
[util.js](./util.js).

Now armed with these function we can decode logs if we know their
attribute types and names. From this row with a raw log:

| address                                    | topic0                                                             | topic1                                                             | topic2                                                             | topic3 | data                                                               | block_hash                                                         | block_number | transaction_hash                                                   | transaction_index | log_index | transaction_log_index | removed | block_timestamp |
|--------------------------------------------|--------------------------------------------------------------------|--------------------------------------------------------------------|--------------------------------------------------------------------|--------|--------------------------------------------------------------------|--------------------------------------------------------------------|--------------|--------------------------------------------------------------------|-------------------|-----------|-----------------------|---------|-----------------|
| 0xcd3b51d98478d53f4515a306be565c6eebef1d58 | 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000f78031c993afb43e79f017938326ff34418ec36e |        | 0x000000000000000000000000000000000000000000000000aad50c474db4eb50 | 0x09f1e5619fcbfaa873fcf4e924b724dac6b84e0f9c02341f75c11393d586792b | 222431       | 0xf9a7cefb1ab525781aac1b0ca29bf76b90cd2f16e22ee9e91cf7d2dcae78aa08 | 6                 | 18        | 1                     | false   |                 |

You can get to this row of a decoded `Transfer` event:

| from                                       | to                                         | value                | contract_address                           |
|--------------------------------------------|--------------------------------------------|----------------------|--------------------------------------------|
| 0x0000000000000000000000000000000000000000 | 0xf78031c993afb43e79f017938326ff34418ec36e | 12309758656873032448 | 0xcd3b51d98478d53f4515a306be565c6eebef1d58 |

With a SQL select like:

```sql
select to_address(topic1) "from",
       to_address(topic2) "to",
       to_uint256(data)   "value",
       address            contract_address
from data.logs
where topic0 = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
```

## ABI parser

The functions described above are sufficient to decode events we know
well with their attribute locations, types and names, like for the
ubiquitous Transfer. A Dapp however can consist of a dozen contracts
emitting dozens of different events and crafting correct SQL selects may
become too hard. So we pack these selects into database views one per
event definition so they present a higher level view of an event. A view
for out Transfer event can be used in a query like so:

```sql
select sum(value), "to" from Transfer_address_from_address_to_uint256_value_d group by 2 order by 1 desc
```

This view was created out of the select statement in the previous
section and the source of its data is still raw logs in `data.logs`.
Note its full name `Transfer_address_from_address_to_uint256_value_d`
contains its attributes as there may be other Transfer events with
different attributes.

Most deployed contracts publish their ABI in json files with data
sufficient to interpret their logs. Our Transfer event is defined as:

```json
{
  "anonymous": false,
  "inputs": [
    {
      "indexed": true,
      "name": "from",
      "type": "address"
    },
    {
      "indexed": true,
      "name": "to",
      "type": "address"
    },
    {
      "indexed": false,
      "name": "value",
      "type": "uint256"
    }
  ],
  "name": "Transfer",
  "type": "event"
}
```

From this we know the attribute *from* is of type address and comes in
the second topic as it's *indexed* and so on. Now given a json file with
a contract's ABI we can parse it and create view definitions for every
event described in it. If we gather ABI files for all the contracts we
extracted logs for we can create views for each of them and our database
of raw logs now becomes user friendly with many views to query from,
named by event names and producing decoded values.




