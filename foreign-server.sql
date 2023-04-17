set search_path to ethereum;

-- https://github.com/hasura/hasura-oracle-fdw/blob/master/README-REDSHIFT.md
-- https://aws.amazon.com/blogs/big-data/join-amazon-redshift-and-amazon-rds-postgresql-with-dblink/

drop extension postgres_fdw cascade;
drop extension dblink cascade;

create extension if not exists postgres_fdw;
create extension if not exists dblink;

-- test-redshift-cluster-1.cujmiosxmo1p.eu-central-1.redshift.amazonaws.com
-- awsuser
-- 5439

drop server if exists redshift cascade;

create server redshift foreign data wrapper postgres_fdw options (host '$PGHOST', port '$PGPORT', dbname 'dev', sslmode 'require');

drop user mapping if exists for graphile server redshift;
create user mapping for graphile server redshift options (user '$PGUSER', password '$PGPASSWORD');

grant usage on foreign server redshift to graphile;

-- test it
-- select * from dblink('redshift', $redshift$
-- select topics, data from ethereum.logs limit 10;
-- $redshift$) as logs(topics json, data text);
