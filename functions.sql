-- library of functions to decode abi encoded data https://docs.soliditylang.org/en/develop/abi-spec.html

create or replace function can_convert_to_decimal (pos int, data text) returns bool immutable
as $$
--select to_int64(0, substring($2, $1+1, 32)) = 0
select length(ltrim(substring($2, $1+1, 32), '0')) = 0
$$ language sql;

create or replace function to_decimal (pos int, data text) returns decimal immutable
as $$
select case when can_convert_to_decimal($1, $2) then to_uint128($1, $2) else null end
$$ language sql;

-- drop function to_location (pos int, data text);
-- drop function to_size (pos int, data text);

create or replace function to_location (pos int, data text) returns int immutable
as $$
select to_uint32($1, $2)::int
$$ language sql;

create or replace function to_size (pos int, data text) returns int immutable
as $$
select to_uint32(to_location($1, $2)*2, $2)::int
$$ language sql;

create or replace function to_raw_bytes (pos int, data text)
  returns text
immutable
as $$
select substring($2, 1 + to_location($1, $2)*2 + 64, to_size($1, $2)*2)
$$ language sql;

create or replace function to_bytes (pos int, data text)
  returns text
immutable
as $$
select '0x' || to_raw_bytes($1, $2)
$$ language sql;

create or replace function to_fixed_bytes (pos int, data text, size int)
  returns text
immutable
as $$
select '0x' || rtrim(substring($2, $1+1, $3*2), '0')
$$ language sql;

create or replace function to_string (pos int, data text)
  returns text
immutable
as $$
select from_varbyte(from_hex(to_raw_bytes($1, $2)), 'utf8')
-- select convert_from(decode(to_raw_bytes($1, $2), 'hex'), 'utf8')
$$ language sql;

create or replace function to_address (pos int, data text)
  returns text
immutable
as $$
select '0x' || substring($2, $1+25, 40)
$$ language sql;

create or replace function to_bool (pos int, data text)
  returns bool
immutable
as $$
select to_uint32($1, $2)::int::bool
$$ language sql;

create or replace function to_element (pos int, data text, type text)
  returns text
immutable
as $$
select case
       when $3 = 'string' then quote_ident(to_string($1, $2))
       when $3 = 'bytes' then quote_ident(to_bytes($1, $2))
       when $3 = 'address' then quote_ident(to_address($1, $2))
       when $3 = 'int32' then to_int32($1, $2)::text
       when $3 = 'uint32' then to_int32($1, $2)::text
       when $3 = 'int64' then to_int64($1, $2)::text
       when $3 = 'uint64' then to_uint64($1, $2)::text
       when $3 = 'uint128' then to_uint128($1, $2)::text
       when $3 = 'decimal' then to_decimal($1, $2)::text
       when $3 = 'bool' then case when to_bool($1, $2) then 'true' else 'false' end
       else quote_ident(substring($2, $1+1, 64))
       end
$$ language sql;

create or replace function to_array (pos int, data text, type text)
  returns text
immutable
as $$
select case
       when to_size($1, $2) = 0 then '[]'
       when to_size($1, $2) = 1 then '[' || to_element($1+128, $2, $3) || ']'
       when to_size($1, $2) = 2 then '[' || to_element($1+128, $2, $3) || ',' || to_element($1+192, $2, $3) || ']'
       else '[' || to_element($1+128, $2, $3) || ',' || to_element($1+192, $2, $3) || ',' || to_element($1+256, $2, $3) || ']'
       end
$$ language sql;

create or replace function to_fixed_array (pos int, data text, type text, size int)
  returns text
immutable
as $$
select case
       when $4 = 0 then '[]'
       when $4 = 1 then '[' || to_element($1, $2, $3) || ']'
       when $4 = 2 then '[' || to_element($1, $2, $3) || ',' || to_element($1+64, $2, $3) || ']'
       else '[' || to_element($1, $2, $3) || ',' || to_element($1+64, $2, $3) || ',' || to_element($1+128, $2, $3) || ']'
       end
$$ language sql;