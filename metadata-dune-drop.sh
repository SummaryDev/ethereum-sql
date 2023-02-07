#!/usr/bin/env bash

env | grep ^PG

for t in 'drop-app-schema'
do
    echo "$t *******************************************************************"

    for i in 01 02 03 04 05 06 07 08 09 10 11 12
    do
        psql -f "metadata/parse-dune-contracts-${i}-out-${t}.sql"
    done
done