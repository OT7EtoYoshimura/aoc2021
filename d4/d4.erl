-module(d4).
-export([both/0]).
-define(FILENAME, d4_bigboi).

-type status()	:: marked | unmarked.
-type cell()	:: {Guess :: integer(), status()}.
-type row()		:: [cell()].
-type board()	:: [row()].
-type boards()	:: [board()].

both() ->
	spawn(fun main/0).

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Impure IO Garbage %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

main() ->
	StartTimestamp = os:timestamp(),
	{_, Data} = file:read_file(?FILENAME),
	[ChosenNumsRaw|BoardsRaw] = binary:split(Data, <<"\n\n">>, [global, trim_all]),
	ChosenNums = lists:map(fun binary_to_integer/1, string:lexemes(ChosenNumsRaw, ",")),
	BoardsRawList = [binary:split(BoardRaw, <<"\n">>, [global, trim_all]) || BoardRaw <- BoardsRaw],
	%% God, forgive me for this next line.
	Boards = lists:map(fun(Board) -> lists:map(fun(Row) -> lists:map(fun(GuessRaw) -> {binary_to_integer(GuessRaw), unmarked} end, string:lexemes(Row, " ")) end, Board) end, BoardsRawList),
	markBoards(Boards, ChosenNums),
	io:format("Microseconds: ~p~n", [timer:now_diff(os:timestamp(), StartTimestamp)]).

%%%%%%%%%%%%%%%%%%%%%%
%%% The Good Stuff %%%
%%%%%%%%%%%%%%%%%%%%%%

-spec markBoards(boards() | [[]], ChosenNums :: [integer()] | []) -> ok.
-spec markBoard(board(),   ChosenNum :: integer()) -> board().
-spec markRow(row(),       ChosenNum :: integer()) -> row().
-spec markCell(cell(),     ChosenNum :: integer()) -> cell().
-spec checkBoard(board())   -> true | false.
-spec checkRow(row())       -> true | false.
-spec checkCell(cell())     -> true | false.
-spec sum ([] | [cell()], Acc :: integer()) -> integer().

markBoards(Boards, [ChosenNum|ChosenNums]) ->
	MarkedBoards = lists:map(fun(Board) -> markBoard(Board, ChosenNum) end, Boards),
	markBoards(MarkedBoards, ChosenNums);
markBoards(_,_) ->
	ok.
markBoard([], _) ->
	[];
markBoard(Board, ChosenNum) ->
	MarkedBoard = lists:map(fun(Row) -> markRow(Row, ChosenNum) end, Board),
	case checkBoard(MarkedBoard) of
		true  ->
			io:format("Score: ~p~n", [ChosenNum * sum(lists:flatten(MarkedBoard), 0)]),
			[];
		false -> MarkedBoard
	end.
markRow(Row, ChosenNum) ->
	lists:map(fun(Cell) -> markCell(Cell, ChosenNum) end, Row).
markCell({Guess, _}, ChosenNum) when Guess =:= ChosenNum ->
	{Guess, marked};
markCell(Cell, _) -> Cell.

checkBoard(Board) ->
	lists:any(fun checkRow/1, Board) orelse
	lists:any(fun checkRow/1, transpose(Board)).
checkRow(Row) ->
	lists:all(fun checkCell/1, Row).
checkCell({_, marked})	-> true;
checkCell(_) 			-> false.

sum([], Acc) ->
	Acc;
sum([{Guess, unmarked}|T], Acc) ->
	sum(T, Acc+Guess);
sum([_|T], Acc) ->
	sum(T, Acc).

transpose([[]|_]) -> [];
transpose(M) ->
  [lists:map(fun hd/1, M) | transpose(lists:map(fun tl/1, M))].

