#!/usr/bin/env bash

mkdir -p data/aws-public-blockchain

# 2020-01-01
d=$1
# 2021-01-01
until=$2
# topic0,address,date
partition=$3

echo "from $d until $until partitioned by $partition"

tmp=./tmp

mkdir -p $tmp

while [ "$d" != $until ]; do

    #  bucket=s3://aws-public-blockchain/v1.0/eth/logs/date=$d/
#    src=s3://aws-public-blockchain/v1.0/eth/logs/date=$d/
    src=./data/aws-public-blockchain/date=$d
    dest=./data/partition/$(echo $partition | sed 's/,/-/g')

    echo src=$src
    echo dest=$dest

    mkdir -p $dest

# pragma memory_limit='2GB';

    ./duckdb -c "pragma temp_directory='$tmp'; copy (select address, topics[1] topic0, topics[2] topic1, topics[3] topic2, topics[4] topic3, data, date from
'$src/*.parquet' where topic0 is not null) to '$dest' (format parquet, partition_by ($partition), allow_overwrite)"


    d=$(date -I -d "$d + 1 day")

    # mac option for d decl (the +1d is equivalent to + 1 day)
    # d=$(date -j -v +1d -f "%Y-%m-%d" $d +%Y-%m-%d)

done
