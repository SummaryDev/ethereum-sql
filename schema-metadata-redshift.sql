create schema if not exists eth;
set search_path to eth;

-- drop table if exists app cascade;
-- drop table if exists namespace cascade;
drop table if exists project cascade;
drop table if exists label cascade;

create table label (name text primary key);

drop table if exists contract cascade;

create table contract (address varchar(42) primary key, name text, label text references label);

drop table if exists abi cascade;

create table abi (signature varchar(512) primary key, name text not null, hash text not null, unpack varchar(1024) not null, json varchar(1024) not null, canonical text not null, table_name text not null);

drop table if exists event cascade;

create table event (contract_address varchar(42) references contract, abi_signature varchar(512) references abi, primary key (contract_address, abi_signature));
