:- module('GA', [
        spaw/2,
        getMove/2,
        makeAMove/3,
        isValidMove/2,
        maze/1,
        buildIndividuo/2,
        initPopulation/3,
        calculateFitnessIndividual/2,
        calculateFitnessPopulation/2,
        concat/3
        ]
).

:- use_module(library(random)).

contains(Element, [Element|_]).
contains(Element, [_|Tail]) :- contains(Element, Tail).

concat([ ],L,L).
concat([X|L1],L2,[X|L3]) :- concat(L1,L2,L3).

subList(_, 0, 0, _).
subList([X|L], 0, End, [X|SL]) :- K is End - 1, subList(L, 0, K, SL).
subList([_|L], Start, End, SL):- K is Start - 1, subList(L, K, End, SL).

individual(fitness, moves).
populationSize(1000).

maze([["#", "#", "#", "#", "#"],
    ["#", " ", " ", " ", "E"],
    ["#", " ", "#", "#", "#"],
    ["#", " ", " ", "S", "#"],
    ["#", "#", "#", "#", "#"]]).

spaw(3, 3).
exit(4, 1).

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

calculateFitnessIndividual(individual(Fitness, Moves), individuo(NewFitness, Moves)) :- spaw(SX, SY), calculateFitnessIndividualAux(Fitness, Moves, (SX,SY), _, NewFitness).

calculateFitnessIndividualAux(CurrentFitness, _, (Xe, Ye), _, NewFitness) :- NewFitness is CurrentFitness * (10**6).
calculateFitnessIndividualAux(CurrentFitness,[],_,_,NewFitness) :- NewFitness is CurrentFitness.
calculateFitnessIndividualAux(CurrentFitness, [M|Moves], (X, Y), Visited, NewFitness) :- 
        makeAMove((X,Y), M, (NewX, NewY)),
        contains((NewX, NewY), Visited) -> ((isValidMove(NewX, NewY)) -> (F is CurrentFitness - 500, calculateFitnessIndividualAux(F, Moves, (NewX, NewY), Visited, NewFitness));
                                                                         (F is CurrentFitness - 700, calculateFitnessIndividualAux(F, Moves, (X,Y), Visited, NewFitness)));
        not(contains((NewX, NewY), Visited)) -> ((isValidMove(NewX, NewY)) -> (F is CurrentFitness - 200, V is [(NewX, NewY)| Visited], calculateFitnessIndividualAux(F, Moves, (NewX, NewY), V, NewFitness));
                                                                              (F is CurrentFitness - 400, V is [(NewX, NewY)| Visited], calculateFitnessIndividualAux(F, Moves, (X,Y), V, NewFitness))).

calculateFitnessPopulation([], _).
calculateFitnessPopulation([I|Individuos], [NewIndividuo|NewPopulation]) :- calculateFitnessIndividual(I, NewIndividuo), calculateFitnessPopulation(Individuos, NewPopulation).



% Testando
% sumVector((1, 5), (0, 1), Coor).
% randomMove(Move).
% randomMoves(Moves, 5).
% buildIndividuo(5, Individuo).
% initPopulation(5, Population, 10).
% buildIndividuo(5, individual(Fitness, Moves)), calculateFitnessIndividualAux(Fitness, Moves, (3,3), Visited, NewFitness).
% buildIndividuo(5, Individuo), calculateFitnessIndividual(Individuo, NewIndividuo).
% initPopulation(5, Population, 5), calculateFitnessPopulation(Population, NewPopulation).
