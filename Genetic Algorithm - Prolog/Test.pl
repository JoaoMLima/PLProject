:- use_module('GA').
:- use_module('Maze').
:- initialization main.


cls :- write('\e[H\e[2J').
ln :- writeln("").

showList([]).
showList([Head|Tail]) :-
    writeln(Head),
    showList(Tail).

main :- read(Len),
        maze(Len, Maze), ln, showList(Maze), ln,
        mazeExit(E), writeln(E),
        mazeSpawn(S), writeln(S),
        mazeExit(E), writeln(E),
        dist(S, D), writeln(D),
        maze(Len, Maze2), ln, showList(Maze2), ln,
        mazeExit(E2), writeln(E2),
        mazeSpawn(S2), writeln(S2),
        mazeExit(E2), writeln(E2),
        dist(S2, D2), writeln(D2),
        initPopulation(5, Population, 5),
        showList(Population), ln,
        calculateFitnessPopulation(Population, NewPopulation),
        showList(NewPopulation), ln.