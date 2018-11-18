:- use_module('GA').
:- initialization main.

cls :- write('\e[H\e[2J').
ln :- writeln("").

showList([]).
showList([Head|Tail]) :-
    writeln(Head),
    showList(Tail).

drawAsterisk(X, [L|Line], [L|NewLine]) :- K is X - 1, drawAsterisk(K, Line, NewLine).
drawAsterisk(0, [_|L], ["*"|L]).

drawPoint((X, 0), [L|Maze]) :- drawAsterisk(X, L, NewL), writeln(NewL), showList(Maze).
drawPoint((X, Y), [L|Maze]) :- K is Y - 1, writeln(L), drawPoint((X, K), Maze).

drawIndividual([], _, _).
drawIndividual([M|Moves], Maze, (Xc, Yc)) :-
    makeAMove((Xc, Yc), M, (Xr, Yr)),
    isValidMove(Xr, Yr) -> (cls, drawPoint((Xr, Yr), Maze), sleep(0.5), drawIndividual(Moves, Maze, (Xr, Yr)));
    (cls, drawPoint((Xc, Yc), Maze), sleep(0.5), drawIndividual(Moves, Maze, (Xc, Yc))).

drawIndividual(individual(_, Moves)) :- 
    maze(Maze), spaw(Xs, Ys), drawIndividual(Moves, Maze, (Xs, Ys)).

main :- maze(Maze), ln, showList(Maze), ln,
        initPopulation(5, Population, 5),
        showList(Population), ln,
        calculateFitnessPopulation(Population, NewPopulation),
        showList(NewPopulation), ln.

%Test
%buildIndividuo(10, Individual), drawIndividual(Individual).