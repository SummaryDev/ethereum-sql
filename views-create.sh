#!/usr/bin/env bash

source postgres.env

env | grep ^PG

psql -t -f view-definitions-create-from-metadata.sql > views-create-out.sql

source test.env

env | grep ^PG

psql -t -f views-create-out.sql
