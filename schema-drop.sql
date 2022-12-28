set search_path to public;

drop table abi cascade;
drop table app cascade;
drop table contract cascade;
drop table contracts cascade;
drop table event cascade;
drop table token_transfers cascade;
drop table tokens cascade;
drop table traces cascade;
drop table transactions cascade;
drop table blocks cascade;
drop table logs_a cascade;
drop table logs_bak cascade;

drop function erc20_transfer();
drop function erc20_transfer_refresh_status();
drop function erc20_transfer_summary();

set search_path to eth;

drop materialized view erc20_transfer;
drop materialized view erc20_transfer_dai;
drop materialized view erc20_transfer_link;
drop materialized view erc20_transfer_usdc;
drop materialized view erc20_transfer_usdt;
drop materialized view erc20_transfer_weth;