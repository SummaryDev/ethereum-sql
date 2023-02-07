create schema if not exists events;

create schema if not exists eth;
set search_path to eth;

drop table if exists app cascade;

create table app (name text primary key);

drop table if exists contract cascade;

create table contract (address varchar(66) primary key, name text, app_name text references app);

drop table if exists abi cascade;

create table abi (signature varchar(512) primary key, name text not null, hash text not null, unpack varchar(1024) not null, json varchar(1024) not null, canonical text not null, table_name text not null);

drop table if exists event cascade;

create table event (contract_address varchar(66) references contract, abi_signature varchar(512) references abi, primary key (contract_address, abi_signature));


/*drop procedure event_logs(contract_address text, abi_signature text, temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int);

create or replace procedure event_logs(contract_address text, abi_signature text, temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int)
as $$
declare
  w varchar(256);
  s varchar(10240);
  u varchar(10240);
  h varchar(66);
begin
  select json, hash into u, h from eth.abi where signature = abi_signature;
  if u is null or h is null then raise exception 'cannot find abi for signature %', abi_signature; end if;

  w := 'where block_timestamp between ' || quote_literal(nvl(after_timestamp, 'now'::timestamp - '1 month'::interval)) || ' and ' || quote_literal(nvl(before_timestamp, 'now'::timestamp)) || ' and address = ' || quote_literal(contract_address) || ' and topics[0] = ' || quote_literal(h);
  raise notice '%', w;

  s := 'select ' || u || ' as payload, transaction_hash, block_timestamp from eth.logs ' || w || ' order by block_timestamp ' || nvl(order_dir, 'desc') || ' limit ' || quote_literal(nvl("limit", 10));
  raise notice '%', s;

  execute 'set search_path to eth';
  execute 'drop table if exists ' || temp_table_name;
  execute 'create temp table ' || temp_table_name || ' as ' || s;
end
$$
  language plpgsql;

-- call event_logs('0x0aacfbec6a24756c20d41914f2caba817c0d8521', 'Transfer_address_from_address_to_uint256_amount_d', 't', 'now'::timestamp - '1 month'::interval, 'now'::timestamp, 'desc', 10);
-- select * from t;


drop procedure contract_logs(contract_address text, temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int);

create or replace procedure contract_logs(contract_address text, temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int)
as $$
declare
  w varchar(256);
  s varchar(10240);
  sunion varchar(10240);
begin
  w := 'where block_timestamp between ' || quote_literal(nvl(after_timestamp, 'now'::timestamp - '1 month'::interval)) || ' and ' || quote_literal(nvl(before_timestamp, 'now'::timestamp)) || ' and address = ' || quote_literal(contract_address);
  raise notice '%', w;

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

-- call contract_logs('0x0aacfbec6a24756c20d41914f2caba817c0d8521', 't', null, null, 'asc', 100);
-- select * from t;

-- select listagg('select ' || quote_literal(name) || ' name,' || json || ' payload, transaction_hash, block_timestamp from eth.logs and topics[0] = ' || quote_literal(hash), ' union all ') from eth.abi left join eth.event on abi.signature = event.abi_signature where event.contract_address = '0x0aacfbec6a24756c20d41914f2caba817c0d8521';*/