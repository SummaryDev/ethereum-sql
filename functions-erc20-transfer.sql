
-- dummy table for hasura
create table if not exists erc20_transfer_result (
  "from"           text,
  "to"             text,
  "value"          numeric,
  transaction_hash text,
  block_timestamp  timestamp
);

grant all on erc20_transfer_result to hasura;


-- function for generic search takes the whole where clause
drop function if exists usdt_transfer_search("where" text, order_by text, "limit" int);

create or replace function usdt_transfer_search("where" text default true, order_by text default 'block_timestamp desc', "limit" int default 100)
  returns setof erc20_transfer_result as
$$
declare
  s text;
begin
  s := format('select "from", "to", value_uint128_array[1] "value", transaction_hash, block_timestamp from eth.usdt_transfer where %s order by %s limit %L', "where", order_by, "limit");
  raise notice 'usdt_transfer %', s;
  return query select "from", "to", "value", transaction_hash, block_timestamp from dblink('redshift_cluster_1_foreign_server', s) as ("from" text, "to" text, "value" numeric, transaction_hash text, block_timestamp timestamp);
end
$$
language plpgsql stable;

-- function for search by columns and block_timestamp time interval
drop function if exists usdt_transfer("from" text, "to" text, "value" dec, "begin" timestamp, "end" timestamp, order_by text, order_dir text, "limit" int);

create or replace function usdt_transfer("from" text default null, "to" text default null, "value" dec default null, "begin" timestamp default 'now'::timestamp - '1 month'::interval, "end" timestamp default 'now'::timestamp, order_by text default 'block_timestamp', order_dir text default 'desc', "limit" int default 100)
  returns setof erc20_transfer_result as
$$
declare
  w text := format('where block_timestamp between %L and %L', "begin", "end");
  s text;
begin
  assert order_by in ('from', 'to', 'value', 'block_timestamp'), 'cannot order_by this column: ' || order_by;
  assert order_dir in ('asc', 'desc'), 'order_dir must be desc or asc not: ' || order_dir;
  assert "limit" < 100001, 'maximum limit is 100000 cannot limit by: ' || "limit";

  if "from" is not null then w := format('%s and %I = %L', w, 'from', "from"); end if;
  if "to" is not null then w := format('%s and %I = %L', w, 'to', "to"); end if;
  if "value" is not null then w := format('%s and %I = %s', w, 'value', "value"); end if; -- numeric argument uses %s not quoted %L

  s := format('select "from", "to", value_uint128_array[1] "value", transaction_hash, block_timestamp from eth.usdt_transfer %s order by %I %s limit %L', w, order_by, order_dir, "limit");
  raise notice '%', s;

  return query select * from dblink('redshift_cluster_1_foreign_server', s) as ("from" text, "to" text, "value" numeric, transaction_hash text, block_timestamp timestamp);
end
$$
language plpgsql stable;

grant execute on function usdt_transfer to hasura;

-- test it out
select usdt_transfer();

select usdt_transfer('0xf509accd096a82ef2562d316669d0aa4b60f3796', '0x6310acfa399f583318d3b7f26ab1888c9e69444f', null, '2020-01-01', '2020-02-01');
select usdt_transfer('0xf509accd096a82ef2562d316669d0aa4b60f3796', '0x6310acfa399f583318d3b7f26ab1888c9e69444f', 489860000, '2020-01-01', '2020-02-01');

select usdt_transfer("begin" => '2020-01-01', "end" => '2020-02-01', "limit" => 100000, "to" => '0xf509accd096a82ef2562d316669d0aa4b60f3796');


-- function for aggregations
drop function usdt_transfer_summary("function" text, group_by text, "from" text, "to" text, "value" dec, "begin" timestamp, "end" timestamp, order_by text, order_dir text, "limit" int);

create or replace function usdt_transfer_summary("function" text default 'count', group_by text default 'trunc(block_timestamp)', "from" text default null, "to" text default null, "value" dec default null, "begin" timestamp default 'now'::timestamp - '1 month'::interval, "end" timestamp default 'now'::timestamp, order_by text default 'block_timestamp', order_dir text default 'desc', "limit" int default 100)
  returns setof erc20_transfer_result as
$$
declare
  w text := format('where block_timestamp between %L and %L', "begin", "end");
  s text;
begin
  assert order_by in ('from', 'to', 'value', 'block_timestamp'), 'cannot order_by this column: ' || order_by;
  assert order_dir in ('asc', 'desc'), 'order_dir must be desc or asc not: ' || order_dir;
  assert "limit" < 100001, 'maximum limit is 100000 cannot limit by: ' || "limit";

  if "from" is not null then w := format('%s and %I = %L', w, 'from', "from"); end if;
  if "to" is not null then w := format('%s and %I = %L', w, 'to', "to"); end if;
  if "value" is not null then w := format('%s and %I = %s', w, 'value', "value"); end if; -- numeric argument uses %s not quoted %L

  s := format('select "from", "to", value_uint128_array[1] "value", transaction_hash, block_timestamp from eth.usdt_transfer %s order by %I %s limit %L', w, order_by, order_dir, "limit");
  raise notice '%', s;

  return query select * from dblink('redshift_cluster_1_foreign_server', s) as ("from" text, "to" text, "value" numeric, transaction_hash text, block_timestamp timestamp);
end
$$
language plpgsql stable;

select * from dblink('redshift_cluster_1_foreign_server', 'select "from", "to", value_uint128_array[1] "value", transaction_hash, block_timestamp from eth.usdt_transfer where block_timestamp between ''2020-01-01'' and ''2020-01-02'' order by block_timestamp desc limit ''100'' ') as ("from" text, "to" text, "value" numeric, transaction_hash text, block_timestamp timestamp);

select * from dblink('redshift_cluster_1_foreign_server', 'select count(1), trunc(block_timestamp)::text from eth.usdt_transfer where block_timestamp between ''2020-01-01'' and ''2020-02-01'' group by trunc(block_timestamp)::text order by trunc(block_timestamp)::text desc limit ''100'' ') as ("count(1)" numeric, "group_by" text);

select * from dblink('redshift_cluster_1_foreign_server', 'select trunc(block_timestamp)::text, sum(value_uint128_array[1]) from eth.usdt_transfer where block_timestamp between ''2020-01-01'' and ''2020-02-01'' group by trunc(block_timestamp)::text order by trunc(block_timestamp)::text desc limit ''100'' ') as ("block_timestamp" text, "sum" numeric);

select * from dblink('redshift_cluster_1_foreign_server', 'select trunc(block_timestamp), avg(value_uint128_array[1]) from eth.usdt_transfer where block_timestamp between ''2019-01-01'' and ''2022-12-01'' group by 1 order by 1 desc limit ''100'' ') as ("block_timestamp" text, "sum" numeric);






-- function for search by columns and block_timestamp time interval
drop function if exists link_transfer("from" text, "to" text, "value" dec, "begin" timestamp, "end" timestamp, order_by text, order_dir text, "limit" int);

create or replace function link_transfer("from" text default null, "to" text default null, "value" dec default null, "begin" timestamp default 'now'::timestamp - '1 month'::interval, "end" timestamp default 'now'::timestamp, order_by text default 'block_timestamp', order_dir text default 'desc', "limit" int default 100)
  returns setof erc20_transfer_result as
$$
declare
  w text := format('where block_timestamp between %L and %L', "begin", "end");
  s text;
begin
  assert order_by in ('from', 'to', 'value', 'block_timestamp'), 'cannot order_by this column: ' || order_by;
  assert order_dir in ('asc', 'desc'), 'order_dir must be desc or asc not: ' || order_dir;
  assert "limit" < 100001, 'maximum limit is 100000 cannot limit by: ' || "limit";

  if "from" is not null then w := format('%s and %I = %L', w, 'from', "from"); end if;
  if "to" is not null then w := format('%s and %I = %L', w, 'to', "to"); end if;
  if "value" is not null then w := format('%s and %I = %s', w, 'value', "value"); end if; -- numeric argument uses %s not quoted %L

  s := format('select "from", "to", value_uint128_array[1] "value", transaction_hash, block_timestamp from eth.link_transfer %s order by %I %s limit %L', w, order_by, order_dir, "limit");
  raise notice '%', s;

  return query select * from dblink('redshift_cluster_1_foreign_server', s) as ("from" text, "to" text, "value" numeric, transaction_hash text, block_timestamp timestamp);
end
$$
language plpgsql stable;

grant execute on function link_transfer to hasura;

-- test it out
select link_transfer();

