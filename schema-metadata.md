# Database schema

public schema

functions
- to_address
- to_uint256

data schema

tables for raw data in aws format
- blocks
- transactions
- logs
- traces 

metadata schema

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

ethereum schema

tables for raw data in dune format
- blocks
- transactions
- logs
- traces
