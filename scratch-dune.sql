select table_schema, table_name, column_name, ordinal_position, data_type from information_schema.columns 
where table_schema <> '__backup_dune_user_generated' 
and column_name not in ('output_0', 'contract_address', 'call_success', 'call_tx_hash', 'call_trace_address', 'call_block_time', 'call_block_number',
'evt_tx_hash', 'evt_index', 'evt_block_time', 'evt_block_number')
order by 1, 2, 4 limit 100;

select * from ethereum.signatures;

-- cat parse-dune-signatures-out.json | jq -r '.data.get_execution.execution_succeeded.data[] | [.id, .signature, .abi] | @csv' > parse-dune-signatures-out.csv

select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 50000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 100000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 150000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 200000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 250000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 300000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 350000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 400000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 450000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 500000;
select namespace, name, address, base, dynamic, id, factory, abi from ethereum.contracts order by namespace, name limit 50000 offset 550000;

-- 583283 rows in ethereum.contracts
select count(distinct id) from ethereum.contracts; -- 583304 distinct ids

cat parse-dune-contracts-out.json | jq --raw-output '.data.get_execution.execution_succeeded.data[] | [.namespace, .name, .address, .base, .dynamic, .id, .factory, (.abi | @text)] | @csv' > parse-dune-contracts-out.csv

