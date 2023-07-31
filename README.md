# SQL for Ethereum

This repo hosts tools to help analyze data of Ethereum and other EVM
blockchains by databases Postgres, Amazon Redshift, DuckDb.

- User defined SQL functions to decode ABI encoded data emitted by smart
  contracts.
- Utilities to parse ABI files to extract event metadata and create SQL
  scripts to query contract logs.

## SQL functions to decode with ABI

Smart contracts notify their users by emitting event logs with payloads
encoded according to the ABI
[spec](https://docs.soliditylang.org/en/develop/abi-spec.html). Their
attributes are encoded as hex and passed in three fields called *topics*
and one field *data*. The first topic is a hash of the event's name and
the types of its attributes.

Token *Transfer* event for example, carries *to*, *from* as addresses
and *amount* as uint256, packed in a log like this:

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

We store events as raw logs in relational databases like Postgres or
Redshift, or in Parquet files to analyze with SQL queries. Their encoded
attributes however are hard to consume. If we need to sum up numeric
attributes and read addresses and text, we need to see them decoded in
our queries.

Fortunately, databases have rich libraries of built-in functions that
can be combined into user defined functions to decode these values. We
just need to know how they are defined and to follow the ABI spec.

For example, to decode the above `value` attribute we can use function
`to_uint256`:

```sql
select to_uint256(2, '0x000000000000000000000000000000000000000000000000aad50c474db4eb50')
```

to get its decimal representation `12309758656873032448` which can now 
be used in calculations.

This user defined function `to_uint256` uses built-in functions

- for Postgres: concat, substring, lpad, and casts to bit(64) and
  bigint; see [functions-postgres.sql](./functions-postgres.sql)
- for Redshift: substring, strol; see
  [functions-redshift.sql](./functions-redshift.sql)
  
Postgres and Redshift built-in functions differ, so we define low level
functions like `to_uint256` separately for each database, and then
define common high level functions like `to_array`. To create the full
library we need to create low functions specific to our database with
[functions-postgres.sql](./functions-postgres.sql) then high functions
with [functions.sql](./functions.sql).

The library has functions to decode the vast majority of attribute
types:

- to_uint256, to_uint128, to_uint64, to_in64, to_int32 etc.
- to_address, to_string, to_bytes
- to_array, to_fixed array

and others.

They correspond to types defined by the ABI spec:

- address: to_address()
- uint256: to_uint256()
- string: to_string()
- uint256[]: to_array('uint256')
- address[]: to_array('address')
- address[2]: to_fixed_array('address', 2)

and so on. For the full list see `supportedTypesDict` in
[util.js](./util.js). Please note this is WIP and we may lack a function
to decode some rare type in which case we'll return its raw value.

Now armed with the functions we can decode logs if we know their
attribute types and names. From this row with a raw log:

| address                                    | topic0                                                             | topic1                                                             | topic2                                                             | topic3 | data                                                               | block_hash                                                         | block_number | transaction_hash                                                   | transaction_index | log_index | transaction_log_index | removed | block_timestamp |
|--------------------------------------------|--------------------------------------------------------------------|--------------------------------------------------------------------|--------------------------------------------------------------------|--------|--------------------------------------------------------------------|--------------------------------------------------------------------|--------------|--------------------------------------------------------------------|-------------------|-----------|-----------------------|---------|-----------------|
| 0xcd3b51d98478d53f4515a306be565c6eebef1d58 | 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000f78031c993afb43e79f017938326ff34418ec36e |        | 0x000000000000000000000000000000000000000000000000aad50c474db4eb50 | 0x09f1e5619fcbfaa873fcf4e924b724dac6b84e0f9c02341f75c11393d586792b | 222431       | 0xf9a7cefb1ab525781aac1b0ca29bf76b90cd2f16e22ee9e91cf7d2dcae78aa08 | 6                 | 18        | 1                     | false   |                 |

You can get to this row of a decoded `Transfer` event:

| from                                       | to                                         | value                | contract_address                           |
|--------------------------------------------|--------------------------------------------|----------------------|--------------------------------------------|
| 0x0000000000000000000000000000000000000000 | 0xf78031c993afb43e79f017938326ff34418ec36e | 12309758656873032448 | 0xcd3b51d98478d53f4515a306be565c6eebef1d58 |

With a SQL query like this:

```sql
select to_address(topic1) "from",
       to_address(topic2) "to",
       to_uint256(data)   "value",
       address            contract_address
from data.logs
where topic0 = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
```

## ABI parser

The functions introduced above are sufficient to decode events we know
well together with their attributes' location, types and names, like for
the ubiquitous Transfer. A Dapp however can run with a dozen contracts
emitting dozens of various events, and crafting correct SQL selects for
each of them may become unmanageable. Let's wrap these selects into
database views one per event, so they give us convenient abstractions of
events. Then a view for our Transfer event can be used in a query like
so:

```sql
select sum(value), "to" from Transfer_address_from_address_to_uint256_value_d group by 2 order by 1 desc
```

This view was created out of the select statement in the previous
section and the source of its data is still raw logs in `data.logs`.
Note its name `Transfer_address_from_address_to_uint256_value_d`
contains event attributes as there may be other Transfer events with
different attributes, like the one for erc721:
`Transfer_address_from_address_to_uint256_tokenId`.

Most deployed contracts publish their ABI in json files to help
interpret their logs. Our Transfer event is defined in ABI as:

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

From this snippet we know the attribute *from* is of type *address* and
comes in the second topic as it's *indexed* and so on. This definition
is sufficient to create a query for a view to decode all raw Transfer
logs.

We can parse an ABI file of any contract and create view definitions for
every event described in it. If we gather ABI files for all the
contracts we extracted logs for, we can create views for all of their
events. Our database of raw logs will then become user friendly with
event views with recognizable names and columns, returning decoded
values we can analyze.

```
event.ApprovalForAll_address_owner_address_operator_bool_approved_d
event.Deposit_address_user_uint256_pid_uint256_amount_d
event.Transfer_address_from_address_to_uint256_tokenId
event.Transfer_address_from_address_to_uint256_value_d
event.Withdraw_address_withdrawer_d_uint256_amount_d
```

## Contract metadata

Event views we just introduced work well to query events of contracts
whose addresses we know. For example, to select Transfers of USDC we
filter on its address we got from
[Etherscan](https://etherscan.io/token/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48).

```sql
select * from event.Transfer_address_from_address_to_uint256_value_d 
where contract_address = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48';
```

But beyond popular tokens and addresses we would also like to explore
Dapps and the events they emit even if we don't know their
addresses and names.

There are sources like block explorers and Github repos that publish
names and labels for contracts, usually together with their ABI files.
These labels are better suited to navigate Dapps and their contracts:
labels can be project names like aave, uniswap, beamswap or standards
like erc20, erc721, and names of contracts are descriptive like
AmmFactory or Staking or USDT.

We can gather contracts' names and labels from open sources and use them
to create additional event views per contract, then group them into
schemas named like their labels. For example, Transfer events of a
contract identified as USDT and labeled erc20 can be found in a view
named `erc20.USDT_evt_Transfer`. A great number of Dapp events can be
explored by selecting from views like
`beamswap.AmmFactoryV1_evt_PairCreated` and the like.

Note that these *contract views* like `erc20.USDT_evt_Transfer` still
select from *event views* like
`event.Transfer_address_from_address_to_uint256_value_d` with a filter
on a known contract address.

```
beamswap.AmmFactoryV1_evt_PairCreated
beamswap.FactoryV3V1_evt_OwnerChanged
beamswap.FactoryV3V1_evt_SetLmPoolDeployer
beamswap.GlintTokenV1_evt_Approval
beamswap.GlintTokenV1_evt_Transfer
```

## Examples

We can now show how to parse ABI files and contract metadata to create
event and contract views for Dapp [Beamswap](https://beamswap.io/)
deployed to a Polkadot EVM parachain
[Moonbeam](https://moonbeam.network/). 

Please see our other repo
[evm-archive](https://github.com/SummaryDev/evm-archive) for an ETL tool
to extract raw logs from an EVM full node and load them into `data.logs`
table of your database.

Beamswap
[publishes](https://docs.beamswap.io/developers/beamswap-contracts)
addresses and names of its 12 smart contracts. Their ABIs can be
downloaded from block explorer
[Moonscan](https://moonscan.io/address/0x985BcA32293A7A496300a48081947321177a86FD#code).

We added the files to this repo in [input/beamswap](./input/beamswap);
their names are concatenations of contract addresses and names (like
`0x2fc63231f734850c4b8c6b80c275fdb66983846fStable Pool Nomad V1.json`)
as extra inputs to the parser. TODO there must be a better way to
organize this.

### Generate view definitions and metadata

Run the parser to read the ABI files. It's a standalone js script and
requires Node.js installed.

```shell
node parse-abi-files.js
```

The parser will produce:

- definitions of contract label schemas
  `parse-abi-create-label-schema.sql`
- event view definitions `parse-abi-event-view.sql`
- contract view definitions `parse-abi-contract-view.sql`
- records of metadata in CSV files to be loaded into tables in schema
  *metadata*
  - *abi*: event names, signatures, parsing logic `parse-abi-abi.csv`
  - *event*: many-to-many relationship of events to contracts
    `parse-abi-event.csv`
  - *contract*: addresses, names, labels `parse-abi-contract.csv`
  - *label*: contract labels `parse-abi-label.csv`

Take a peek into these scripts to see the SQL statements we talked
about.

Statements to create event views in schema *event*. These views define
logic to parse raw logs and don't depend on any metadata tables. You can
create *event* schema, execute this file and start exploring decoded
events right away.

```sql
create or replace view event."AddLiquidity_address_provider_uint256___tokenAmounts_d_uint256___fees_d_uint256_invariant_d_uint256_lpTokenSupply_d" as select to_address(2,topic1::text) "provider",to_array(2,data::text,'to_uint256') "tokenAmounts",to_array(66,data::text,'to_uint256') "fees",to_uint256(130,data::text) "invariant",to_uint256(194,data::text) "lpTokenSupply", address contract_address, transaction_hash evt_tx_hash, log_index evt_index, block_timestamp evt_block_time, block_number evt_block_number from data.logs where topic0 = '0x189c623b666b1b45b83d7178f39b8c087cb09774317ca2f53c2d3c3726f222a2';
create or replace view event."FlashLoan_address_receiver_uint8_tokenIndex_d_uint256_amount_d_uint256_amountFee_d_uint256_protocolFee_d" as select to_address(2,topic1::text) "receiver",to_uint32(2,data::text) "tokenIndex",to_uint256(66,data::text) "amount",to_uint256(130,data::text) "amountFee",to_uint256(194,data::text) "protocolFee", address contract_address, transaction_hash evt_tx_hash, log_index evt_index, block_timestamp evt_block_time, block_number evt_block_number from data.logs where topic0 = '0x7c186b2827b23e9024e7b29869cba58a97a4bac6567802a8ea6a8afa7b8c22f0';
create or replace view event."NewAdminFee_uint256_newAdminFee_d" as select to_uint256(2,data::text) "newAdminFee", address contract_address, transaction_hash evt_tx_hash, log_index evt_index, block_timestamp evt_block_time, block_number evt_block_number from data.logs where topic0 = '0xab599d640ca80cde2b09b128a4154a8dfe608cb80f4c9399c8b954b01fd35f38';
```

Statements to create contract views in schema *beamswap* (if you process
ABI sources for contracts of other Dapps they will use their own
schemas). These views depend on metadata tables to relate contracts and
events.

```sql
create or replace view beamswap."StablePoolNomadV1_evt_AddLiquidity" as select v.* from event."AddLiquidity_address_provider_uint256___tokenAmounts_d_uint256___fees_d_uint256_invariant_d_uint256_lpTokenSupply_d" v left join metadata.event e on lower(e.contract_address) = lower(v.contract_address) left join metadata.contract c on lower(e.contract_address) = lower(c.address) where e.abi_signature = 'AddLiquidity(address indexed provider,uint256[] tokenAmounts,uint256[] fees,uint256 invariant,uint256 lpTokenSupply)' and c.label = 'beamswap' and c.name = 'StablePoolNomadV1';
create or replace view beamswap."StablePoolNomadV1_evt_FlashLoan" as select v.* from event."FlashLoan_address_receiver_uint8_tokenIndex_d_uint256_amount_d_uint256_amountFee_d_uint256_protocolFee_d" v left join metadata.event e on lower(e.contract_address) = lower(v.contract_address) left join metadata.contract c on lower(e.contract_address) = lower(c.address) where e.abi_signature = 'FlashLoan(address indexed receiver,uint8 tokenIndex,uint256 amount,uint256 amountFee,uint256 protocolFee)' and c.label = 'beamswap' and c.name = 'StablePoolNomadV1';
create or replace view beamswap."ShareTokenV1_evt_Approval" as select v.* from event."Approval_address_owner_address_spender_uint256_value_d" v left join metadata.event e on lower(e.contract_address) = lower(v.contract_address) left join metadata.contract c on lower(e.contract_address) = lower(c.address) where e.abi_signature = 'Approval(address indexed owner,address indexed spender,uint256 value)' and c.label = 'beamswap' and c.name = 'ShareTokenV1';
create or replace view beamswap."ShareTokenV1_evt_Transfer" as select v.* from event."Transfer_address_from_address_to_uint256_value_d" v left join metadata.event e on lower(e.contract_address) = lower(v.contract_address) left join metadata.contract c on lower(e.contract_address) = lower(c.address) where e.abi_signature = 'Transfer(address indexed from,address indexed to,uint256 value)' and c.label = 'beamswap' and c.name = 'ShareTokenV1';
create or replace view beamswap."StakingV1_evt_CycleStakingPercentUpdated" as select v.* from event."CycleStakingPercentUpdated_address_token_uint256_previousValue_d_uint256_newValue_d" v left join metadata.event e on lower(e.contract_address) = lower(v.contract_address) left join metadata.contract c on lower(e.contract_address) = lower(c.address) where e.abi_signature = 'CycleStakingPercentUpdated(address indexed token,uint256 previousValue,uint256 newValue)' and c.label = 'beamswap' and c.name = 'StakingV1';
```

### End to end with Postgres

Run a shell script to generate and apply SQL to your Postgres database,
in the correct order:

- generate view definitions and metadata from ABI files
- create metadata schema in your Postgres database
- copy metadata csv to Postgres tables
- create schemas for contract labels
- create low level functions
- create high level functions
- create event views
- create contract views

Make sure Postgres client [psql](https://www.postgresql.org/download/)
is installed and connection to your database is defined with env
variables `PGHOST` et al.; see [example.env](./example.env).

```shell
./copy-metadata-postgres.sh 
```








