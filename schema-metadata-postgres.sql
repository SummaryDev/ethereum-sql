create schema if not exists eth;
set search_path to eth;

drop table if exists app cascade;

create table app (name text primary key);

drop table if exists contract cascade;

create table contract (address text primary key, name text, app_name text references app);
create index on contract (app_name);
create index on contract (name);

drop table if exists abi cascade;

create table abi (signature text primary key, name text not null, hash text not null, unpack text not null, json text not null, columns text not null, signature_typed text not null, unpack_typed text not null);
create index on abi (hash);
create index on abi (name);

drop table if exists event cascade;

create table event (contract_address text references contract, abi_signature text references abi, primary key (contract_address, abi_signature));
create index on event (contract_address);
create index on event (abi_signature);

-- comment on table app is E'@listSuffix omit';
-- comment on table contract is E'@listSuffix omit';
-- comment on table abi is E'@listSuffix omit';
-- comment on table event is E'@listSuffix omit';
comment on constraint contract_app_name_fkey on contract is E'@fieldName app\n@foreignFieldName contracts';
comment on constraint event_abi_signature_fkey on event is E'@fieldName abi\n@foreignFieldName events';
comment on constraint event_contract_address_fkey on event is E'@fieldName contract\n@foreignFieldName events';

-- comment on constraint contract_app_name_fkey on contract is null;
-- comment on constraint event_abi_signature_fkey on event is null;
-- comment on constraint event_contract_address_fkey on event is null;


drop table if exists log cascade;

create table log (name text, payload json, transaction_hash text, timestamp timestamp);

comment on table log is E'@omit';


create or replace function event_logs(e event, "after_timestamp" timestamp default 'now'::timestamp - '1 month'::interval, "before_timestamp" timestamp default 'now'::timestamp, order_dir text default 'desc', "limit" int default 10)
returns setof log as $$
declare
  w text;
  s text;
  u text;
  h text;
  n text;
begin
  assert order_dir in ('asc', 'desc'), 'order_dir must be desc or asc not: ' || order_dir;
  assert "limit" < 1001, 'maximum limit is 1000 cannot limit by: ' || "limit";

  select name, json, hash into n, u, h from eth.abi where signature = e.abi_signature;
  if not found then raise exception 'cannot find abi for signature %',  e.abi_signature; end if;

  w := format('where block_timestamp between %L and %L and address = %L', after_timestamp, before_timestamp, e.contract_address);
  raise notice '%', w;

  s := format('set search_path to eth; select %s, transaction_hash, block_timestamp from eth.logs %s and topics[0] = %L order by block_timestamp %s limit %L', u, w, h, order_dir, "limit");
  raise notice '%', s;

  return query select n, * from eth.dblink('redshift', s) as (payload json, transaction_hash text, "timestamp" timestamp);
end
$$
language plpgsql stable;

-- adds the condition argument to this connection, allowing to filter the set by any of its scalar fields https://www.graphile.org/postgraphile/smart-tags/#filterable
comment on function event_logs is E'@filterable';

-- select event_logs(e) from event e where e.contract_address = '0x0aacfbec6a24756c20d41914f2caba817c0d8521';
-- select event_logs(e) from event e where e.contract_address = '0x0aacfbec6a24756c20d41914f2caba817c0d8521' and e.abi_signature = 'Transfer_address_from_address_to_uint256_amount_d';
select event_logs(e) from event e where e.contract_address = '0x00ee7423162d312a5c3bba6c4c7d8332c4d20f2c' and e.abi_signature = 'Transfer_address_from_address_to_uint256_amount_d';
select event_logs(e) from event e where e.contract_address = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48' and e.abi_signature = 'Transfer_address_from_address_to_uint256_value_d';
select event_logs(e, '2022-03-01', '2022-05-01') from event e where e.contract_address = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48' and e.abi_signature = 'Transfer_address_from_address_to_uint256_value_d';


drop function contract_logs(c contract, "after_timestamp" timestamp, "before_timestamp" timestamp , order_dir text, "limit" int);

create or replace function contract_logs(c contract, "after_timestamp" timestamp default 'now'::timestamp - '1 month'::interval, "before_timestamp" timestamp default 'now'::timestamp, order_dir text default 'desc', "limit" int default 10)
returns setof log as $$
declare
  w text;
  s text;
  sunion text;
begin
  assert order_dir in ('asc', 'desc'), 'order_dir must be desc or asc not: ' || order_dir;
  assert "limit" < 1001, 'maximum limit is 1000 cannot limit by: ' || "limit";

  w := 'where block_timestamp between ' || quote_literal(after_timestamp) || ' and ' || quote_literal(before_timestamp) || ' and address = ' || quote_literal(c.address);
  raise notice '%', w;

  select into sunion string_agg('select ' || quote_literal(name) || ' name,' || json || ' payload, transaction_hash, block_timestamp from eth.logs ' || w || ' and topics[0] = ' || quote_literal(hash), ' union all ') from eth.abi left join eth.event on abi.signature = event.abi_signature where event.contract_address = c.address;
  if not found then raise exception 'cannot find abi for contract %',  c.address; end if;
  raise notice '%', sunion;

  s := 'set search_path to eth; select * from (' || sunion || ') order by block_timestamp ' || order_dir || ' limit ' || quote_literal("limit");
  raise notice '%', s;

  return query select * from eth.dblink('redshift', s) as (name text, payload json, transaction_hash text, "timestamp" timestamp);
end
$$
language plpgsql stable;

-- adds the condition argument to this connection, allowing to filter the set by any of its scalar fields https://www.graphile.org/postgraphile/smart-tags/#filterable
comment on function contract_logs is E'@filterable';


-- select contract_logs(c, 'now'::timestamp - '1 month'::interval, 'now'::timestamp, 'desc', 10) from contract c where c.address = '0x0aacfbec6a24756c20d41914f2caba817c0d8521';
-- select contract_logs(c) from contract c where c.address = '0x0aacfbec6a24756c20d41914f2caba817c0d8521';
select contract_logs(c) from contract c where c.address = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48';