select 'drop schema if exists events cascade;';

select concat('drop schema if exists ', name, ' cascade;') from eth.app;