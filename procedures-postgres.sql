set search_path to eth;

drop table if exists log cascade;

create table log (name text, payload json, transaction_hash text, log_index int, block_timestamp timestamp, block_number int);

comment on table log is E'@omit';


create or replace function event_logs(e event, "after_timestamp" timestamp default 'now'::timestamp - '1 month'::interval, "before_timestamp" timestamp default 'now'::timestamp, order_dir text default 'desc', "limit" int default 10)
returns setof log as $$
declare
  s text;
begin
  assert order_dir in ('asc', 'desc'), 'order_dir must be desc or asc not: ' || order_dir;
  assert "limit" < 1001, 'maximum limit is 1000 cannot limit by: ' || "limit";

  s := format('call event_logs(%L, %L, ''t'', %L, %L, %L, %s); select * from t order by evt_block_number desc, evt_index desc;', e.contract_address, e.abi_signature, after_timestamp, before_timestamp, order_dir, "limit");
  raise notice '%', s;

  return query select * from eth.dblink('redshift', s) as (name text, payload json, transaction_hash text, log_index int, block_timestamp timestamp, block_number int);
end
$$
language plpgsql stable;

-- adds the condition argument to this connection, allowing to filter the set by any of its scalar fields https://www.graphile.org/postgraphile/smart-tags/#filterable
comment on function event_logs is E'@filterable';

-- select event_logs(e) from event e where e.contract_address = '0x0aacfbec6a24756c20d41914f2caba817c0d8521';
-- select event_logs(e) from event e where e.contract_address = '0x0aacfbec6a24756c20d41914f2caba817c0d8521' and e.abi_signature = 'Transfer_address_from_address_to_uint256_amount_d';
-- select event_logs(e) from event e where e.contract_address = '0x00ee7423162d312a5c3bba6c4c7d8332c4d20f2c' and e.abi_signature = 'Transfer_address_from_address_to_uint256_amount_d';
-- select event_logs(e) from event e where e.contract_address = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48' and e.abi_signature = 'Transfer_address_from_address_to_uint256_value_d';
-- select event_logs(e, '2022-03-01', '2022-05-01') from event e where e.contract_address = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48' and e.abi_signature = 'Transfer(address indexed by,address indexed from,address indexed to,uint256 value)';
-- select event_logs(e, '2023-01-01', '2023-01-10') from event e where e.contract_address = '0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9' and e.abi_signature = 'DelegatedPowerChanged(address indexed user,uint256 amount,uint8 delegationType)';
-- select event_logs(e) from event e where e.contract_address = '0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9';



--drop function contract_logs(c contract, "after_timestamp" timestamp, "before_timestamp" timestamp , order_dir text, "limit" int);

create or replace function contract_logs(c contract, "after_timestamp" timestamp default 'now'::timestamp - '1 month'::interval, "before_timestamp" timestamp default 'now'::timestamp, order_dir text default 'desc', "limit" int default 10)
returns setof log as $$
declare
  s text;
begin
  assert order_dir in ('asc', 'desc'), 'order_dir must be desc or asc not: ' || order_dir;
  assert "limit" < 1001, 'maximum limit is 1000 cannot limit by: ' || "limit";

  s := format('call contract_logs(%L, ''t'', %L, %L, %L, %s); select * from t order by evt_block_number desc, evt_index desc;', c.address, after_timestamp, before_timestamp, order_dir, "limit");
  raise notice '%', s;

  return query select * from eth.dblink('redshift', s) as (name text, payload json, transaction_hash text, log_index int, block_timestamp timestamp, block_number int);
end
$$
language plpgsql stable;

-- adds the condition argument to this connection, allowing to filter the set by any of its scalar fields https://www.graphile.org/postgraphile/smart-tags/#filterable
comment on function contract_logs is E'@filterable';


-- select contract_logs(c, 'now'::timestamp - '1 month'::interval, 'now'::timestamp, 'desc', 10) from contract c where c.address = '0x0aacfbec6a24756c20d41914f2caba817c0d8521';
-- select contract_logs(c) from contract c where c.address = '0x0aacfbec6a24756c20d41914f2caba817c0d8521';
-- select contract_logs(c) from contract c where c.address = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48';
-- select contract_logs(c, '2023-01-01', '2023-01-10', 'desc', 100) from contract c where c.address = '0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9';
