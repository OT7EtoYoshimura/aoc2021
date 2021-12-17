-module(d17).
-export([p1/4, p1/0]).
-include("../include/aoc2021.hrl").
-define(XMIN, 117).
-define(XMAX, 164).
-define(YMIN,-140).
-define(YMAX, -89).

p1() ->
    p1(?XMIN, ?XMAX, ?YMIN, ?YMAX).
p1(XMin, XMax, YMin, YMax) ->
    Xs = x_range(XMin, XMax),
    Ys = lists:seq(abs(YMin), YMin, -1),
    find_y(Xs, Ys, YMin, YMax).

-spec find_y([uint()], [integer()], integer(), integer()) -> integer().
find_y(Xs, Ys, YMin, YMax) ->
    MaxYVel = hd([Y || Y <- Ys, X <- Xs, hits_target(X,Y,YMin,YMax)]),
    trunc(int_sum(MaxYVel)).

hits_target(_X, Y,    0, _YVel, YMin,  YMax) when Y >= YMin andalso Y =< YMax  -> true;
hits_target(_X, Y,    0, _YVel, YMin, _YMax) when Y < YMin                     -> false;
hits_target( X, Y,    0,  YVel, YMin,  YMax)   -> hits_target(X       , Y + YVel,      0, YVel-1, YMin, YMax);
hits_target( X, Y, XVel,  YVel, YMin,  YMax)   -> hits_target(X + XVel, Y + YVel, XVel-1, YVel-1, YMin, YMax).
hits_target(       XVel,  YVel, YMin,  YMax)   -> hits_target(0       , 0       , XVel  , YVel  , YMin, YMax).
-spec hits_target(uint(), integer(), integer(), integer()) -> true | false.

-spec x_range(uint(), uint()) -> [uint()].
x_range(XMin, XMax) ->
    lists:filter(fun(Elem) -> int_sum(Elem) >= XMin andalso int_sum(Elem) =< XMax end, lists:seq(1, XMax)).

int_sum(Goal) ->
    Goal*(Goal+1)/2.
