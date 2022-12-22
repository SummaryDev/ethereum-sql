#!/usr/bin/env bash

# 2020-01-01
d=$1
# 2021-01-01
until=$2

while [ "$d" != $until ]; do

  aws s3 sync s3://aws-public-blockchain/v1.0/eth/logs/date=$d/ s3://aws-public-blockchain-copy/logs/date=$d/

  #  aws redshift-data execute-statement --cluster-identifier redshift-cluster-1 --database dev --db-user awsuser --sql \
  psql -c \
  "COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=$d/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON"

  d=$(date -I -d "$d + 1 day")

  # mac option for d decl (the +1d is equivalent to + 1 day)
  # d=$(date -j -v +1d -f "%Y-%m-%d" $d +%Y-%m-%d)
done
