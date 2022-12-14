/*
creates functions based on redshift built it functions (and the lack of many)
 */

create or replace function to_part (pos int, data text, pos_part int, bits int) returns text immutable
as $$
select substring($2, $1 + 65 - ($3 + 1) * ($4/8)*2, ($4/8)*2)
$$ language sql;

create or replace function to_positive (pos int, data text, pos_part int, bits int) returns bigint immutable
as $$
select strtol(to_part($1, $2, $3, $4), 16)
$$ language sql;

create or replace function to_uint32 (pos int, data text) returns bigint immutable
as $$
select to_positive($1, $2, 0, 32)
$$ language sql;

create or replace function to_uint64 (pos int, data text) returns bigint immutable
as $$
select to_positive($1, $2, 0, 64)
$$ language sql;

create or replace function to_binary (pos int, data text, pos_part int, bits int) returns varbyte immutable
as $$
select from_hex(to_part($1, $2, $3, $4))
$$ language sql;

create or replace function is_positive (pos int, data text, pos_part int, bits int) returns bool immutable
as $$
select getbit(to_binary($1, $2, $3, $4), $4 - 1) = 0
$$ language sql;

create or replace function to_negative (pos int, data text, pos_part int, bits int) returns bigint immutable
as $$
select ~strtol(to_hex(~to_binary($1, $2, $3, $4)), 16)
$$ language sql;

create or replace function to_int32 (pos int, data text) returns bigint immutable
as $$
select case when is_positive($1, $2, 0, 32) then to_positive($1, $2, 0, 32) else to_negative($1, $2, 0, 32) end;
$$ language sql;

create or replace function to_int64 (pos int, data text) returns bigint immutable
as $$
select case when is_positive($1, $2, 0, 64) then to_positive($1, $2, 0, 64) else to_negative($1, $2, 0, 64) end;
$$ language sql;

create or replace function to_uint128 (pos int, data text) returns dec immutable
as $$
select to_positive($1, $2, 3, 32)::dec*4294967296*4294967296*4294967296 + to_positive($1, $2, 2, 32)::dec*4294967296*4294967296 + to_positive($1, $2, 1, 32)::dec*4294967296 + to_positive($1, $2, 0, 32)::dec
$$ language sql;

create or replace function to_uint32_array (pos int, data text) returns super immutable
as $$
select array(to_positive($1, $2, 7, 32),
             to_positive($1, $2, 6, 32),
             to_positive($1, $2, 5, 32),
             to_positive($1, $2, 4, 32),
             to_positive($1, $2, 3, 32),
             to_positive($1, $2, 2, 32),
             to_positive($1, $2, 1, 32),
             to_positive($1, $2, 0, 32))
$$ language sql;

create or replace function to_uint64_array (pos int, data text) returns super immutable
as $$
select array(to_positive($1, $2, 7, 32)::dec*4294967296 + to_positive($1, $2, 6, 32),
             to_positive($1, $2, 5, 32)::dec*4294967296 + to_positive($1, $2, 4, 32),
             to_positive($1, $2, 3, 32)::dec*4294967296 + to_positive($1, $2, 2, 32),
             to_positive($1, $2, 1, 32)::dec*4294967296 + to_positive($1, $2, 0, 32))
$$ language sql;

create or replace function to_uint128_array (pos int, data text) returns super immutable
as $$
select array(to_positive($1, $2, 7, 32)::dec*4294967296*4294967296*4294967296 + to_positive($1, $2, 6, 32)::dec*4294967296*4294967296 + to_positive($1, $2, 5, 32)::dec*4294967296 + to_positive($1, $2, 4, 32),
             to_positive($1, $2, 3, 32)::dec*4294967296*4294967296*4294967296 + to_positive($1, $2, 2, 32)::dec*4294967296*4294967296 + to_positive($1, $2, 1, 32)::dec*4294967296 + to_positive($1, $2, 0, 32))
$$ language sql;

create or replace function has_part (pos int, data text, pos_part int, bits int) returns bool immutable
as $$
select length(ltrim(to_part($1, $2, $3, $4), '0')) > 0
$$ language sql;

/*create or replace function can_overflow (pos int, data text) returns bool immutable
as $$
select case
       when has_part($1, $2, 3, 32) then
         to_positive($1, $2, 3, 32) > 1262177448 or log(to_positive($1, $2, 3, 32)::dec*4294967296*4294967296*4294967296::float) + to_positive($1, $2, 2, 32)::dec*4294967296*4294967296 / (to_positive($1, $2, 3, 32)::dec*4294967296*4294967296*4294967296) > 38
       when has_part($1, $2, 7, 32) then
         to_positive($1, $2, 7, 32) > 1262177448 or log(to_positive($1, $2, 7, 32)::dec*4294967296*4294967296*4294967296::float) + to_positive($1, $2, 6, 32)::dec*4294967296*4294967296 / (to_positive($1, $2, 7, 32)::dec*4294967296*4294967296*4294967296) > 38
       else false end;
$$ language sql;*/

create or replace function can_overflow (pos int, data text) returns bool immutable
as $$
select (has_part($1, $2, 7, 32) and (to_positive($1, $2, 7, 32) > 1262177448 or ceiling(log(to_positive($1, $2, 7, 32)::dec*4294967296*4294967296*4294967296::float)) >= 38))
       or (has_part($1, $2, 3, 32) and (to_positive($1, $2, 3, 32) > 1262177448 or ceiling(log(to_positive($1, $2, 3, 32)::dec*4294967296*4294967296*4294967296::float)) >= 38))
$$ language sql;

create or replace function to_uint128_array_or_null (pos int, data text) returns super immutable
as $$
select case when can_overflow($1, $2) then null else to_uint128_array($1, $2) end
$$ language sql;
