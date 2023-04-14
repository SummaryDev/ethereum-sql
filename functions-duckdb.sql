/*
creates functions based on duckdb functions
 */

-- set search_path to public;

create or replace function strtol (hex)
as concat('0x', hex)::ubigint; --todo bigint for jdbc ubigint otherwise

create or replace function to_part (pos, data, pos_part, bits)
as substring(data, pos + 65 - (pos_part + 1) * (bits/8)*2, (bits/8)*2);

create or replace function to_positive (pos, data, pos_part, bits)
as strtol(to_part(pos, data, pos_part, bits));

create or replace function to_uint8 (pos, data)
as to_positive(pos, data, 0, 8);

create or replace function to_uint16 (pos, data)
as to_positive(pos, data, 0, 16);

create or replace function to_uint32 (pos, data)
as to_positive(pos, data, 0, 32);

create or replace function to_uint64 (pos, data)
as to_positive(pos, data, 0, 64);

create or replace function to_uint128 (pos, data)
as to_positive(pos, data, 3, 32)::hugeint*4294967296*4294967296*4294967296
+ to_positive(pos, data, 2, 32)::hugeint*4294967296*4294967296
+ to_positive(pos, data, 1, 32)::hugeint*4294967296
+ to_positive(pos, data, 0, 32)::hugeint;

-- for jdbc driver as it doesn't understand hugeint
-- create or replace function to_uint128 (pos, data)
-- as to_positive(pos, data, 3, 32)::ubigint*4294967296*4294967296*4294967296
--   + to_positive(pos, data, 2, 32)::ubigint*4294967296*4294967296
--   + to_positive(pos, data, 1, 32)::ubigint*4294967296
--   + to_positive(pos, data, 0, 32)::ubigint;

-- create or replace function to_binary (pos, data, pos_part int, bits int) returns varbyte immutable
-- as
-- select from_hex(to_part(pos, data, $3, $4))
-- ;
--
-- create or replace function is_positive (pos, data, pos_part int, bits int) returns bool immutable
-- as
-- select getbit(to_binary($1, $2, $3, $4), $4 - 1) = 0
-- ;
--
-- create or replace function to_negative (pos, data, pos_part int, bits int)
-- as
-- select ~strtol(to_hex(~to_binary($1, $2, $3, $4)), 16)
-- ;
--
-- create or replace function to_int32 (pos, data)
-- as
-- select case when is_positive($1, $2, 0, 32) then to_positive($1, $2, 0, 32) else to_negative($1, $2, 0, 32) end;
-- ;
--
-- create or replace function to_int64 (pos, data)
-- as
-- select case when is_positive($1, $2, 0, 64) then to_positive($1, $2, 0, 64) else to_negative($1, $2, 0, 64) end;
-- ;



-- create or replace function to_uint32_array (pos, data)
-- as
-- array(to_positive($1, $2, 7, 32),
--              to_positive($1, $2, 6, 32),
--              to_positive($1, $2, 5, 32),
--              to_positive($1, $2, 4, 32),
--              to_positive($1, $2, 3, 32),
--              to_positive($1, $2, 2, 32),
--              to_positive($1, $2, 1, 32),
--              to_positive($1, $2, 0, 32))
-- ;


create or replace function to_uint64_array (pos, data)
as list_value((to_positive(pos, data, 7, 32)::ubigint*4294967296 + to_positive(pos, data, 6, 32))::ubigint,
(to_positive(pos, data, 5, 32)::ubigint*4294967296 + to_positive(pos, data, 4, 32))::ubigint,
(to_positive(pos, data, 3, 32)::ubigint*4294967296 + to_positive(pos, data, 2, 32))::ubigint,
(to_positive(pos, data, 1, 32)::ubigint*4294967296 + to_positive(pos, data, 0, 32))::ubigint);

create or replace function to_uint64_array (pos, data)
as list_value((to_positive(pos, data, 7, 32)::hugeint*4294967296 + to_positive(pos, data, 6, 32))::hugeint,
(to_positive(pos, data, 5, 32)::hugeint*4294967296 + to_positive(pos, data, 4, 32))::hugeint,
(to_positive(pos, data, 3, 32)::hugeint*4294967296 + to_positive(pos, data, 2, 32))::hugeint,
(to_positive(pos, data, 1, 32)::hugeint*4294967296 + to_positive(pos, data, 0, 32))::hugeint);


create or replace function to_uint128_array (pos, data)
as list_value(to_positive(pos, data, 7, 32)::hugeint*4294967296*4294967296*4294967296 + to_positive(pos, data, 6, 32)::hugeint*4294967296*4294967296 + to_positive(pos, data, 5, 32)::hugeint*4294967296 + to_positive(pos, data, 4, 32),
              to_positive(pos, data, 3, 32)::hugeint*4294967296*4294967296*4294967296 + to_positive(pos, data, 2, 32)::hugeint*4294967296*4294967296 + to_positive(pos, data, 1, 32)::hugeint*4294967296 + to_positive(pos, data, 0, 32));



create or replace function has_part (pos, data, pos_part, bits)
as length(ltrim(to_part(pos, data, pos_part, bits), '0')) > 0;

/*create or replace function can_overflow (pos, data) returns bool immutable
as
select case
       when has_part($1, $2, 3, 32) then
         to_positive($1, $2, 3, 32) > 1262177448 or log(to_positive($1, $2, 3, 32)::dec*4294967296*4294967296*4294967296::float) + to_positive($1, $2, 2, 32)::dec*4294967296*4294967296 / (to_positive($1, $2, 3, 32)::dec*4294967296*4294967296*4294967296) > 38
       when has_part($1, $2, 7, 32) then
         to_positive($1, $2, 7, 32) > 1262177448 or log(to_positive($1, $2, 7, 32)::dec*4294967296*4294967296*4294967296::float) + to_positive($1, $2, 6, 32)::dec*4294967296*4294967296 / (to_positive($1, $2, 7, 32)::dec*4294967296*4294967296*4294967296) > 38
       else false end;
;*/

-- create or replace function can_overflow (pos, data) as case when ((has_part(pos, data, 7, 32) and (to_positive(pos, data, 7, 32) > 1262177448 or ceiling(log(to_positive(pos, data, 7, 32)::dec*4294967296*4294967296*4294967296::float)) >= 38)) or (has_part(pos, data, 3, 32) and (to_positive(pos, data, 3, 32) > 1262177448 or ceiling(log(to_positive(pos, data, 3, 32)::dec*4294967296*4294967296*4294967296::float)) >= 38))) then true else false end;

-- create or replace function can_overflow (pos, data) as (
-- (has_part(pos, data, 7, 32) and (to_positive(pos, data, 7, 32) > 1262177448 or ceiling(log(to_positive(pos, data, 7, 32)::dec*4294967296*4294967296*4294967296::float)) >= 38))
-- or
-- (has_part(pos, data, 3, 32) and (to_positive(pos, data, 3, 32) > 1262177448 or ceiling(log(to_positive(pos, data, 3, 32)::dec*4294967296*4294967296*4294967296::float)) >= 38))
-- );
--
--
-- create or replace function to_uint128_array_or_null (pos, data) as case when can_overflow(pos, data) then null else to_uint128_array(pos, data) end;
--
-- create or replace function to_decimal (pos, data) as case when can_overflow(pos, data) then null else to_uint128(pos, data) end;
--
-- create or replace function to_uint256 (pos, data) as to_uint128_array_or_null(pos, data);

create or replace function to_decimal (pos, data) as to_uint128(pos, data);

-- create or replace function to_uint256 (pos, data) as to_uint128_array(pos, data);
create or replace function to_uint256 (pos, data) as to_uint64_array(pos, data);
