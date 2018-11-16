:- use_module('GA').
:- initialization main.

ln :- writeln("").

showList([]).
showList([I|Individual]) :-
    writeln(I),
    showList(Individual).

main :- maze(Maze), ln, showList(Maze), ln,
        initPopulation(5, Population, 5),
        showList(Population), ln,
        calculateFitnessPopulation(Population, NewPopulation),
        showList(NewPopulation), ln.
