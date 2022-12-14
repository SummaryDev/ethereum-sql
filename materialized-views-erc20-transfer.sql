select count(1) from logs;

select count(1) from logs where topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'; -- 1 259 093 753

select count(1), address from logs where topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' group by address order by 1 desc limit 10;

/*
166613312	0xdac17f958d2ee523a2206206994597c13d831ec7 Tether USD USDT
129619403	0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 Wrapped Ether WETH
55258103	0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 USD Coin USDC
16179987	0x6b175474e89094c44da98b954eedeac495271d0f Dai Stablecoin DAI
12265041	0x514910771af9ca656af840dff83e8264ecf986ca ChainLink Token LINK
9096572	0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce SHIBA INU
8947684	0x174bfa6600bf90c885c7c01c7031389ed1461ab9
8001314	0x0e3a2a1f2146d86a604adc220b4967a898d7fe07
6972127	0x990f341946a3fdb507ae7e52d17851b87168017c
6680552	0x629cdec6acc980ebeebea9e5003bcd44db9fc5ce
*/

select can_overflow(2, data::text) from logs where topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null limit 1;

-- materialized view for all erc20 transfers
drop materialized view if exists erc20_transfers;

create materialized view erc20_transfers auto refresh yes as
select to_address(2, topics[1]::text) "from",
to_address(2, topics[2]::text) "to",
to_uint64_array(2, data::text) "value_uint64_array",
to_uint128_array_or_null(2, data::text) "value_uint128_array",
address, /*topics, */data::text, transaction_index, log_index, transaction_hash, block_number, block_hash, block_timestamp, date from logs
where topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null;
-- completed in 19 m 33 s

-- test
select value_uint64_array, value_uint128_array from erc20_transfers where date > '2022-12-01' limit 100;

-- check if any erc20 transfers overflow

select count(1) from logs where can_overflow(2, data::text) and topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null; -- 88515

select count(1) from logs where to_uint128_array_or_null(2, data::text) is not null and topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null; -- 1 252 499 715

select count(1) from logs where topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null; -- 1 252 588 230

select count(1) from logs where topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'; -- 1259093753

select count(1) from erc20_transfers where value_uint128_array is null; -- 88515

select sum(value_uint128_array[1]), "to" from erc20_transfers where address = '0xdac17f958d2ee523a2206206994597c13d831ec7' group by 2 order by 1 desc limit 100; -- execution: 35 s 422 ms

select data::text from erc20_transfers where address = '0xdac17f958d2ee523a2206206994597c13d831ec7' and value_uint128_array is null; -- no overflow for USDT

select count(1), address from erc20_transfers where value_uint128_array is null group by address; -- overflow offenders

select date, sum(value_uint128_array[1]) from erc20_transfers where address = '0xdac17f958d2ee523a2206206994597c13d831ec7' group by 1 order by 1 desc; -- execution: 15 s 532 ms; entire history USDT from 2017

select date, count(1) from erc20_transfers where address = '0xdac17f958d2ee523a2206206994597c13d831ec7' group by 1 order by 1 desc; -- execution: 13 s 706 ms

select count(1) from erc20_transfers where address = '0xdac17f958d2ee523a2206206994597c13d831ec7'; -- 166 613 312 usdt

select count(1), address from erc20_transfers group by 2 order by 1 desc limit 100; -- top tokens


-- materialized view for erc20 transfers of USDT 0xdac17f958d2ee523a2206206994597c13d831ec7
drop materialized view if exists usdt_transfer;

create materialized view usdt_transfer auto refresh yes as
select to_address(2, topics[1]::text) "from",
to_address(2, topics[2]::text) "to",
to_uint64_array(2, data::text) "value_uint64_array",
to_uint128_array_or_null(2, data::text) "value_uint128_array",
transaction_index, log_index, transaction_hash, block_number, block_hash, block_timestamp, date from logs
where address = '0xdac17f958d2ee523a2206206994597c13d831ec7' and topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null;
-- completed in 7 m 43 s

-- test
select * from usdt_transfer limit 10;

-- test usdt_transfer vs erc20_transfers
select sum(value_uint128_array[1]), "to" from usdt_transfer group by 2 order by 1 desc limit 10000; -- execution: 8 s 262 ms
select sum(value_uint128_array[1]), "to" from erc20_transfers where address = '0xdac17f958d2ee523a2206206994597c13d831ec7' group by 2 order by 1 desc limit 10000; -- execution: 36 s 10 ms

-- all events of top tokens
select count(1), topics[0] from logs where address = '0xdac17f958d2ee523a2206206994597c13d831ec7' group by 2 order by 1 desc;
select count(1), topics[0] from logs where address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2' group by 2 order by 1 desc;
select count(1), topics[0] from logs where address = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48' group by 2 order by 1 desc;
select count(1), topics[0] from logs where address = '0x6b175474e89094c44da98b954eedeac495271d0f' group by 2 order by 1 desc;
select count(1), topics[0] from logs where address = '0x514910771af9ca656af840dff83e8264ecf986ca' group by 2 order by 1 desc;



166613312	0xdac17f958d2ee523a2206206994597c13d831ec7 Tether USD USDT
129619403	0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 Wrapped Ether WETH
55258103	0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 USD Coin USDC
16179987	0x6b175474e89094c44da98b954eedeac495271d0f Dai Stablecoin DAI
12265041	0x514910771af9ca656af840dff83e8264ecf986ca ChainLink Token LINK


-- materialized view for erc20 transfers of 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 Wrapped Ether WETH
drop materialized view if exists weth_transfer;

create materialized view weth_transfer auto refresh yes as
select to_address(2, topics[1]::text) "from",
       to_address(2, topics[2]::text) "to",
       to_uint64_array(2, data::text) "value_uint64_array",
       to_uint128_array_or_null(2, data::text) "value_uint128_array",
  transaction_index, log_index, transaction_hash, block_number, block_hash, block_timestamp, date from logs
where address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2' and topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null;
-- completed in 7 m 43 s


-- materialized view for erc20 transfers of 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 USD Coin USDC
drop materialized view if exists usdc_transfer;

create materialized view usdc_transfer auto refresh yes as
select to_address(2, topics[1]::text) "from",
       to_address(2, topics[2]::text) "to",
       to_uint64_array(2, data::text) "value_uint64_array",
       to_uint128_array_or_null(2, data::text) "value_uint128_array",
  transaction_index, log_index, transaction_hash, block_number, block_hash, block_timestamp, date from logs
where address = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48' and topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null;
-- completed in 7 m 43 s


-- materialized view for erc20 transfers of 0x6b175474e89094c44da98b954eedeac495271d0f Dai Stablecoin DAI
drop materialized view if exists dai_transfer;

create materialized view dai_transfer auto refresh yes as
select to_address(2, topics[1]::text) "from",
       to_address(2, topics[2]::text) "to",
       to_uint64_array(2, data::text) "value_uint64_array",
       to_uint128_array_or_null(2, data::text) "value_uint128_array",
  transaction_index, log_index, transaction_hash, block_number, block_hash, block_timestamp, date from logs
where address = '0x6b175474e89094c44da98b954eedeac495271d0f' and topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null;
-- completed in 7 m 43 s


-- materialized view for erc20 transfers of 0x514910771af9ca656af840dff83e8264ecf986ca ChainLink Token LINK
drop materialized view if exists link_transfer;

create materialized view link_transfer auto refresh yes as
select to_address(2, topics[1]::text) "from",
       to_address(2, topics[2]::text) "to",
       to_uint64_array(2, data::text) "value_uint64_array",
       to_uint128_array_or_null(2, data::text) "value_uint128_array",
  transaction_index, log_index, transaction_hash, block_number, block_hash, block_timestamp, date from logs
where address = '0x514910771af9ca656af840dff83e8264ecf986ca' and topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null;

-- the above 4 tokens completed in 25 m 18 s


