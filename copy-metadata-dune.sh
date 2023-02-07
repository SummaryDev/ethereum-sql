#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
#    read -n1 -r -p "Press any key to continue" key
#    echo
}


info "generate metadata"

node parse-contracts-dune.js

info "copy csv to postgres"

source ./postgres.env

env | grep ^PG

psql -f ./copy-metadata-dune-postgres.sql

info "copy csv to s3 for redshift"

aws s3 cp metadata s3://summary.dev/metadata --exclude "*" --include "*01*.csv" --recursive

info "copy csv to redshift"

source .env

env | grep ^PG

psql -f ./copy-metadata-dune-redshift.sql

info "drop events schema in redshift"

psql -c 'drop schema events cascade'

#for i in 01 02 03 04 05 06 07 08 09 10 11 12
for i in 01
do
info "drop schemas in redshift ${i}"
psql -f metadata/parse-dune-contracts-${i}-out-drop-app-schema.sql
done

#for i in 01 02 03 04 05 06 07 08 09 10 11 12
for i in 01
do
info "create views in redshift ${i}"
psql -f metadata/parse-dune-contracts-${i}-out-create-app-schema.sql -f metadata/parse-dune-contracts-${i}-out-create-event-view.sql -f metadata/parse-dune-contracts-${i}-out-create-contract-view.sql
done





