#!/usr/bin/env bash

source postgres.env

env | grep ^PG

psql -t -f view-definitions-drop-from-metadata.sql > views-drop-out.sql

source test.env

env | grep ^PG

psql -t -f views-drop-out.sql
