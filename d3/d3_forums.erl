%% I was too busy to finish p2 but I wanted to know how someone had solved this so I found this on
%% erlangforums.org. Great solution! Learn from it yourself too
%% https://erlangforums.com/t/advent-of-code-2021-day-3/726/2

-module(d3a).
-compile(export_all).

main(File) ->
    {ok, RawData} = file:read_file(File),
    Data = [ binary_to_list(N) || N <- binary:split(RawData, <<"\n">>, [global, trim]) ],
    io:format("part 1: ~p~n", [solve1(Data)]),
    io:format("part 2: ~p~n", [solve2(Data)]),
    ok.

solve1(Data) ->
    Counts = lists:foldl(fun bit_count/2, lists:duplicate(length(hd(Data)), 0), Data),
    bit_count_to_integer(fun most/1, Counts)
  * bit_count_to_integer(fun least/1, Counts).

bit_count(Bits, Acc) ->
    [ inc(Bit) + A || {Bit, A} <- lists:zip(Bits, Acc) ].

bit_count_to_integer(BitFun, Counts) ->
    list_to_integer([ BitFun(X) || X <- Counts ], 2).

most(V)  when V >= 0 -> $1;
most(_)              -> $0.

least(V) when V >= 0 -> $0;
least(_)             -> $1.

inc($0) -> -1;
inc($1) ->  1.

solve2(Data) ->
    bits_filter(fun most/1, Data)
  * bits_filter(fun least/1, Data).

bits_filter(BitFun, BitsList) ->
    bits_filter(1, BitFun, BitsList).

bits_filter(_, _, [Bits]) ->
    list_to_integer(Bits, 2);
bits_filter(N, BitFun, Data) ->
    V = BitFun(lists:sum([ inc(lists:nth(N, D)) || D <- Data ])),
    bits_filter(N + 1, BitFun, [ D || D <- Data, lists:nth(N, D) =:= V ]).

