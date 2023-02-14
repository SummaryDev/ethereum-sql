# etl
Scripts to extract, transform and load blockchain metadata and
transactional data into Postgres and Redshift.

# Database schema

public schema

~~ethereum schema~~

functions
- to_address
- to_uint256

ethereum schema

tables for raw data in aws format
- blocks
- transactions
- logs
- traces 

~~ethereum_metadata schema~~ 

~~metadata schema~~ 

~~ethereum schema~~

tables
- label
- contract
- event
- abi

event schema

views
- Transfer_address_from_address_to_uint256_value_d
- Approval_address_owner_address_approved_uint256_tokenId

aave schema

views
- AAVEToken_evt_DelegatedPowerChanged
- AAVEToken_evt_SnapshotDone

uniswap_v2 schema

views
- Pair_evt_Transfer
- Pair_evt_Approval



ethereum-goerli
- blocks
- transactions
- logs
- traces 

ethereum-goerli-metadata
