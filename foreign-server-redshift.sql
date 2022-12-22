-- https://github.com/hasura/hasura-oracle-fdw/blob/master/README-REDSHIFT.md
-- https://aws.amazon.com/blogs/big-data/join-amazon-redshift-and-amazon-rds-postgresql-with-dblink/

create extension if not exists postgres_fdw;
create extension if not exists dblink;

-- test-redshift-cluster-1.cujmiosxmo1p.eu-central-1.redshift.amazonaws.com
-- test-redshift-cluster-1.cujmiosxmo1p.eu-central-1.redshift.amazonaws.com

drop server if exists redshift cascade;

create server redshift
  foreign data wrapper postgres_fdw
options (host 'test-redshift-cluster-1.cujmiosxmo1p.eu-central-1.redshift.amazonaws.com', port '5439', dbname 'dev', sslmode 'require');

drop user mapping if exists for postgres server redshift;
create user mapping for postgres server redshift options ( user 'awsuser', password '');

drop server if exists redshift cascade;

create server redshift
  foreign data wrapper postgres_fdw
options (host 'redshift-cluster-1.cujmiosxmo1p.eu-central-1.redshift.amazonaws.com', port '5439', dbname 'dev', sslmode 'require');

drop user mapping if exists for postgres server redshift;
create user mapping for postgres server redshift options ( user 'awsuser', password '');

-- test it
-- select * from dblink('redshift', $redshift$
-- select topics, data from eth.logs limit 10;
-- $redshift$) as logs(topics json, data text);
