
create schema if not exists metadata;
set search_path to metadata;

drop table if exists label cascade;
create table label (name text primary key);

drop table if exists contract cascade;
create table contract (address text primary key, name text, label text references label);
create index on contract (label);
create index on contract (name);

drop table if exists abi cascade;
create table abi (signature text primary key, name text not null, hash text not null, unpack text not null, json text not null, canonical text not null, table_name text not null);
create index on abi (hash);
create index on abi (name);
create index on abi (canonical);

drop table if exists event cascade;
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
