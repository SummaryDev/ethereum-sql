drop procedure event_logs(contract_address varchar(66), abi_signature varchar(512), temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int);

create or replace procedure event_logs(contract_address varchar(66), abi_signature varchar(512), temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int)
as $$
declare
  w varchar(256);
  s varchar(51200);
  u varchar(51200);
  h varchar(66);
  n varchar(256);
begin
  select json, hash, name into u, h, n from eth.abi where signature = abi_signature;
  if u is null or h is null then raise exception 'cannot find abi for signature %', abi_signature; end if;

  w := 'where block_timestamp between ' || quote_literal(nvl(after_timestamp, 'now'::timestamp - '1 month'::interval)) || ' and ' || quote_literal(nvl(before_timestamp, 'now'::timestamp)) || ' and address = ' || quote_literal(contract_address) || ' and topics[0] = ' || quote_literal(h);
  raise notice '%', w;

  s := 'select ' || quote_literal(n) || ' name, ' || u || ' payload, transaction_hash evt_tx_hash, log_index evt_index, block_timestamp evt_block_time, block_number evt_block_number from eth.logs ' || w || ' order by block_number ' || nvl(order_dir, 'desc') || ', log_index ' || nvl(order_dir, 'desc') || ' limit ' || quote_literal(nvl("limit", 10));
  raise notice '%', s;

  execute 'set search_path to public';
  execute 'drop table if exists ' || temp_table_name;
  execute 'create temp table ' || temp_table_name || ' as ' || s;
end
$$
  language plpgsql;

-- call event_logs('0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9', 'DelegatedPowerChanged(address indexed user,uint256 amount,uint8 delegationType)', 't', '2023-01-01', '2023-01-10', 'desc', 10);
-- select * from t order by evt_block_number desc, evt_index desc;


drop procedure contract_logs(contract_address varchar(66), temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int);

create or replace procedure contract_logs(contract_address varchar(66), temp_table_name in varchar(128), "after_timestamp" timestamp, "before_timestamp" timestamp, order_dir text, "limit" int)
as $$
declare
  w varchar(256);
  s varchar(51200);
  sunion varchar(51200);
begin
  w := 'where block_timestamp between ' || quote_literal(nvl(after_timestamp, 'now'::timestamp - '1 month'::interval)) || ' and ' || quote_literal(nvl(before_timestamp, 'now'::timestamp)) || ' and address = ' || quote_literal(contract_address);
  raise notice '%', w;

  select into sunion listagg('select ' || quote_literal(name) || ' name,' || json || ' payload, transaction_hash evt_tx_hash, log_index evt_index, block_timestamp evt_block_time, block_number evt_block_number from eth.logs ' || w || ' and topics[0] = ' || quote_literal(hash), ' union all ') from eth.abi left join eth.event on abi.signature = event.abi_signature where event.contract_address = contract_address;
  if not found then raise exception 'cannot find abi for contract %',  contract_address; end if;
  raise notice '%', sunion;

  s := 'select * from (' || sunion || ') order by evt_block_number ' || nvl(order_dir, 'desc') || ', evt_index ' || nvl(order_dir, 'desc') || ' limit ' || quote_literal(nvl("limit", 10));
  raise notice '%', s;

  execute 'set search_path to public';
  execute 'drop table if exists ' || temp_table_name;
  execute 'create temp table ' || temp_table_name || ' as ' || s;
end
$$
language plpgsql;

-- call contract_logs('0x0aacfbec6a24756c20d41914f2caba817c0d8521', 't', null, null, 'asc', 100);
-- call contract_logs('0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9', 't', '2023-01-01', '2023-01-10', 'desc', 100);
-- select * from t order by evt_block_number desc, evt_index desc;
