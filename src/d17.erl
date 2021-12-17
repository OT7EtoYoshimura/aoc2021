-module(d17).
-export([main/0, main/4]).
-include("../include/aoc2021.hrl").
-define(XMIN, 117).
-define(XMAX, 164).
-define(YMIN,-140).
-define(YMAX, -89).

main() ->
    main(?XMIN,?XMAX,?YMIN,?YMAX).
main(XMin,XMax,YMin,YMax) ->   
    Vels  = [{XVel,YVel} || XVel <- lists:seq(XMax, 0, -1), YVel <- lists:seq(abs(YMin), YMin, -1)],
    Range = {{XMin, XMax}, {YMin, YMax}},
    Hits  = lists:filter(fun(V) -> m_throw(V, Range) end, Vels),
    MaxYV = abs(?YMIN)-1,
    {{p1, ints_sum(MaxYV)}, {p2, length(Hits)}}.

m_throw({XVel,YVel}, Range) ->
    {Coords, Vels} = tick({0,0}, {XVel, YVel}),
    m_throw(Coords, Vels, Range).
m_throw({_X,Y} , _Vels, {_XRange,{YMin,_YMax}})
  when Y < YMin -> false;
m_throw({ X,Y} , _Vels, {{ XMin,XMax},{YMin, YMax}})
  when X >= XMin, X =< XMax, Y >= YMin, Y =< YMax -> true;
m_throw(Coords, Vels, Range) ->
    {NCoords, NVels} = tick(Coords,Vels),
    m_throw(NCoords, NVels, Range).

tick({X,Y}, {XVel,YVel}) when XVel =:= 0 ->
    {{X+XVel, Y+YVel}, {XVel  , YVel-1}};
tick({X,Y}, {XVel,YVel}) when XVel > 0   ->
    {{X+XVel, Y+YVel}, {XVel-1, YVel-1}}.
