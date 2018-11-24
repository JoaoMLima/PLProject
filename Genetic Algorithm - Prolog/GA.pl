:- module('GA', [
        getMove/2,
        makeAMove/3,
        isValidMove/2,
        buildIndividuo/2,
        initPopulation/3,
        calculateFitnessIndividual/2,
        calculateFitnessPopulation/2,
        concat/3
        ]
).
:- use_module('Maze').

:- use_module(library(random)).

contains(_, [], false).
contains(Element, [Element|_], true).
contains(Element, [_|Tail], false) :- contains(Element, Tail, false).

concat([ ],L,L).
concat([X|L1],L2,[X|L3]) :- concat(L1,L2,L3).

subList(_, 0, 0, _).
subList([X|L], 0, End, [X|SL]) :- K is End - 1, subList(L, 0, K, SL).
subList([_|L], Start, End, SL):- K is Start - 1, subList(L, K, End, SL).

individual(fitness, moves).
populationSize(1000).



getIndex(0, [Head|_], Head).
getIndex(X, [_|Tail], Element) :- K is X - 1, getIndex(K, Tail, Element).



makeAMove(Pos, Direction, Result) :- getMove(Direction, CoorMove), sumVector(Pos, CoorMove, Result).
isValidMove(Pos) :- freeSpace(Pos).
isValidMove(Pos, true) :- freeSpace(Pos).
isValidMove(_, false).

getMove("U", (0, -1)).
getMove("D", (0, 1)).
getMove("L", (-1, 0)).
getMove("R", (1, 0)).
direction(0, "U").
direction(1, "D").
direction(2, "L").
direction(3, "R").

randomMove(Move) :- random_between(0, 3, Rand), direction(Rand, Move).

randomMoves([Move], 1) :- randomMove(Move).
randomMoves([M|RandMoves], Len) :- randomMove(M), K is Len - 1, randomMoves(RandMoves, K).

buildIndividuo(ChromossomeSize, individual(Fitness, Moves)) :- Fitness is 10**6, randomMoves(Moves, ChromossomeSize).

initPopulation(ChromossomeSize, [Individuo], 1) :- buildIndividuo(ChromossomeSize, Individuo).
initPopulation(ChromossomeSize, [I|Individuos], Len) :- buildIndividuo(ChromossomeSize, I), K is Len - 1, initPopulation(ChromossomeSize, Individuos, K).

calculateFitnessIndividual(individual(Fitness, Moves), individuo(NewFitness, Moves)) :- mazeSpawn(Pos), calculateFitnessIndividualAux(Fitness, Moves, Pos, _, NewFitness).

calculateFitnessIndividualAux(CurrentFitness, _, Pos, _, NewFitness) :- mazeExit(Pos), NewFitness is CurrentFitness * (10**6).
calculateFitnessIndividualAux(CurrentFitness,[],_,_,CurrentFitness).
calculateFitnessIndividualAux(CurrentFitness, [M|Moves], Pos, Visited, NewFitness) :-
        makeAMove(Pos, M, NewPos),
        verifyMove(NewPos, Visited, Result),
        ((Result == 1, F is CurrentFitness - 500, calculateFitnessIndividualAux(F, Moves, NewPos, Visited, NewFitness));
        (Result == 2, F is CurrentFitness - 700, calculateFitnessIndividualAux(F, Moves, Pos, Visited, NewFitness));
        (Result == 3, F is CurrentFitness - 200, calculateFitnessIndividualAux(F, Moves, NewPos, [NewPos|Visited], NewFitness));
        (Result == 4, F is CurrentFitness - 400, calculateFitnessIndividualAux(F, Moves, Pos, [NewPos|Visited], NewFitness))).

calculateFitnessPopulation([], _).
calculateFitnessPopulation([I|Individuos], [NewIndividuo|NewPopulation]) :- calculateFitnessIndividual(I, NewIndividuo), calculateFitnessPopulation(Individuos, NewPopulation).

verifyMove(Pos, Visited, Result) :-
        contains(Pos, Visited, C1),
        isValidMove(Pos, C2),
        ((C1, C2) -> (Result is 1);
        (C1, not(C2)) -> (Result is 2);
        (not(C1), C2) -> (Result is 3);
        (not(C1), not(C2)) -> (Result is 4)).

% Testando
% sumVector((1, 5), (0, 1), Coor).
% randomMove(Move).
% randomMoves(Moves, 5).
% buildIndividuo(5, Individuo).
% initPopulation(5, Population, 10).
% buildIndividuo(5, individual(Fitness, Moves)), calculateFitnessIndividualAux(Fitness, Moves, (3,3), Visited, NewFitness).
% buildIndividuo(5, Individuo), calculateFitnessIndividual(Individuo, NewIndividuo).
% initPopulation(5, Population, 5), calculateFitnessPopulation(Population, NewPopulation).
%calculateFitnessIndividualAux(1000000, ["D", "R", "U", "L", "U"], (3, 3), Visited, NewFitness).
%calculateFitnessIndividualAux(1000000, ["L","L","U","U","R","R","R"], (3, 3), Visited, NewFitness).