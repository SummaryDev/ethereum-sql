/*
playground to manually test abi decoding defined in functions.sql

https://github.com/web3/web3.js/blob/1.x/test/abi.decodeParameter.js
 */

select to_part(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF', 0, 32); -- FFFFFFFF
select to_part(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF', 1, 32); -- 098A223F
select to_part(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF', 2, 32); -- 5A86C47A
select to_part(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF', 3, 32); -- 4B3B4CA8
select to_part(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF', 4, 32); -- 00000000
select to_part(0, '777777776666666655555555000000004B3B4CA85A86C47A098A223FFFFFFFFF', 5, 32); -- 55555555
select to_part(0, '777777776666666655555555000000004B3B4CA85A86C47A098A223FFFFFFFFF', 6, 32); -- 66666666
select to_part(0, '777777776666666655555555000000004B3B4CA85A86C47A098A223FFFFFFFFF', 7, 32); -- 77777777
select to_part(0, '777777776666666655555555000000004B3B4CA85A86C47A098A223FFFFFFFFF', 0, 64); -- 098A223FFFFFFFFF
select to_part(0, '777777776666666655555555000000004B3B4CA85A86C47A098A223FFFFFFFFF', 1, 64); -- 4B3B4CA85A86C47A
select to_part(0, '777777776666666655555555000000004B3B4CA85A86C47A098A223FFFFFFFFF', 2, 64); -- 5555555500000000
select to_part(0, '777777776666666655555555000000004B3B4CA85A86C47A098A223FFFFFFFFF', 3, 64); -- 7777777766666666
-- select to_part(0, '00000001', 0, 32); -- 7777777766666666

select to_positive(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF', 0, 32); -- FFFFFFFF
select to_positive(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF', 1, 32); -- 098A223F
select to_positive(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF', 2, 32); -- 5A86C47A
select to_positive(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF', 3, 32); -- 4B3B4CA8

select to_uint32(0, '0000000000000000000000000000000000000000000000000000000000000000'); -- 0
select to_uint32(0, '0000000000000000000000000000000000000000000000000000000000000001'); -- 1
-- select to_uint32(0, '00000001'); -- 1 still
-- select to_uint32(0, '1');
select to_uint32(0, '0000000000000000000000000000000000000000000000000000000000000010'); -- 16
select to_uint32(0, '000000000000000000000000000000000000000000000000000000000000000f'); -- 15
select to_uint32(0, '00000000000000000000000000000000000000000000000000000000ffffffff'); -- 4294967295
select to_uint32(0, '0000000000000000000000000000000000000000000000000000000fffffffff'); -- 4294967295 still
-- select to_uint32(0, 'ffffffffffffffff'); -- 4294967295 still
-- select to_uint32(0, 'ff'); -- 255

select to_uint64(0, '0000000000000000000000000000000000000000000000000000000000000000'); -- 0
select to_uint64(0, '0000000000000000000000000000000000000000000000000000000000000001'); -- 1
-- select to_uint64(0, '00000000000000000000000000000001'); -- 1 still
-- select to_uint64(0, '0000000000000001'); -- 1 still
-- select to_uint64(0, '1');
select to_uint64(0, '0000000000000000000000000000000000000000000000000000000000000010'); -- 16
select to_uint64(0, '000000000000000000000000000000000000000000000000000000000000000f'); -- 15
select to_uint64(0, '000000000000000000000000000000000000000000000000ffffffffffffffff'); -- 18446744073709551615 on postgres, 9223372036854775807 on redshift
select to_uint64(0, '0000000000000000000000000000000000000000000000007fffffffffffffff'); -- TODO 9223372036854775807 maximum on redshift prevent loss of precision
select to_uint64(0, '0000000000000000000000000000000000000000000000008fffffffffffffff'); -- still 9223372036854775807 maximum on redshift
select to_uint64(0, '000000000000000000000000000000000000000000000fffffffffffffffffff'); -- still 18446744073709551615 on postgres, 9223372036854775807 on redshift
-- select to_uint64(0, '7fffffffffffffff'); -- still 18446744073709551615 on postgres, 9223372036854775807 on redshift

select to_binary(0, '00000000000000000000000000000000000000000000000fffffffffffffffff', 0, 32); -- ffffffff
select to_binary(0, '00000000000000000000000000000000000000000000000ffffffffffffffff1', 0, 64); -- fffffffffffffff1

select is_positive(0, '0000000000000000000000000000000000000000000000000000000000000000', 0, 32); -- true
select is_positive(0, '00000000000000000000000000000000000000000000000fffffffffffffffff', 0, 32); -- -1 false
select is_positive(0, '00000000000000000000000000000000000000000000000ffffffffffffffff1', 0, 32); -- -15 false
-- select is_positive(0, 'ffffffffffffb7c5', 57, 32); -- false -18491
select is_positive(0, '0000000000000000000000000000000000000000000000000000000000000000', 0, 64); -- true
select is_positive(0, '00000000000000000000000000000000000000000000000fffffffffffffffff', 0, 64); -- -1 false
select is_positive(0, '00000000000000000000000000000000000000000000000ffffffffffffffff1', 0, 64); -- -15 false
-- select is_positive(0, 'ffffffffffffb7c5', 0, 32); -- false -18491

select to_negative(0, '00000000000000000000000000000000000000000000000fffffffffffffffff', 0, 32); -- -1
select to_negative(0, '00000000000000000000000000000000000000000000000ffffffffffffffff1', 0, 32); -- -15
-- select to_negative(0, 'ffffffffffffb7c5', 57, 32); -- -18491
select to_negative(0, '00000000000000000000000000000000000000000000000fffffffffffffffff', 0, 64); -- -1
select to_negative(0, '00000000000000000000000000000000000000000000000ffffffffffffffff1', 0, 64); -- -15
-- select to_negative(0, 'ffffffffffffb7c5', 0, 64); -- -18491

select to_int32(0, '0000000000000000000000000000000000000000000000000000000000000000'); -- 0
select to_int32(0, '0000000000000000000000000000000000000000000000000000000000000001'); -- 1
select to_int32(0, '00000000000000000000000000000001'); -- 1 still
-- select to_int32(0, '1');
select to_int32(0, '0000000000000000000000000000000000000000000000000000000000000010'); -- 16
select to_int32(0, '000000000000000000000000000000000000000000000000000000000000000f'); -- 15
select to_int32(0, '00000000000000000000000000000000000000000000000fffffffffffffffff'); -- -1
select to_int32(0, '0000000000000000000000000000000000000000000000ffffffffffffffffff'); -- -1 still
select to_int32(0, '00000000000000000000000000000000000000000000000ffffffffffffffff1'); -- -15
select to_int32(0, 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff69'); -- -151
select to_int32(0, 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb7c5'); -- -18491
-- select to_int32(0, 'ffffffffffffb7c5'); -- -18491
-- select to_int32(0, 'ff'); -- 255

select to_int64(0, '0000000000000000000000000000000000000000000000000000000000000000');
select to_int64(0, '0000000000000000000000000000000000000000000000000000000000000001'); -- 1
-- select to_int64(0, '00000000000000000000000000000001'); -- 1 still
-- select to_int64(0, '1');
select to_int64(0, '0000000000000000000000000000000000000000000000000000000000000010');
select to_int64(0, '000000000000000000000000000000000000000000000000000000000000000f');
select to_int64(0, '00000000000000000000000000000000000000000000000fffffffffffffffff'); -- -1
select to_int64(0, '0000000000000000000000000000000000000000000000ffffffffffffffffff'); -- -1 still
select to_int64(0, '00000000000000000000000000000000000000000000000ffffffffffffffff1'); -- -15
select to_int64(0, 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff69'); -- -151
select to_int64(0, 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb7c5'); -- -18491
-- select to_int64(0, 'ffffffffffffb7c5'); -- -18491

select to_uint128(0, '0000000000000000000000000000000000000000000000000000000000000000'); -- 0
select to_uint128(0, '0000000000000000000000000000000000000000000000000000000000000001'); -- 1
select to_uint128(0, '0000000000000000000000000000000000000000000000000000000000000010'); -- 16
select to_uint128(0, '0000000000000000000000000000000000000000000000010000000000000000'); -- 18446744073709551616
select to_uint128(0, '000000000000000000000000000000000000000000000001ffffffffffffffff'); -- 36893488147419103231
select to_uint128(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF'); -- 99999999999999999999999999999999999999 38 characters maximum decimal on redshift https://docs.aws.amazon.com/redshift/latest/dg/r_Numeric_types201.html#r_Numeric_types201-decimal-or-numeric-type
-- select to_uint128(0, '000000000000000000000000000000004B3B4CA85A86C47A098A224000000000'); -- 100000000000000000000000000000000000000 39 characters will fail overflow decimal on redshift
-- select to_uint128(0, '00000000000000000000000000000000ffffffffffffffffffffffffffffffff'); -- 340282366920938463463374607431768211455 ok on postgres but will fail on redshift as 39 characters will overflow decimal on redshift
-- select to_uint128(0, '0000000000000000000000000000000fffffffffffffffffffffffffffffffff'); -- 340282366920938463463374607431768211455 still on postgres



select can_convert_to_decimal(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF');
select can_convert_to_decimal(0, '000000000000000000000000000000014B3B4CA85A86C47A098A224000000000');

select to_decimal(0, '000000000000000000000000000000000000000000000001ffffffffffffffff'); -- 36893488147419103231
select to_decimal(0, '000000000000000000000000000000014B3B4CA85A86C47A098A223FFFFFFFFF'); -- null to prevent overflow on redshift uses imprecise can_overflow which uses logarithm and returns here a false positive

select to_location(0, '0000000000000000000000000000000000000000000000000000000000000020');

select to_size(0, '0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000748656c6c6f252100000000000000000000000000000000000000000000000000');

select to_raw_bytes(0, '0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000748656c6c6f252100000000000000000000000000000000000000000000000000');

select to_bytes(0, '0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000748656c6c6f252100000000000000000000000000000000000000000000000000');

select to_bytes(0, '0000000000000000000000000000000000000000000000000000000000000020' ||
                   '0000000000000000000000000000000000000000000000000000000000000009' ||
                   '6761766f66796f726b0000000000000000000000000000000000000000000000');

select to_bytes(0, '0000000000000000000000000000000000000000000000000000000000000020' ||
                   '0000000000000000000000000000000000000000000000000000000000000020' ||
                   '731a3afc00d1b1e3461b955e53fc866dcf303b3eb9f4c16f89e388930f48134b');

select to_bytes(0, '0000000000000000000000000000000000000000000000000000000000000020' ||
                   '000000000000000000000000000000000000000000000000000000000000009f' ||
                   'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' ||
                   'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' ||
                   'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' ||
                   'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' ||
                   'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff100');

select to_fixed_bytes(0, '6761766f66796f726b0000000000000000000000000000000000000000000000', 32);

select to_fixed_bytes(0, '731a3afc00d1b1e3461b955e53fc866dcf303b3eb9f4c16f89e388930f48134b', 32);

select to_fixed_bytes(0, '02838654a83c213dae3698391eabbd54a5b6e1fb3452bc7fa4ea0dd5c8ce7e29', 32);

select to_fixed_bytes(0, 'c3a40000c3a40000000000000000000000000000000000000000000000000000', 32);

select to_fixed_bytes(0, 'cf00000000000000000000000000000000000000000000000000000000000000', 1);

select to_string(0, '0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000748656c6c6f252100000000000000000000000000000000000000000000000000');

select to_string(0, '0000000000000000000000000000000000000000000000000000000000000020' ||
                    '0000000000000000000000000000000000000000000000000000000000000009' ||
                    '6761766f66796f726b0000000000000000000000000000000000000000000000');

select to_string(0, '00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000026486565c3a4c3b6c3b6c3a4f09f9185443334c99dc9a33234d084cdbd2d2e2cc3a4c3bc2b232f0000000000000000000000000000000000000000000000000000');

select to_string(0, '0000000000000000000000000000000000000000000000000000000000000020' ||
                    '0000000000000000000000000000000000000000000000000000000000000002' ||
                    'c3bc000000000000000000000000000000000000000000000000000000000000');

select to_address(0, '000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c1');

select to_address(0, '000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c1' ||
                     '000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c3');

select to_bool(0, '0000000000000000000000000000000000000000000000000000000000000001');
select to_bool(0, '0000000000000000000000000000000000000000000000000000000000000000');

select to_element(0, '0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000748656c6c6f252100000000000000000000000000000000000000000000000000', 'bytes');
select to_element(0, '0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000748656c6c6f252100000000000000000000000000000000000000000000000000', 'string');
select to_element(0, '000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c1', 'address');
select to_element(0, '0000000000000000000000000000000000000000000000000000000000000020', 'int64');
select to_element(0, '0000000000000000000000000000000000000000000000000000000000000001', 'bool');
select to_element(0, '0000000000000000000000000000000000000000000000000000000000000000', 'bool');

select to_element(0, '0000000000000000000000000000000000000000000000000000000000000003', 'int64');

select to_size(0, '0000000000000000000000000000000000000000000000000000000000000020' ||
                  '0000000000000000000000000000000000000000000000000000000000000001' ||
                  '0000000000000000000000000000000000000000000000000000000000000003');

select to_element(128, '0000000000000000000000000000000000000000000000000000000000000020' ||
                       '0000000000000000000000000000000000000000000000000000000000000001' ||
                       '0000000000000000000000000000000000000000000000000000000000000003', 'int64');

select to_array(0, '0000000000000000000000000000000000000000000000000000000000000020' ||
                   '0000000000000000000000000000000000000000000000000000000000000001' ||
                   '0000000000000000000000000000000000000000000000000000000000000003', 'int64');

select to_array(0, '0000000000000000000000000000000000000000000000000000000000000020' ||
                   '0000000000000000000000000000000000000000000000000000000000000002' ||
                   '000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c1' ||
                   '000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c3', 'address');

select to_array(0, '0000000000000000000000000000000000000000000000000000000000000020' ||
                   '0000000000000000000000000000000000000000000000000000000000000003' ||
                   '0000000000000000000000000000000000000000000000000000000000000001' ||
                   '0000000000000000000000000000000000000000000000000000000000000002' ||
                   '0000000000000000000000000000000000000000000000000000000000000003', 'int64');

select to_array(0, '0000000000000000000000000000000000000000000000000000000000000020' ||
                   '0000000000000000000000000000000000000000000000000000000000000003' ||
                   '0000000000000000000000000000000000000000000000000000000000000001' ||
                   '0000000000000000000000000000000000000000000000000000000000000001' ||
                   '0000000000000000000000000000000000000000000000000000000000000000', 'bool');

select to_fixed_array(0, '0000000000000000000000000000000000000000000000000000000000000001', 'bool', 1);

select to_fixed_array(0, '0000000000000000000000000000000000000000000000000000000000000000', 'bool', 1);

select to_fixed_array(0, '0000000000000000000000000000000000000000000000000000000000000001' ||
                         '0000000000000000000000000000000000000000000000000000000000000000', 'bool', 2);

select to_fixed_array(0, '000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c1' ||
                         '000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c3', 'address', 2);

select to_uint32_array(2, '0x000000000000000000000000f089678b4aaeeed0b9fcecf0cf8bf480875c9877000000000000000000000000b1690c08e213a35ed9bab7b318de14420fb57d8c00000000000000000000000000000000000000000000000000000000001ecb3a');
-- [0,0,0,4035536779,1252978384,3120360688,3482055808,2270992503]
-- calc 4294967296*4294967296*4294967296*4294967296*4035536779 + 4294967296*4294967296*4294967296*1252978384 + 4294967296*4294967296*3120360688 + 4294967296*3482055808 + 2270992503
-- 1373222007053891329594168749456532073071865796727

select to_uint64_array(2, '0x000000000000000000000000f089678b4aaeeed0b9fcecf0cf8bf480875c9877');
--[0,4035536779,5381501184995290352,14955315820477847671]
-- calc 18446744073709551616*18446744073709551616*4035536779 + 18446744073709551616*5381501184995290352 + 14955315820477847671
-- 1373222007053891329594168749456532073071865796727

select to_uint128_array(2, '0x000000000000000000000000f089678b4aaeeed0b9fcecf0cf8bf480875c9877');
-- [4035536779,99271175091972801710944722738128656503]
-- calc 340282366920938463463374607431768211456*4035536779 + 99271175091972801710944722738128656503
-- 1373222007053891329594168749456532073071865796727

select to_uint128_array(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF'); -- 99999999999999999999999999999999999999 38 characters maximum decimal on redshift
select to_uint128_array(0, '000000000000000000000000000000004B3B4CA85A86C47A098A224000000000'); -- 100000000000000000000000000000000000000 39 characters will fail overflow decimal on redshift

select to_uint64_array(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF'); -- 99999999999999999999999999999999999999 38 characters maximum decimal on redshift
-- [0,0,5421010862427522170,687399551400673279]
-- calc 18446744073709551616*5421010862427522170 + 687399551400673279

select to_uint64_array(0, '000000000000000000000000000000004B3B4CA85A86C47A098A224000000000'); -- 100000000000000000000000000000000000000 39 characters will fail overflow decimal on redshift
-- [0,0,5421010862427522170,687399551400673280]

select to_uint64_array(0, '00000000000000000000000000000000ffffffffffffffff0000000000000000'); -- 100000000000000000000000000000000000000 39 characters will fail overflow decimal on redshift

select can_overflow(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF'); -- true 99999999999999999999999999999999999999
select can_overflow(0, '000000000000000000000000000000004B3B4CA8270000000000000000000000'); -- false 9999999998188694553551280671012421632

select can_overflow(0, 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
select can_overflow(0, '00000000000000000000000000000000ffffffffffffffffffffffffffffffff');
select can_overflow(0, 'ffffffffffffffffffffffffffffffff00000000000000000000000000000000');
select can_overflow(0, '000000000000000000000000000000004B3B4CA8000000000000000000000000');
select to_positive(0, '00000000000000000000000000000000ffffffffffffffffffffffffffffffff', 3, 32)::dec;
select to_positive(0, '00000000000000000000000000000000ffffffffffffffffffffffffffffffff', 3, 32)::dec;

select can_overflow(0, '000000000000000000000000000000000000000000000000ffffffffffffffff');

select index, element from to_uint128_array_or_null(0, '000000000000000000000000000000000000000000000000ffffffffffffffff') AS element AT index;

select to_uint128_array_or_null(0, '000000000000000000000000000000004B3B4CA85A86C47A098A223FFFFFFFFF'); -- null
select to_uint128_array_or_null(0, '000000000000000000000000000000004B3B4CA8200000000000000000000000'); -- [0,99999999981886945535512806710124216320]
select to_uint128_array_or_null(2, '0x000000000000000000000000f089678b4aaeeed0b9fcecf0cf8bf480875c9877');