set search_path to ethereum;

truncate table label cascade;
truncate table abi cascade;
truncate table contract cascade;
truncate table event cascade;

\copy label from './metadata/parse-contracts-dune-label.csv' csv header;
\copy abi from './metadata/parse-contracts-dune-abi.csv' csv header;
\copy contract from './metadata/parse-contracts-dune-contract.csv' csv header;
\copy event from './metadata/parse-contracts-dune-event.csv' csv header;
