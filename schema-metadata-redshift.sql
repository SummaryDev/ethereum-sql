drop schema if exists metadata cascade;
create schema metadata;

set search_path to metadata;

create table label (name text primary key);

create table contract (address varchar(42) primary key, name text, label text references label);

create table abi (signature varchar(512) primary key, name text not null, hash text not null, unpack varchar(1024) not null, json varchar(1024) not null, canonical text not null, table_name text not null);

create table event (contract_address varchar(42) references contract, abi_signature varchar(512) references abi, primary key (contract_address, abi_signature));
