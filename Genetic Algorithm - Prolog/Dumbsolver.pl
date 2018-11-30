:- module('Dumbsolver', [
    dumbSolve/2
    ]
).
:- use_module('GA').
:- use_module('Maze').
:- use_module('Util').
:- use_module('Display').
:- use_module('Main').


dumbSolve(0, Individuo) :- 
    chromossomeSize(ChromossomeSize),initPopulation(ChromossomeSize, Population, 1000),
    calculateFitnessPopulation(Population, CalculatedPopulation),
    first(CalculatedPopulation, individual(Gen, Fitness, Moves)),
    write("Geração "), write(0), write(":"), write(Fitness), writeln(Moves),
    FirstBestIndividual = individual(Gen, Fitness, Moves),
    ((Fitness > 1000000), Individuo = FirstBestIndividual; dumbSolve(1,Individuo)).
dumbSolve(1, Individuo) :-
    chromossomeSize(ChromossomeSize),initPopulation(ChromossomeSize, Population, 1000),
    calculateFitnessPopulation(Population, CalculatedPopulation),
    first(CalculatedPopulation, individual(Gen, Fitness, Moves)),
    write("Geração "), write(1), write(":"), write(Fitness), writeln(Moves),
    FirstBestIndividual = individual(Gen, Fitness, Moves),
    ((Fitness > 1000000), Individuo = FirstBestIndividual; dumbSolve(2,Individuo)).
dumbSolve(2, Individuo) :-
    chromossomeSize(ChromossomeSize),initPopulation(ChromossomeSize, Population, 1000),
    calculateFitnessPopulation(Population, CalculatedPopulation),
    first(CalculatedPopulation, individual(Gen, Fitness, Moves)),
    write("Geração "), write(2), write(":"), write(Fitness), writeln(Moves),
    FirstBestIndividual = individual(Gen, Fitness, Moves),
    ((Fitness > 1000000), Individuo = FirstBestIndividual; dumbSolve(3,Individuo)).
dumbSolve(3, Individuo) :-
    chromossomeSize(ChromossomeSize),initPopulation(ChromossomeSize, Population, 1000),
    calculateFitnessPopulation(Population, CalculatedPopulation),
    first(CalculatedPopulation, individual(Gen, Fitness, Moves)),
    write("Geração "), write(3), write(":"), write(Fitness), writeln(Moves),
    FirstBestIndividual = individual(Gen, Fitness, Moves),
    ((Fitness > 1000000), Individuo = FirstBestIndividual; dumbSolve(4,Individuo)).
dumbSolve(4, Individuo) :-
    chromossomeSize(ChromossomeSize),initPopulation(ChromossomeSize, Population, 1000),
    calculateFitnessPopulation(Population, CalculatedPopulation),
    first(CalculatedPopulation, individual(Gen, Fitness, Moves)),
    write("Geração "), write(4), write(":"), write(Fitness), writeln(Moves),
    FirstBestIndividual = individual(Gen, Fitness, Moves),
    Individuo = FirstBestIndividual, sleep(3).