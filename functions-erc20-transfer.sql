-- this schema contains tables not visible to the users and not tracked by graphql
create schema hidden;

-- dummy table for function setof return
create table if not exists hidden.erc20_transfer_result (
  "from"           text,
  "to"             text,
  "value"          numeric,
  transaction_hash text,
  block_timestamp  timestamp
);
grant all on hidden.erc20_transfer_result to hasura;

-- dummy table for function setof return
create table if not exists hidden.erc20_transfer_summary_result (
  "group"           text,
  "value"           numeric
);
grant all on hidden.erc20_transfer_summary_result to hasura;

-- dummy table for function setof return
create table if not exists hidden.erc20_transfer_refresh_status_result (
  starttime         timestamp,
  endtime           timestamp,
  status            text,
  refresh_type      text
);
grant all on hidden.erc20_transfer_refresh_status_result to hasura;

-- function for generic search takes the whole where clause
-- drop function if exists erc20_transfer_search("where" text, order_by text, "limit" int);
--
-- create or replace function erc20_transfer_search("where" text default true, order_by text default 'block_timestamp desc', "limit" int default 100)
--   returns setof erc20_transfer_result as
-- $$
-- declare
--   s text;
-- begin
--   s := format('select "from", "to", value_uint128_array[1] "value", transaction_hash, block_timestamp from eth.usdt_transfer where %s order by %s limit %L', "where", order_by, "limit");
--   raise notice '%', s;
--   return query select "from", "to", "value", transaction_hash, block_timestamp from dblink('redshift', s) as ("from" text, "to" text, "value" numeric, transaction_hash text, block_timestamp timestamp);
-- end
-- $$
-- language plpgsql stable;

-- creates materialized view in redshift for erc20 transfers for a given contract address and ticker
drop procedure create_redshift_materialized_view_erc20_transfer(address text, ticker text);

create or replace procedure create_redshift_materialized_view_erc20_transfer(address text, ticker text) as $$
declare
  v text;
  s text;
  d text;
begin
  assert address is not null and length(address) > 0, 'address is empty';
  assert ticker is not null and length(ticker) > 0, 'ticker is empty';

  v := concat('eth.erc20_transfer_', lower(ticker));

  d := format('drop materialized view if exists %s', v);
  raise notice '%', d;
  perform dblink_exec('redshift', d);

  s := format('create materialized view %s auto refresh yes as select to_address(2, topics[1]::text) "from", to_address(2, topics[2]::text) "to", to_uint64_array(2, data::text) "value_uint64_array", to_uint128_array_or_null(2, data::text) "value_uint128_array", transaction_index, log_index, transaction_hash, block_number, block_hash, block_timestamp, date from eth.logs where topics[0] = ''0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'' and topics[1] is not null and topics[2] is not null and address = %L', v, lower(address));
  raise notice '%', s;
  perform dblink_exec('redshift', s);

end;
$$ language plpgsql;

-- create materialized views in redshift for top 5 tokens

/*
166613312	0xdac17f958d2ee523a2206206994597c13d831ec7 Tether USD USDT
129619403	0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 Wrapped Ether WETH
55258103	0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 USD Coin USDC
16179987	0x6b175474e89094c44da98b954eedeac495271d0f Dai Stablecoin DAI
12265041	0x514910771af9ca656af840dff83e8264ecf986ca ChainLink Token LINK
*/

call create_redshift_materialized_view_erc20_transfer('0xdac17f958d2ee523a2206206994597c13d831ec7', 'usdt');
call create_redshift_materialized_view_erc20_transfer('0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2', 'weth');
call create_redshift_materialized_view_erc20_transfer('0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'usdc');
call create_redshift_materialized_view_erc20_transfer('0x6b175474e89094c44da98b954eedeac495271d0f', 'dai');
call create_redshift_materialized_view_erc20_transfer('0x514910771af9ca656af840dff83e8264ecf986ca', 'link');
-- completed in 33 m 49 s

-- test it
select * from dblink('redshift', 'select block_timestamp from eth.erc20_transfer_link order by block_timestamp desc limit 10') as t(block_timestamp timestamp);

-- table to hold known erc20 tokens and a top node in graphql schema to attach redshift functions to
create table erc20(ticker varchar(8) primary key);

-- rows for top 5 tokens
insert into erc20 (ticker) values ('usdt');
insert into erc20 (ticker) values ('weth');
insert into erc20 (ticker) values ('usdc');
insert into erc20 (ticker) values ('dai');
insert into erc20 (ticker) values ('link');

-- function to search for erc20 transfers in redshift takes erc20 table so it attaches to erc20 node in graphile
drop function if exists erc20_transfer(erc20 erc20, "from" text, "to" text , "value" numeric , after_block_timestamp timestamp without time zone , "before_block_timestamp" timestamp without time zone , order_by text , order_dir text , "limit" integer );

create or replace function erc20_transfer("erc20" erc20, "from" text default null, "to" text default null, "value" dec default null, "after_block_timestamp" timestamp default 'now'::timestamp - '1 month'::interval, "before_block_timestamp" timestamp default 'now'::timestamp, order_by text default 'block_timestamp', order_dir text default 'desc', "limit" int default 10)
  returns setof hidden.erc20_transfer_result as
$$
declare
  ticker text := erc20.ticker;
  w text := format('where block_timestamp between %L and %L', "after_block_timestamp", "before_block_timestamp");
  s text;
  v text;
begin
  raise notice 'ticker %', ticker;

  assert ticker is not null and length(ticker) > 0, 'ticker is empty';
  assert order_by in ('from', 'to', 'value', 'block_timestamp'), 'cannot order_by this column: ' || order_by;
  assert order_dir in ('asc', 'desc'), 'order_dir must be desc or asc not: ' || order_dir;
  assert "limit" < 100001, 'maximum limit is 100000 cannot limit by: ' || "limit";

  v := concat('eth.erc20_transfer_', lower(ticker));

  if "from" is not null then w := format('%s and %I = %L', w, 'from', "from"); end if;
  if "to" is not null then w := format('%s and %I = %L', w, 'to', "to"); end if;
  if "value" is not null then w := format('%s and %I = %s', w, 'value', "value"); end if; -- numeric argument uses %s not quoted %L

  s := format('select "from", "to", value_uint128_array[1] "value", transaction_hash, block_timestamp from %s %s order by %I %s limit %L', v, w, order_by, order_dir, "limit");
  raise notice '%', s;

  return query select * from dblink('redshift', s) as ("from" text, "to" text, "value" numeric, transaction_hash text, block_timestamp timestamp);
end
$$
language plpgsql stable;

grant execute on function erc20_transfer to hasura;

-- test it out
select erc20_transfer(erc20.*) from erc20;
select erc20_transfer(erc20.*) from erc20 where ticker = 'usdt';
select erc20_transfer(erc20.*) from erc20 where ticker = 'link';
select erc20_transfer(erc20.*, "after_block_timestamp" => '2020-01-01', "before_block_timestamp" => '2020-02-01') from erc20 where ticker = 'link';
select erc20_transfer(erc20.*, "from" => '0xf509accd096a82ef2562d316669d0aa4b60f3796', "to" => '0x6310acfa399f583318d3b7f26ab1888c9e69444f', "after_block_timestamp" => '2020-01-01', "before_block_timestamp" => '2020-02-01') from erc20 where ticker = 'usdt';
select erc20_transfer(erc20.*, "from" => '0xf509accd096a82ef2562d316669d0aa4b60f3796', "to" => '0x6310acfa399f583318d3b7f26ab1888c9e69444f', "after_block_timestamp" => '2020-01-01', "before_block_timestamp" => '2020-02-01', "value" => 489868000) from erc20 where ticker = 'usdt';
select erc20_transfer(erc20.*, "after_block_timestamp" => '2020-01-01', "before_block_timestamp" => '2020-02-01', "limit" => 100000, "to" => '0xf509accd096a82ef2562d316669d0aa4b60f3796') from erc20 where ticker = 'usdt';


-- function for aggregations
drop function if exists erc20_transfer_summary(erc20 erc20, "function" text, group_by text, "from" text, "to" text, "value" dec, "begin" timestamp, "end" timestamp, order_by int, order_dir text, "limit" int);

create or replace function erc20_transfer_summary(erc20 erc20, "function" text default 'count', group_by text default 'trunc(block_timestamp)', "from" text default null, "to" text default null, "value" dec default null, "after_block_timestamp" timestamp default 'now'::timestamp - '1 month'::interval, "before_block_timestamp" timestamp default 'now'::timestamp, order_by int default 1, order_dir text default 'desc', "limit" int default 10)
  returns setof hidden.erc20_transfer_summary_result as
$$
declare
  ticker text := erc20.ticker;
  w text := format('where block_timestamp between %L and %L', "after_block_timestamp", "before_block_timestamp");
  s text;
  v text;
  g text;
begin
  raise notice 'ticker %', ticker;

  assert ticker is not null and length(ticker) > 0, 'ticker is empty';
  assert "function" in ('count', 'sum', 'avg', 'max', 'min'), 'cannot aggregate with this function: ' || "function";
  assert group_by in ('from', 'to', 'block_timestamp', 'trunc(block_timestamp)'), 'cannot group_by this column: ' || group_by; -- can only group by non numeric fields
  assert order_by in (1, 2), 'order_by must be 1 or 2 not: ' || order_by;
  assert order_dir in ('asc', 'desc'), 'order_dir must be desc or asc not: ' || order_dir;
  assert "limit" < 100001, 'maximum limit is 100000 cannot limit by: ' || "limit";

  v := concat('eth.erc20_transfer_', lower(ticker));

  if "from" is not null then w := format('%s and %I = %L', w, 'from', "from"); end if;
  if "to" is not null then w := format('%s and %I = %L', w, 'to', "to"); end if;
  if "value" is not null then w := format('%s and %I = %s', w, 'value', "value"); end if; -- numeric argument uses %s not quoted %L
  if starts_with(group_by, 'trunc(') then g := group_by; else g := format('%I', group_by); end if; -- don't quote group_by when it's trunc(block_timestamp)

  s := format('select %s, %s(value_uint128_array[1]) from %s %s group by 1 order by %s %s limit %L', g, "function", v, w, order_by, order_dir, "limit");
  raise notice '%', s;

  return query select * from dblink('redshift', s) as ("group" text, "value" numeric);
end
$$
language plpgsql stable;

grant execute on function erc20_transfer_summary to hasura;

-- test
select erc20_transfer_summary(erc20.*, after_block_timestamp => '2020-01-01', before_block_timestamp => '2020-02-01') from erc20 where ticker = 'usdt';
select erc20_transfer_summary(erc20.*, after_block_timestamp => '2020-01-01', before_block_timestamp => '2020-02-01', function=>'sum') from erc20 where ticker = 'usdt';
select erc20_transfer_summary(erc20.*, after_block_timestamp => '2020-01-01', before_block_timestamp => '2020-02-01', group_by=>'to') from erc20 where ticker = 'usdt';
select erc20_transfer_summary(erc20.*, after_block_timestamp => '2020-01-01', before_block_timestamp => '2020-02-01', group_by=>'to', function=>'sum', order_by=>2) from erc20 where ticker = 'usdt';
select erc20_transfer_summary(erc20.*, after_block_timestamp => '2020-01-01', before_block_timestamp => '2020-02-01', group_by=>'to', function=>'sum', order_by=>2, order_dir=>'asc') from erc20 where ticker = 'usdt';
-- will fail assert
select erc20_transfer_summary(erc20.*, after_block_timestamp => '2020-01-01', before_block_timestamp => '2020-02-01', function=>'stddev') from erc20 where ticker = 'usdt';
select erc20_transfer_summary(erc20.*, after_block_timestamp => '2020-01-01', before_block_timestamp => '2020-02-01', group_by=>'address') from erc20 where ticker = 'usdt';
select erc20_transfer_summary(erc20.*, after_block_timestamp => '2020-01-01', before_block_timestamp => '2020-02-01', order_by=>0) from erc20 where ticker = 'usdt';

-- function to query from redshift materialized view refresh status
drop function if exists erc20_transfer_refresh_status(erc20 erc20, "limit" int);

create or replace function erc20_transfer_refresh_status(erc20 erc20, "limit" int default 10)
  returns setof hidden.erc20_transfer_refresh_status_result as
$$
declare
  ticker text := erc20.ticker;
  w text := format('where db_name = %L and schema_name = %L', 'dev', 'eth');
  v text;
  s text;
begin
  raise notice 'ticker %', ticker;

  assert ticker is not null and length(ticker) > 0, 'ticker is empty';
  assert "limit" < 100001, 'maximum limit is 100000 cannot limit by: ' || "limit";

  v := concat('erc20_transfer_', lower(ticker));

  s := format('select starttime, endtime, status, refresh_type from SVL_MV_REFRESH_STATUS %s and mv_name = %L order by starttime desc limit %L', w, v, "limit");
  raise notice '%', s;

  return query select * from dblink('redshift', s) as (starttime timestamp, endtime timestamp, status text, refresh_type text);
end
$$
language plpgsql stable;

-- test it out
select ticker, erc20_transfer_refresh_status(erc20.*) from erc20;
select erc20_transfer_refresh_status(erc20.*) from erc20 where ticker = 'usdt';
select erc20_transfer_refresh_status(erc20.*) from erc20 where ticker = 'link';

