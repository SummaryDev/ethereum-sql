select 'create schema if not exists events;';

select concat('create or replace view events.', translate(a.signature, '[,]', '_'), ' as select address, transaction_hash, block_timestamp, date, ', a.unpack, ' from eth.logs where topics[0] = ', quote_literal(a.hash), ';') from eth.abi a;

select concat('create schema if not exists ', name, ';') from eth.app;

select concat('create or replace view ', c.app_name, '.', c.name, '_evt_', a.name, ' as select * from events.', a.signature, ' where address in (', string_agg(quote_literal(c.address), ','), ');') from eth.abi a left join eth.event e on a.signature = e.abi_signature left join eth.contract c on c.address = e.contract_address group by c.app_name, c.name, a.name, a.signature;