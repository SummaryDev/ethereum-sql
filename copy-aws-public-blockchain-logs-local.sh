#!/usr/bin/env bash

mkdir -p data/aws-public-blockchain

# 2020-01-01
d=$1
# 2021-01-01
until=$2

echo from $d until $until

while [ "$d" != $until ]; do

    #  bucket=s3://aws-public-blockchain/v1.0/eth/logs/date=$d/
    src=s3://aws-public-blockchain/v1.0/eth/logs/date=$d/
    dest=./data/aws-public-blockchain/date=$d/

    echo src=$src
    echo dest=$dest

    #  aws s3 sync --no-sign-request --dryrun $src $dest
    aws s3 sync --no-sign-request $src $dest

    d=$(date -I -d "$d + 1 day")

    # mac option for d decl (the +1d is equivalent to + 1 day)
    # d=$(date -j -v +1d -f "%Y-%m-%d" $d +%Y-%m-%d)

done
