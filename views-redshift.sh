#!/usr/bin/env bash

env | grep ^PG

psql -c "drop schema if exists events cascade; create schema events;"

for i in 01 02 03 04 05 06 07 08 09 10 11 12
#for i in 01
do
echo "$i *******************************************************************"
psql -f metadata/parse-dune-contracts-$i-out-create-view.sql
done

