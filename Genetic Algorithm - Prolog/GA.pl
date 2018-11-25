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

individual(fitness, moves).
populationSize(1000).

getIndex(0, [Head|_], Head).
getIndex(X, [_|Tail], Element) :- K is X - 1, getIndex(K, Tail, Element).

insertAtEnd(X,Y,Z) :- append(Y,[X],Z).

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

groups([[0, 10],[11, 250],[251, 400],[401, 750],[751,1000]]).
groupsChance([0.5, 0.25, 0.15, 0.08, 0.02]).

initGroupsList(GroupList) :- initGroupsList_(_,0,GroupList).
initGroupsList_(GroupList,5, GroupList).
initGroupsList_(GroupList, N, Output) :- groupsChance(G), getIndex(N,G,Chance), C is round(Chance*100),
                                 repl(N,C,List), concat(GroupList, List, L), K is N + 1,
                                 initGroupsList_(L, K, Output).

repl(X, N, L) :-
        length(L, N),
        maplist(=(X), L).

crossover(Population, NewPopulation, ChromossomeSize) :- initGroupsList(GroupList), crossOver_(Population, ChromossomeSize, GroupList, NewPopulation, 0).
        
crossOver_(_,_,_,[],1000).
crossOver_(Population, ChromossomeSize, GroupList, [Son|NewPopulation], N) :- groups(Groups),
                                    random_between(0, 99, Rand1), getIndex(Rand1, GroupList, Group1), getIndex(Group1, Groups, [L1, L2]),
                                    random_between(0, 99, Rand2), getIndex(Rand2, GroupList, Group2), getIndex(Group2, Groups, [R1, R2]),
                                    newRandom(L1, R1, RandDaddy), getIndex(RandDaddy, Population, Daddy),
                                    newRandom(L2, R2, RandMommy), getIndex(RandMommy, Population, Mommy),
                                    crossOverIndividual(ChromossomeSize, Daddy, Mommy, Son),
                                    K is N + 1,
                                    crossOver_(Population, ChromossomeSize, GroupList, NewPopulation, K).

newRandom(Left, Right, Result) :- (Left > Right) -> random_between(Right, Left, Result) ; random_between(Left, Right, Result).


coherentMoves("U", ["U","L","R"]).
coherentMoves("D", ["D","L","R"]).
coherentMoves("R", ["R","D","U"]).
coherentMoves("L", ["L","D","U"]).


crossOverIndividual(ChromossomeSize, individual(_,MovesMommy), individual(_,MovesDaddy), CompletedSon) :-
        random_between(0,1,Rand),
        (Rand =:= 0) -> crossOverIndividual_(ChromossomeSize, MovesMommy, MovesDaddy, CompletedSon);
        crossOverIndividual_(ChromossomeSize, MovesDaddy, MovesMommy, CompletedSon).

crossOverIndividual_(ChromossomeSize, MovesMommy, MovesDaddy, CompletedSon) :-
        CS is ChromossomeSize - 1, random_between(1, CS, CrossOverPoint), coMommy(CrossOverPoint, MovesMommy, MommysSon, StoppingPoint, Last),
        addCoherentMoves(MommysSon, Last, COMommysSon), partOfList(StoppingPoint, CS, MovesDaddy, DaddysSon),
        append(COMommysSon, DaddysSon, CompletedSon). 

coMommy(1,[M|_],[M],1,M).
coMommy(_,[M],[M],1,M).
coMommy(CrossOverPoint, [M|MovesMommy], [M|MommysSon], StoppingPoint, Last) :-
        K is CrossOverPoint - 1, coMommy(K, MovesMommy, MommysSon, S, L), StoppingPoint is 1 + S, string_codes(Last,L).

addCoherentMoves(Son, Last, CMSon) :- coherentMoves(Last, CM), random_between(0, 2, Rand), getIndex(Rand, CM, CoMove), insertAtEnd(CoMove, Son, CMSon).



partOfList(0,_,[],[]).
partOfList(0, 0, _, []).
partOfList(0, Right, [H|List], [H|OutputList]) :- R is Right - 1, partOfList(0, R, List, OutputList).
partOfList(Left, Right, [_|List], OutputList) :- L is Left - 1, partOfList(L, Right, List, OutputList).
partOfList(_,_,[],[]).

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
%coDaddy(CrossOverPoint, MovesDaddy, StoppingPoint, CompletedSon) :- 
%coMommy(3, ["U", "L", "L", "D", "R"], Son, Stop, Last).
%coMommy(4, ["U", "L", "L", "D", "R"], Son, Stop, Last).
%addCoherentMoves(["U", "L", "L", "D", "R"], "R", CMSon).
%coMommy(3, ["U", "L", "L", "D", "R"], Son, StoppingPoint).
%crossOverIndividual(5,individual(_,["U", "L", "L", "D", "R"]), individual(_,["D", "R", "U", "L", "U"]), Son).
%initPopulation(5, Population, 1000), crossover(Population, NewPopulation, 5).