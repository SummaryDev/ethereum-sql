create schema if not exists eth;
set search_path to eth;

drop table if exists app cascade;

create table app (name text primary key);

drop table if exists contract cascade;

create table contract (address text primary key, name text, app_name text references app);

drop table if exists abi cascade;

create table abi (signature text primary key, name text not null, hash text not null, unpack text not null, json text not null, columns text not null, signature_typed text not null, unpack_typed text not null);

drop table if exists event cascade;

create table event (contract_address text references contract, abi_signature text references abi, primary key (contract_address, abi_signature));


drop procedure event_logs(contract_address text, abi_signature text, temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int);

create or replace procedure event_logs(contract_address text, abi_signature text, temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int)
as $$
declare
  w varchar(1024);
  s varchar(1024);
  u varchar(1024);
  h varchar(66);
begin
  select json, hash into u, h from eth.abi where signature = abi_signature;

  if u is null or h is null then raise exception 'cannot find abi for signature %', abi_signature; end if;

  w := 'where block_timestamp between ' || quote_literal(nvl(after_timestamp, 'now'::timestamp - '1 month'::interval)) || ' and ' || quote_literal(nvl(before_timestamp, 'now'::timestamp)) || ' and address = ' || quote_literal(contract_address) || ' and topics[0] = ' || quote_literal(h);

  s := 'select ' || u || ' as payload, transaction_hash, block_timestamp from eth.logs ' || w || ' order by block_timestamp ' || nvl(order_dir, 'desc') || ' limit ' || quote_literal(nvl("limit", 10));
  raise notice '%', s;

  execute 'set search_path to eth';
  execute 'drop table if exists ' || temp_table_name;
  execute 'create temp table ' || temp_table_name || ' as ' || s;
end
$$
  language plpgsql;

-- begin; call event_logs('0x0aacfbec6a24756c20d41914f2caba817c0d8521', 'Transfer_address_indexed_from_address_indexed_to_uint256_amount', 'now'::timestamp - '1 month'::interval, 'now'::timestamp, 'desc', 10, 't'); select * from t; end;

drop procedure contract_logs(contract_address text, temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int);

create or replace procedure contract_logs(contract_address text, temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int)
as $$
declare
  w varchar(1024);
  s varchar(2048);
  sunion varchar(2048);
begin
  w := 'where block_timestamp between ' || quote_literal(nvl(after_timestamp, 'now'::timestamp - '1 month'::interval)) || ' and ' || quote_literal(nvl(before_timestamp, 'now'::timestamp)) || ' and address = ' || quote_literal(contract_address);

  select into sunion listagg('select ' || quote_literal(name) || ' name,' || json || ' payload, transaction_hash, block_timestamp from eth.logs ' || w || ' and topics[0] = ' || quote_literal(hash), ' union all ') from eth.abi left join eth.event on abi.signature = event.abi_signature where event.contract_address = contract_address;
  if not found then raise exception 'cannot find abi for contract %',  contract_address; end if;

  raise notice '%', sunion;

  s := 'select * from (' || sunion || ') order by block_timestamp ' || nvl(order_dir, 'desc') || ' limit ' || quote_literal(nvl("limit", 10));
  raise notice '%', s;

  execute 'set search_path to eth';
  execute 'drop table if exists ' || temp_table_name;
  execute 'create temp table ' || temp_table_name || ' as ' || s;
end
$$
language plpgsql;

call contract_logs('0x0aacfbec6a24756c20d41914f2caba817c0d8521', 't', null, null, 'asc', 100);

select * from t;