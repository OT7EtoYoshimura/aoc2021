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
	Fuel1      =     lists:sum(lists:map(fun(Elem) ->           abs(Median   -Elem)  end, CrabsPos)),
	Fuel2      = min(lists:sum(lists:map(fun(Elem) -> gauss_sum(abs(MeanCeil -Elem)) end, CrabsPos)),
					 lists:sum(lists:map(fun(Elem) -> gauss_sum(abs(MeanFloor-Elem)) end, CrabsPos))),
	{Fuel1, trunc(Fuel2)}.

gauss_sum(Goal) ->
	Goal*(Goal+1)/2.
