create table app (name text primary key);

drop table if exists contract cascade;

create table contract (address text primary key, name text, app_name text references app);
create index on contract (app_name);
create index on contract (name);

drop table if exists abi cascade;

create table abi (hash text primary key, name text not null, signature text unique not null, unpack text, json text, columns text);
create index on abi (name);

drop table if exists event cascade;

create table event (contract_address text references contract, abi_hash text references abi, primary key (contract_address, abi_hash));

comment on table app is E'@listSuffix omit';
comment on table contract is E'@listSuffix omit';
comment on table abi is E'@listSuffix omit';
comment on table event is E'@listSuffix omit';
comment on constraint contract_app_name_fkey on contract is E'@fieldName app\n@foreignFieldName contracts\n@listSuffix omit';
comment on constraint event_abi_hash_fkey on event is E'@fieldName abi\n@foreignFieldName event\n@listSuffix omit';
comment on constraint event_contract_address_fkey on event is E'@fieldName contract\n@foreignFieldName event\n@listSuffix omit';

-- drop function if exists contract_events(c contract);
--
-- create or replace function contract_events(c contract)
--   returns setof event as $$
-- select event.*
-- from event
--   inner join contract_event
--     on (contract_event.hash = event.hash)
-- where contract_event.address = c.address;
-- $$
-- language sql
-- stable;

drop table if exists log cascade;

create table log (payload json, transaction_hash text, timestamp timestamp);

comment on table log is E'@omit';

create or replace function event_logs(e event, "after_timestamp" timestamp default 'now'::timestamp - '1 month'::interval, "before_timestamp" timestamp default 'now'::timestamp, order_dir text default 'desc', "limit" int default 10)
returns setof log as $$
declare
  w text := format('where block_timestamp between %L and %L and address = %L and topics[0] = %L', after_timestamp, before_timestamp, e.contract_address, e.abi_hash);
  s text;
  u text;
begin
  assert order_dir in ('asc', 'desc'), 'order_dir must be desc or asc not: ' || order_dir;
  assert "limit" < 1001, 'maximum limit is 1000 cannot limit by: ' || "limit";

  u := (select json from abi where hash = e.abi_hash);

  s := format('select %s, transaction_hash, block_timestamp from eth.logs %s order by block_timestamp %s limit %L', u, w, order_dir, "limit");
  raise notice '%', s;

  return query select * from dblink('redshift', s) as (payload json, transaction_hash text, "timestamp" timestamp);
end
$$
language plpgsql stable;

comment on function event_logs is E'@listSuffix omit';
