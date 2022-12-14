
create schema eth;

set search_path to eth;

drop table if exists logs;

CREATE TABLE logs (
  address           VARCHAR(42)     NOT NULL, -- Address from which this log originated
  topics            super, -- Indexed log arguments (0 to 4 32-byte hex strings). (In solidity: The first topic is the hash of the signature of the event (e.g. Deposit(address,bytes32,uint256))
  data              varbinary(512000)  NOT NULL, -- Contains one or more 32 Bytes non-indexed arguments of the log
  transaction_index BIGINT          NOT NULL, -- Integer of the transactions index position log was created from
  log_index         BIGINT          NOT NULL, -- Integer of the log index position in the block
  transaction_hash  VARCHAR(66)     NOT NULL, -- Hash of the transactions this log was created from
  block_number      BIGINT          NOT NULL, -- The block number where this log was in,
  block_hash        VARCHAR(66)     NOT NULL, -- Hash of the block where this log was in except you declared the event with the anonymous specifier,
  block_timestamp   timestamp          NOT NULL,
  date              varchar(10)     NOT NULL,
  last_modified     timestamp          NOT NULL,
  PRIMARY KEY (transaction_hash, log_index)
)
  DISTKEY (block_number)
  SORTKEY AUTO;

COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-01/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-02/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-03/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-04/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-05/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-06/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-07/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-08/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-09/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-10/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-11/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-12/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-13/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-14/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-15/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-16/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-17/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-18/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-19/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-20/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-21/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-22/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-23/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-24/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-25/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-26/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-27/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-28/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-29/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-30/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.public.logs FROM 's3://aws-public-blockchain-copy/logs/date=2020-01-31/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
