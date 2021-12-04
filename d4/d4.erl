-module(d4).
-export([p1/0]).
-define(FILENAME, d4input).

-type status() :: marked | unmarked.
-type cell()   :: {GuessNumber :: integer(), status()}.
-type row()    :: [cell()].
-type board()  :: [row()].
-type boards() :: [board()].

-spec markBoards(boards(), ChosenNums :: [integer()], ChosenNum :: integer()) -> ok.
-spec markBoard(board(), ChosenNum :: integer()) -> board().
-spec markRow(row(), ChosenNum :: integer())	 -> row().
-spec markCell(cell(), ChosenNum :: integer())	 -> cell().
-spec checkBoard(board())	-> true | false.
-spec checkRow(row())		-> true | false.
-spec checkCell(cell())		-> true | false.
-spec sum([] | [cell()], Acc :: integer()) -> acc.

p1() ->
	spawn(fun main/0).

main() ->
	{_, Data} = file:read_file(?FILENAME),
	[Chosen|Boards] = binary:split(Data, <<"\n\n">>, [global, trim_all]),
	ChosenNums = lists:map(fun erlang:binary_to_integer/1, string:lexemes(Chosen, ",")),
	BinaryBoardsList = [binary:split(Board, <<"\n">>, [global, trim_all]) || Board <- Boards],
	ProperBoards = lists:map(fun(Board) -> lists:map(fun(Row) -> lists:map(fun(Number) -> {erlang:binary_to_integer(Number), unmarked} end, string:lexemes(Row, " ")) end, Board) end, BinaryBoardsList), %% God, fogive me for this
	markBoards(ProperBoards, tl(ChosenNums), hd(ChosenNums)).

markBoards(Boards, [NextNum|ChosenNums], ChosenNum) ->
	MarkedBoards = lists:map(fun(Board) -> markBoard(Board, ChosenNum) end, Boards),
	markBoards(MarkedBoards, ChosenNums, NextNum).
markBoard(Board, ChosenNum) ->
	MarkedBoard = lists:map(fun(Row) -> markRow(Row, ChosenNum) end, Board),
	case checkBoard(MarkedBoard) of
		true  ->
			io:format("Sum is: ~p~n", [ChosenNum * sum(lists:flatten(MarkedBoard), 0)]),
			exit(ok);
		false -> MarkedBoard
	end.
markRow(Row, ChosenNum) ->
	lists:map(fun(Cell) -> markCell(Cell, ChosenNum) end, Row).
markCell({GuessNumber, _Status}, ChosenNum) when GuessNumber =:= ChosenNum ->
	{GuessNumber, marked};
markCell(Cell, _ChoseNum) -> Cell.

checkBoard(Board) ->
	lists:any(fun checkRow/1, Board) orelse
	lists:any(fun checkRow/1, transpose(Board)).
checkRow(Row) ->
	lists:all(fun checkCell/1, Row).
checkCell({_, marked})	-> true;
checkCell(_) 			-> false.

sum([], Acc) ->
	Acc;
sum([{GuessNumber, unmarked}|T], Acc) ->
	sum(T, Acc+GuessNumber);
sum([_H|T], Acc) ->
	sum(T, Acc).

transpose([[]|_]) -> [];
transpose(M) ->
  [lists:map(fun hd/1, M) | transpose(lists:map(fun tl/1, M))].

