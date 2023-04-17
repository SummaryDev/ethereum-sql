/*
creates functions based on duckdb functions
 */

-- set search_path to public;

create or replace function strtol (h) as case when h is null or h = '' then 0 else concat('0x', h)::ubigint end; --todo bigint for jdbc ubigint otherwise

create or replace function char_to_bit(c) as case when c = '1' then '0001'::bit when c = '2' then '0010'::bit when c = '3' then '0011'::bit when c = '4' then '0100'::bit when c = '5' then '0101'::bit when c = '6' then '0110'::bit when c = '7' then '0111'::bit when c = '8' then '1000'::bit when c = '9' then '1001'::bit when c = 'a' then '1010'::bit when c = 'b' then '1011'::bit when c = 'c' then '1100'::bit when c = 'd' then '1101'::bit when c = 'e' then '1110'::bit when c = 'f' then '1111'::bit else '0000'::bit end;

create or replace function bit_to_char(c) as case when c = '0001' then '1' when c = '0010' then '2' when c = '0011' then '3' when c = '0100' then '4' when c = '0101' then '5' when c = '0110' then '6' when c = '0111' then '7' when c = '1000' then '8' when c = '1001' then '9' when c = '1010' then 'a' when c = '1011' then 'b' when c = '1100' then 'c' when c = '1101' then 'd' when c = '1110' then 'e' when c = '1111' then 'f' else '0' end;

create or replace function bit_to_uint(c) as (case when c = '0001' then 1 when c = '0010' then 2 when c = '0011' then 3 when c = '0100' then 4 when c = '0101' then 5 when c = '0110' then 6 when c = '0111' then 7 when c = '1000' then 8 when c = '1001' then 9 when c = '1010' then 10 when c = '1011' then 11 when c = '1100' then 12 when c = '1101' then 13 when c = '1110' then 14 when c = '1111' then 15 else 0 end)::uinteger;

create or replace function hex_32_to_bit(h) as (char_to_bit(h[1]) || char_to_bit(h[2]) || char_to_bit(h[3]) || char_to_bit(h[4]) || char_to_bit(h[5]) || char_to_bit(h[6]) || char_to_bit(h[7]) || char_to_bit(h[8]))::bit;

create or replace function hex_32_to_bit(h) as char_to_bit(h[1]) || char_to_bit(h[2]) || char_to_bit(h[3]) || char_to_bit(h[4]) || char_to_bit(h[5]) || char_to_bit(h[6]) || char_to_bit(h[7]) || char_to_bit(h[8]);

create or replace function bit_to_hex_32(h) as bit_to_char(h[1:4]) || bit_to_char(h[5:8]) || bit_to_char(h[9:12]) || bit_to_char(h[13:16]) || bit_to_char(h[17:20]) || bit_to_char(h[21:24]) || bit_to_char(h[25:28]) || bit_to_char(h[29:32]);

-- create or replace function bit_to_uint_32(h) as bit_to_uint(h[1:4])::uinteger*268435456 + bit_to_uint(h[5:8])::uinteger*16777216 + bit_to_uint(h[9:12])::uinteger*1048576 + bit_to_uint(h[13:16])::uinteger*65536 + bit_to_uint(h[17:20])::uinteger*4096 + bit_to_uint(h[21:24])::uinteger*256 + bit_to_uint(h[25:28])::uinteger*16 + bit_to_uint(h[29:32])::uinteger;
--
-- create or replace function bit_to_uint_32(h) as bit_to_uint('1111')::uinteger*268435456 + bit_to_uint('1111')::uinteger*16777216 + bit_to_uint('1111')::uinteger*1048576 + bit_to_uint('1111')::uinteger*65536 + bit_to_uint('1111')::uinteger*4096 + bit_to_uint('1111')::uinteger*256 + bit_to_uint('1111')::uinteger*16 + bit_to_uint('1111')::uinteger;
--
-- create or replace function bit_to_uint_32(h) as bit_to_uint(array_slice(h, 1, 4))::uinteger*268435456 + bit_to_uint(array_slice(h, 5, 4))::uinteger*16777216 + bit_to_uint(array_slice(h, 1, 4))::uinteger*1048576 + bit_to_uint(array_slice(h, 1, 4))::uinteger*65536 + bit_to_uint(array_slice(h, 1, 4))::uinteger*4096 + bit_to_uint(array_slice(h, 1, 4))::uinteger*256 + bit_to_uint(array_slice(h, 1, 4))::uinteger*16 + bit_to_uint(array_slice(h, 1, 4))::uinteger;
--
-- create or replace function bit_to_uint_32(h) as bit_to_uint(h[1:4])::uinteger*268435456 + bit_to_uint(h[5:8])::uinteger*16777216 + bit_to_uint(h[9:12])::uinteger*1048576 + bit_to_uint(h[13:16])::uinteger*65536 + bit_to_uint(h[17:20])::uinteger*4096 + bit_to_uint(h[21:24])::uinteger*256 + bit_to_uint(h[25:28])::uinteger*16 + bit_to_uint(h[29:32])::uinteger;

create or replace function bit_to_uint_32(h) as bit_to_uint(h[1:4])*268435456 + bit_to_uint(h[5:8])*16777216 + bit_to_uint(h[9:12])*1048576 + bit_to_uint(h[13:16])*65536 + bit_to_uint(h[17:20])*4096 + bit_to_uint(h[21:24])*256 + bit_to_uint(h[25:28])*16 + bit_to_uint(h[29:32]);

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


-- create or replace function to_uint64_array (pos, data)
-- as list_value((to_positive(pos, data, 7, 32)::ubigint*4294967296 + to_positive(pos, data, 6, 32))::ubigint,
-- (to_positive(pos, data, 5, 32)::ubigint*4294967296 + to_positive(pos, data, 4, 32))::ubigint,
-- (to_positive(pos, data, 3, 32)::ubigint*4294967296 + to_positive(pos, data, 2, 32))::ubigint,
-- (to_positive(pos, data, 1, 32)::ubigint*4294967296 + to_positive(pos, data, 0, 32))::ubigint);

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
