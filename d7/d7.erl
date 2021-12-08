-module(d7).
-export([main/0]).
-define(FILENAME, 'd7.in').

main() ->
	{_, Raw}   = file:read_file(?FILENAME),
	CrabsPos   = lists:map(fun binary_to_integer/1, string:lexemes(Raw, ",\n")),
	CrabsCount = length(CrabsPos),
	Median     = lists:nth(round(CrabsCount/2), lists:sort(CrabsPos)),
	MeanFloor  = floor(lists:sum(CrabsPos) / CrabsCount),
	MeanCeil   =  ceil(lists:sum(CrabsPos) / CrabsCount),
	Fuel1      =     element(1, lists:foldl(fun fuel1/2, {0, Median   }, CrabsPos)),
	Fuel2      = min(element(1, lists:foldl(fun fuel2/2, {0, MeanCeil }, CrabsPos)),
	                 element(1, lists:foldl(fun fuel2/2, {0, MeanFloor}, CrabsPos))),
	{Fuel1, Fuel2}.

fuel1(Pos, {Fuel, Median}) ->
	{Fuel + abs(Median-Pos), Median}.

fuel2(Pos, {Fuel, Mean}) ->
	Goal = abs(Mean-Pos),
	{Fuel + Goal*(Goal+1)/2, Mean}.
