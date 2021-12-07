-module(d7).
-export([main/0]).
-define(FILENAME, 'd7.in').

main() ->
	{_, Raw}    = file:read_file(?FILENAME),
	SortedCrabs = lists:sort(lists:map(fun binary_to_integer/1, string:lexemes(Raw, ",\n"))),
	Median      = lists:nth(round(length(SortedCrabs)/2), SortedCrabs),
	{Fuel1, _}  =  lists:foldl(fun total_fuel1/2, {0, Median}, SortedCrabs),
	PropList    = [lists:foldl(fun total_fuel2/2, {0, Pos   }, SortedCrabs) || Pos <- lists:seq(hd(SortedCrabs), lists:last(SortedCrabs))],
	Fuel2       = lists:min(proplists:get_keys(PropList)),
	{Fuel1, Fuel2}.

total_fuel1(Pos, {Fuel, Mean}) ->
	{Fuel + abs(Mean-Pos), Mean}.

total_fuel2(Pos, {Fuel, Goal}) ->
	{Fuel + crab_fuel2(Pos, Goal), Goal}.

crab_fuel2(Pos, Mean) ->
	crab_fuel2(Pos, Mean, 1, 0).
crab_fuel2(Pos, Mean, _Inc, Fuel) when Pos =:= Mean ->
	Fuel;
crab_fuel2(Pos, Mean, Incr, Fuel) when Pos > Mean ->
	crab_fuel2(Pos-1, Mean, Incr+1, Fuel+Incr);
crab_fuel2(Pos, Mean, Incr, Fuel) when Pos < Mean ->
	crab_fuel2(Pos+1, Mean, Incr+1, Fuel+Incr).
