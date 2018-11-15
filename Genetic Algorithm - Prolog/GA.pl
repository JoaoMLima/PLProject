:- use_module(library(random)).

contains(Element, [Element|_]).
contains(Element, [_|Tail]) :- contains(Element, Tail).

individual(fitness, moves).
populationSize(1000).

maze([["#", "#", "#", "#", "#"],
    ["#", " ", " ", " ", "E"],
    ["#", " ", "#", "#", "#"],
    ["#", " ", " ", "S", "#"],
    ["#", "#", "#", "#", "#"]]).

swap((3, 3)).
exit((4, 1)).

getIndex(0, [Head|_], Head).
getIndex(X, [_|Tail], Element) :- K is X - 1, getIndex(K, Tail, Element).

sumVector((X1, Y1), (X2, Y2), (X3, Y3)) :- X3 is X1 + X2, Y3 is Y1 + Y2.

icon(X, Y, Icon) :- maze(Maze), getIndex(Y, Maze, Line), getIndex(X, Line, Icon).
isValid(X, Y) :- maze(Maze), length(Maze, Len), X < Len, Y < Len.
isAWall(X, Y) :- isValid(X, Y), icon(X, Y, Icon), Icon =:= "#".
makeAMove((X, Y), Direction, Result) :- getMove(Direction, CoorMove), sumVector((X, Y), CoorMove, Result).
isValidMove(X, Y) :- isValid(X, Y), not(isAWall(X, Y)).

getMove("U", (0, 1)).
getMove("D", (0, -1)).
getMove("L", (-1, 0)).
getMove("R", (1, 0)).
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

calculateFitnessIndividual(individual(Fitness, Moves), NewFitness) :- swap(Swap), NewFitness is Fitness, calculateFitnessIndividualAux(NewFitness, Moves, Swap, []).

calculateFitnessIndividualAux(_,[],_,_).
calculateFitnessIndividualAux(CurrentFitness, [M|Moves], (XCurrent, YCurrent), Visited) :- 
        makeAMove((XCurrent,YCurrent), M, (XNext, YNext)),
        ((isValidMove(XNext, YNext), contains((XNext, YNext), Visited)) -> (F is CurrentFitness - 500, calculateFitnessIndividualAux(F, Moves, (XNext, YNext), Visited));
        (isValidMove(XNext, YNext), not(contains((XNext, YNext), Visited))) -> (F is CurrentFitness - 200, V is [(XNext, YNext)|Visited], calculateFitnessIndividualAux(F, Moves, (XNext, YNext), V));
        (not(isValidMove(XNext, YNext)), contains((XNext, YNext), Visited)) -> (F is CurrentFitness - 700, calculateFitnessIndividualAux(F, Moves, (XCurrent,YCurrent), Visited));
        (not(isValidMove(XNext, YNext)), not(contains((XNext, YNext), Visited))) -> (F is CurrentFitness - 400, V is [(XNext, YNext)|Visited], calculateFitnessIndividualAux(F, Moves, (XCurrent,YCurrent), V))).
% Testando
% sumVector((1, 5), (0, 1), Coor).
% randomMove(Move).
% randomMoves(Moves, 5).
% buildIndividuo(5, Individuo).
% initPopulation(5, Population, 10).

