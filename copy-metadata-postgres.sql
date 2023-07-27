set search_path to metadata;

truncate table label cascade;
truncate table abi cascade;
truncate table contract cascade;
truncate table event cascade;

\copy label from './metadata/parse-abi-label.csv' csv header;
\copy abi from './metadata/parse-abi-abi.csv' csv header;
\copy contract from './metadata/parse-abi-contract.csv' csv header;
\copy event from './metadata/parse-abi-event.csv' csv header;
