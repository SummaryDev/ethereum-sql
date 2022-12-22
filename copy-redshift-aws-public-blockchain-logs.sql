
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

COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-01/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-02/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-03/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-04/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-05/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-06/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-07/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-08/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-09/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-10/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-11/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-12/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-13/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-14/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-15/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-16/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-17/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-18/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-19/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-20/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-21/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-22/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-23/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-24/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-25/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-26/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-27/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-28/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-29/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-30/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-31/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-01/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-02/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-03/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-04/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-05/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-06/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-07/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-08/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-09/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-10/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-11/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-12/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-13/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-14/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-15/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-16/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-17/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-18/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-19/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-20/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-21/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-22/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-23/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-24/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-25/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-26/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-27/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-28/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-29/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-30/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-11-31/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;

COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-01/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-02/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-03/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-04/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;

COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-07/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-08/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-09/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-10/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-11/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-12/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-13/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-14/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-15/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-16/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-17/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;
COPY dev.eth.logs FROM 's3://aws-public-blockchain-copy/logs/date=2022-12-18/' IAM_ROLE 'arn:aws:iam::729713441316:role/service-role/AmazonRedshift-CommandsAccessRole-20221031T131305' FORMAT AS PARQUET SERIALIZETOJSON;

select current_time, * from SVL_MV_REFRESH_STATUS where schema_name = 'eth' order by starttime desc;

select transaction_hash, block_timestamp from eth.logs where topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' and topics[1] is not null and topics[2] is not null and address = '0xdac17f958d2ee523a2206206994597c13d831ec7' order by block_timestamp desc limit '100';

