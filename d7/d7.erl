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
	Fuel1      =     element(1, lists:foldl(fun total_fuel1/2, {0, Median   }, CrabsPos)),
	Fuel2      = min(element(1, lists:foldl(fun total_fuel2/2, {0, MeanCeil }, CrabsPos)),
	                 element(1, lists:foldl(fun total_fuel2/2, {0, MeanFloor}, CrabsPos))),
	{Fuel1, Fuel2}.

total_fuel1(Pos, {Fuel, Median}) ->
	{Fuel + abs(Median-Pos), Median}.

total_fuel2(Pos, {Fuel, Mean}) ->
	{Fuel + crab_fuel2(Pos, Mean), Mean}.

crab_fuel2(Pos, Mean) ->
	crab_fuel2(Pos, Mean, 1, 0).
crab_fuel2(Pos, Mean, _Inc, Fuel) when Pos =:= Mean ->
	Fuel;
crab_fuel2(Pos, Mean, Incr, Fuel) when Pos > Mean ->
	crab_fuel2(Pos-1, Mean, Incr+1, Fuel+Incr);
crab_fuel2(Pos, Mean, Incr, Fuel) when Pos < Mean ->
	crab_fuel2(Pos+1, Mean, Incr+1, Fuel+Incr).
