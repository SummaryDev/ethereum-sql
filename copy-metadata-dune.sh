#!/usr/bin/env bash

env | grep ^PG

for t in app abi contract event
do
    echo "$t *******************************************************************"

    c="begin; truncate table eth.$t cascade; create temp table t (like eth.$t) on commit drop;"

    for i in 01 02 03 04 05 06 07 08 09 10 11 12
    do
        c="$c\copy t from './metadata/parse-dune-contracts-$i-out-$t.csv' csv header;"
    done

    c="$c insert into eth.$t select * from t on conflict do nothing"

    echo $c
done