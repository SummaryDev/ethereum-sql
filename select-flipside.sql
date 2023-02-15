-- https://docs.flipsidecrypto.com/our-data/address-tags-and-labels/labels

select address, address_name, label_type, label_subtype, label
from ethereum.core.dim_labels
where blockchain = 'ethereum'
limit 100000 offset 100000;

select DISTINCT address_name
from ethereum.core.dim_labels
where blockchain = 'ethereum'
limit 20;

select count(1)
from ethereum.core.dim_labels
where blockchain = 'ethereum'
and address_name is not null
limit 20;

select count(1)
from ethereum.core.dim_nft_metadata
where blockchain = 'ethereum'
and contract_name is not null;

select count(1) from ethereum.core.dim_contracts;

select * from ethereum.core.dim_contracts where decimals is null LIMIT 10;