#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
#    read -n1 -r -p "Press any key to continue" key
#    echo
}


info "generate metadata"

node parse-contracts-dune.js

info "create metadata schema in postgres"

source ./postgres.env
env | grep ^PG

psql -f ./schema-metadata-postgres.sql

info "copy csv to postgres"

psql -f ./copy-metadata-dune-postgres.sql

info "create foreign server dblink from postgres to redshift"

source redshift.env && envsubst < ./foreign-server.sql > ./foreign-server-out.sql && source ./postgres.env

psql -f foreign-server-out.sql

info "create procedures in postgres"

psql -f procedures-postgres.sql

info "copy csv to s3 for redshift"

aws s3 cp metadata s3://summary.dev/metadata --exclude "*" --include "*.csv" --recursive

info "create metadata schema in redshift"

source redshift.env
env | grep ^PG

psql -f ./schema-metadata-redshift.sql

info "copy csv to redshift"

psql -f ./copy-metadata-dune-redshift.sql

info "drop label schemas in redshift"

psql -f metadata/parse-contracts-dune-drop-label-schema.sql

info "drop event schema in redshift"

psql -c 'drop schema event cascade'

info "create schemas in redshift"
psql -f metadata/parse-contracts-dune-create-label-schema.sql

info "create event views in redshift"
psql -f metadata/parse-contracts-dune-create-event-view.sql

info "create contract views in redshift"
psql -f metadata/parse-contracts-dune-create-contract-view.sql

info "create procedures in redshift"

psql -f procedures-redshift.sql