#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
#    read -n1 -r -p "Press any key to continue" key
    echo
}

# export namespace=prod && export evm_chain=moonbeam && export evm_network=mainnet


info "generate metadata"

node parse-abi-files.js

source ./postgres.env
env | grep ^PG

info "create metadata schema in postgres"
psql -f ./schema-metadata-postgres.sql

info "copy csv to postgres"
psql -f ./copy-metadata-postgres.sql

info "create schemas"
psql -f metadata/parse-abi-create-label-schema.sql

info "create low level functions in postgres"
psql -f ./functions-postgres.sql

info "create high level functions in postgres"
psql -f ./functions.sql

info "create event views"
psql -f metadata/parse-abi-create-event-view.sql

info "create contract views"
psql -f metadata/parse-abi-create-contract-view.sql

#info "create procedures"
#
#psql -f procedures-redshift.sql