/*
library of functions to decode abi encoded data https://docs.soliditylang.org/en/develop/abi-spec.html
uses lower level functions created for redshift or another db
 */

-- set search_path to public;

-- create or replace function can_convert_to_decimal (pos, data) returns bool immutable
-- as 
-- --select to_int64(0, substring($2, $1+1, 32)) = 0
-- select length(ltrim(substring($2, $1+1, 32), '0')) = 0
-- ;
--
-- create or replace function to_decimal (pos, data) returns decimal immutable
-- as 
-- select case when can_convert_to_decimal($1, $2) then to_uint128($1, $2) else null end
-- ;

-- drop function to_location (pos, data);
-- drop function to_size (pos, data);

create or replace function to_location (pos, data)
as to_uint32(pos, data)::int;

create or replace function to_size (pos, data)
as to_uint32(to_location(pos, data)*2, data)::int;

create or replace function to_raw_bytes (pos, data)
as substring(data, 1 + to_location(pos, data)*2 + 64, to_size(pos, data)*2);

create or replace function to_bytes (pos, data)
as '0x' || to_raw_bytes(pos, data);

create or replace function to_fixed_bytes (pos, data, size)
as '0x' || rtrim(substring(data, pos+1, size*2), '0');

-- create or replace function to_string (pos, data)
-- as from_varbyte(from_hex(to_raw_bytes(pos, data)), 'utf8');
-- select convert_from(decode(to_raw_bytes(pos, data), 'hex'), 'utf8')

create or replace function to_address (pos, data)
as '0x' || substring(data, pos+25, 40);

create or replace function to_bool (pos, data)
as to_uint32(pos, data)::int::bool;

-- create or replace function to_element (pos, data, type)
-- as case
--        when type = 'string' then quote_ident(to_string(pos, data))
--        when type = 'bytes' then quote_ident(to_bytes(pos, data))
--        when type = 'address' then quote_ident(to_address(pos, data))
--        when type = 'int32' then to_int32(pos, data)::text
--        when type = 'uint32' then to_int32(pos, data)::text
--        when type = 'int64' then to_int64(pos, data)::text
--        when type = 'uint64' then to_uint64(pos, data)::text
--        when type = 'uint128' then to_uint128(pos, data)::text
--        when type = 'decimal' then to_decimal(pos, data)::text
--        when type = 'bool' then case when to_bool(pos, data) then 'true' else 'false' end
--        else quote_ident(substring(data, pos+1, 64))
-- end;

-- create or replace function to_array (pos, data, type)
-- as case
--        when to_size(pos, data) = 0 then '[]'
--        when to_size(pos, data) = 1 then '[' || to_element(pos+128, data, type) || ']'
--        when to_size(pos, data) = 2 then '[' || to_element(pos+128, data, type) || ',' || to_element(pos+192, data, type) || ']'
--        else '[' || to_element(pos+128, data, type) || ',' || to_element(pos+192, data, type) || ',' || to_element(pos+256, data, type) || ']'
-- end;
--
-- create or replace function to_fixed_array (pos, data, type, size)
-- as case
--        when size = 0 then '[]'
--        when size = 1 then '[' || to_element(pos, data, type) || ']'
--        when size = 2 then '[' || to_element(pos, data, type) || ',' || to_element(pos+64, data, type) || ']'
--        else '[' || to_element(pos, data, type) || ',' || to_element(pos+64, data, type) || ',' || to_element(pos+128, data, type) || ']'
-- end;