set search_path to eth;

truncate table app;
truncate table abi;
truncate table contract;
truncate table event;

copy app from 's3://summary.dev/metadata/parse-dune-contracts-01-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-01-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-01-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-01-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;

copy app from 's3://summary.dev/metadata/parse-dune-contracts-02-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-02-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-02-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-02-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
--
copy app from 's3://summary.dev/metadata/parse-dune-contracts-03-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-03-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-03-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-03-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
--
copy app from 's3://summary.dev/metadata/parse-dune-contracts-04-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-04-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-04-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-04-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
--
copy app from 's3://summary.dev/metadata/parse-dune-contracts-05-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-05-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-05-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-05-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
--
copy app from 's3://summary.dev/metadata/parse-dune-contracts-06-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-06-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-06-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-06-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
--
copy app from 's3://summary.dev/metadata/parse-dune-contracts-07-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-07-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-07-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-07-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
--
copy app from 's3://summary.dev/metadata/parse-dune-contracts-08-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-08-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-08-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-08-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
--
copy app from 's3://summary.dev/metadata/parse-dune-contracts-09-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-09-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-09-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-09-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
--
copy app from 's3://summary.dev/metadata/parse-dune-contracts-10-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-10-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-10-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-10-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
--
copy app from 's3://summary.dev/metadata/parse-dune-contracts-11-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-11-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-11-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-11-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
--
copy app from 's3://summary.dev/metadata/parse-dune-contracts-12-out-app.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy abi from 's3://summary.dev/metadata/parse-dune-contracts-12-out-abi.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy contract from 's3://summary.dev/metadata/parse-dune-contracts-12-out-contract.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;
copy event from 's3://summary.dev/metadata/parse-dune-contracts-12-out-event.csv' iam_role 'arn:aws:iam::729713441316:role/RedshiftRole' format csv ignoreheader 1;

-- select * from abi limit 10;
