:- use_module(library(random)).

coor(X, Y) :- integer(X), integer(Y).

% validMoves([]).
% validMoves([Move|Moves]) :- (Move =:= "U"; Move =:= "D"; Move =:= "L"; Move =:= "R") -> validMoves(Moves). 

% individual(Fitness, Moves) :- integer(Fitness), validMoves(Moves).

individual(fitness, moves).
populationSize(1000).

maze([["#", "#", "#", "#", "#"],
    ["#", " ", " ", " ", "E"],
    ["#", " ", "#", "#", "#"],
    ["#", " ", " ", "S", "#"],
    ["#", "#", "#", "#", "#"]]).

getIndex(0, [Head|_], Head).
getIndex(X, [_|Tail], Element) :- K is X - 1, getIndex(K, Tail, Element).

icon(X, Y, Icon) :- maze(Maze), getIndex(X, Maze, Line), getIndex(Y, Line, Element), Icon is Element.

isValid(X, Y) :- maze(Maze), length(Maze, Len), X < Len, Y < Len.
isAWall(X, Y) :- isValid(X, Y), icon(X, Y, Icon), Icon =:= "#".
isValidMove(X, Y) :- isValid(X, Y), not(isAWall(X, Y)).

sumVector(coor(X1, Y1), coor(X2, Y2), coor(X3, Y3)) :- X3 is X1 + X2, Y3 is Y1 + Y2.
makeAMove(Coordenadas, Direction, Result) :- getMove(Direction, CoorMove), sumVector(Coordenadas, CoorMove, Result).

getMove("U", coor(0, 1)).
getMove("D", coor(0, -1)).
getMove("L", coor(-1, 0)).
getMove("R", coor(1, 0)).
move(0, "U").
move(1, "D").
move(2, "L").
move(3, "R").

randomMove(Move) :- random_between(0, 3, Rand), move(Rand, Move).

randomMoves([Move], 1) :- randomMove(Move).
randomMoves([M|RandMoves], Len) :- randomMove(M), K is Len - 1, randomMoves(RandMoves, K).

buildIndividuo(ChromossomeSize, individual(Fitness, Moves)) :- Fitness is 10**6, randomMoves(Moves, ChromossomeSize).

initPopulation(ChromossomeSize, [Individuo], 1) :- buildIndividuo(ChromossomeSize, Individuo).
initPopulation(ChromossomeSize, [I|Individuos], Len) :- buildIndividuo(ChromossomeSize, I), K is Len - 1, initPopulation(ChromossomeSize, Individuos, K).

% Testando
% sumVector(coor(1, 5), coor(0, 1), Coor).
% randomMove(Move).
% randomMoves(Moves, 5).
% buildIndividuo(5, Individuo).
% initPopulation(5, Population, 10).