-- https://github.com/hasura/hasura-oracle-fdw/blob/master/README-REDSHIFT.md
-- https://aws.amazon.com/blogs/big-data/join-amazon-redshift-and-amazon-rds-postgresql-with-dblink/

create extension postgres_fdw;
create extension dblink;


-- test_redshift_cluster_1
drop server if exists test_redshift_cluster_1_foreign_server cascade;

create server test_redshift_cluster_1_foreign_server
  foreign data wrapper postgres_fdw
options (host 'test-redshift-cluster-1.cujmiosxmo1p.eu-central-1.redshift.amazonaws.com', port '5439', dbname 'dev', sslmode 'require');

drop user mapping if exists for postgres server test_redshift_cluster_1_foreign_server;
create user mapping for postgres server test_redshift_cluster_1_foreign_server options ( user 'awsuser', password '');

drop user mapping if exists for hasura server test_redshift_cluster_1_foreign_server;
create user mapping for hasura server test_redshift_cluster_1_foreign_server options ( user 'awsuser', password '');
grant usage on foreign server test_redshift_cluster_1_foreign_server to hasura;

-- test it
select * from dblink('test_redshift_cluster_1_foreign_server', $redshift$
select topics, data from logs limit 10;
$redshift$) as logs(topics json, data text);


-- redshift_cluster_1
drop server if exists redshift_cluster_1_foreign_server cascade;

create server redshift_cluster_1_foreign_server
  foreign data wrapper postgres_fdw
options (host 'redshift-cluster-1.cujmiosxmo1p.eu-central-1.redshift.amazonaws.com', port '5439', dbname 'dev', sslmode 'require');

drop user mapping if exists for postgres server redshift_cluster_1_foreign_server;
create user mapping for postgres server redshift_cluster_1_foreign_server options ( user 'awsuser', password '');

drop user mapping if exists for hasura server redshift_cluster_1_foreign_server;
create user mapping for hasura server redshift_cluster_1_foreign_server options ( user 'awsuser', password '');
grant usage on foreign server redshift_cluster_1_foreign_server to hasura;

-- test it
select * from dblink('redshift_cluster_1_foreign_server', $redshift$
select topics, data from eth.logs limit 10;
$redshift$) as logs(topics json, data text);

--grant select on usdt_transfer to hasura;





