set search_path to metadata;

truncate table label;
truncate table abi;
truncate table contract;
truncate table event;

copy label from 's3://summary.dev/metadata/parse-contracts-dune-label.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-contracts-dune-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-contracts-dune-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-contracts-dune-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;

-- select * from abi limit 10;
