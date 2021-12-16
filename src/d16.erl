-module(d16).
-export([main/0, main/1]).
-include("../include/aoc2021.hrl").
-type bits()   :: bitstring(). 
-type ver()    :: bits().
-type val()    :: non_neg_integer().
-type cnt()    :: non_neg_integer().
-type len()    :: non_neg_integer().
-type packet() :: {literal, ver(), val()}
                | {operator, ver(), val(), [packet()]}.

main() ->
    parse_packet(binary:decode_hex(<<"D2FE28">>)).
-spec main(bits()) -> {packet(), packet()}.
main(Bits) ->
    parse_packet(binary:decode_hex(Bits)).

-spec parse_packet(bits()) -> {packet(), bits()}.
parse_packet(<<Ver:3, 4:3, Groups/bits>>) ->
    {Val, Rest} = parse_group(Groups, 0),
    {{literal, Ver, Val}, Rest};
parse_packet(<<Ver: 3, Type:3, 0:1, Length:15, Operands/bits>>) ->
    {Packets, Rest} = parse_operands_len(Length, Operands, []),
    {{operator, Ver, Type, Packets}, Rest};
parse_packet(<<Ver: 3, Type:3, 1:1, SubPacketCnt:11, Operands/bits>>) ->
    {Packets, Rest} = parse_operands_cnt(SubPacketCnt, Operands, []),
    {{operator, Ver, Type, Packets}, Rest}.

-spec parse_group(bits(), non_neg_integer()) -> {non_neg_integer(), bits()}.
parse_group(<<0:1, Group:4, Rest/bits>>, Acc) ->
    {Acc bsl 4 + Group, Rest};
parse_group(<<1:1, Group:4, Rest/bits>>, Acc) ->
    parse_group(Rest, Acc bsl 4 + Group).

-spec parse_operands_cnt(cnt(), bits(), [packet()]) -> {[packet()], bits()}.
parse_operands_cnt(0  , Bits, Acc) ->
    {Acc, Bits};
parse_operands_cnt(Cnt, Bits, Acc) ->
    {Packet, Rest} = parse_packet(Bits),
    parse_operands_cnt(Cnt-1, Rest, Acc ++ [Packet]).

-spec parse_operands_len(len(), bits(), [packet()]) -> {[packet()], bits()}.
parse_operands_len(0  , Bits, Acc) ->
    {Acc, Bits};
parse_operands_len(Len, Bits, Acc) ->
    {Packet, Rest} = parse_packet(Bits),
    Remaining = Len-(bit_size(Bits) - bit_size(Rest)),
    parse_operands_len(Remaining, Rest, Acc ++ [Packet]).
