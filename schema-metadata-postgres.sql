-- this schema metadata is for labels, contracts, event definitions and their abis
-- schema event is for decoded events like event.Transfer
-- schema data is for raw undecoded records received from an rpc node like logs, transactions, blocks, traces
-- other schemas will be created as namespaces to hold views per contract like erc20, aave, beamswap

drop schema if exists metadata cascade;
create schema metadata;
set search_path to metadata;

create table label (name text primary key);

create table contract (address text primary key, name text, label text references label);
create index on contract (label);
create index on contract (name);

create table abi (signature text primary key, name text not null, hash text not null, unpack text not null, json text not null, canonical text not null, table_name text not null);
create index on abi (hash);
create index on abi (name);
create index on abi (canonical);

create table event (contract_address text references contract, abi_signature text references abi, primary key (contract_address, abi_signature));
create index on event (contract_address);
create index on event (abi_signature);

-- needed for graphile
-- comment on table label is E'@listSuffix omit';
-- comment on table contract is E'@listSuffix omit';
-- comment on table abi is E'@listSuffix omit';
-- comment on table event is E'@listSuffix omit';
comment on constraint contract_label_fkey on contract is E'@fieldName app\n@foreignFieldName contracts';
comment on constraint event_abi_signature_fkey on event is E'@fieldName abi\n@foreignFieldName events';
comment on constraint event_contract_address_fkey on event is E'@fieldName contract\n@foreignFieldName events';
-- comment on constraint contract_label_fkey on contract is null;
-- comment on constraint event_abi_signature_fkey on event is null;
-- comment on constraint event_contract_address_fkey on event is null;
