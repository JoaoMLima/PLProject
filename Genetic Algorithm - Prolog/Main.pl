:- use_module('GA').
:- use_module('Maze').
:- use_module('Util').
:- use_module('Display').
:- use_module(library(statistics)).
:- set_prolog_stack(local,  limit(2 000 000 000)).
:- set_prolog_stack(global,  limit(1 000 000 000)).
:- initialization main.

% Fazer Esse Método
chromossomeSize(ChromossomeSize):- findall(X, freeSpace(X), Xs), length(Xs, ChromossomeSize).

% Calcula o fitness, ordena a população, pega o mais fitness, printa os movimentos do mais fitness, pega o fitness do individuo, verifica se ele solucionou o labirinto. Se sim, termina a recursão.
% se não terminou a recursão, faz o crossover e chama solve de novo.

applyMethodToThePopulation(Population, BestIndividual, ChromossomeSize) :-
    crossover(Population, NewPopulation, ChromossomeSize),
    calculateFitnessPopulation(Population, CalculatedPopulation),
    first(CalculatedPopulation, BestIndividualGen),
    BestIndividualGen = individual(Gen, Fitness, Moves),
    write("Geração "), write(Gen), write(":"), write(Fitness), writeln(Moves),
    ((Fitness < 1000000) -> applyMethodToThePopulation(NewPopulation, BestIndividual, ChromossomeSize);
    BestIndividual = BestIndividualGen).

solve(Population, BestIndividual, ChromossomeSize) :-
    calculateFitnessPopulation(Population, CalculatedPopulation),
    first(CalculatedPopulation, individual(Gen, Fitness, Moves)),
    FirstBestIndividual = individual(Gen, Fitness, Moves),
    write("Geração "), write(Gen), write(":"), write(Fitness), writeln(Moves),
    ((Fitness > 1000000) -> BestIndividual = FirstBestIndividual;
    applyMethodToThePopulation(CalculatedPopulation, BestIndividual, ChromossomeSize)).

main :-   
    % Pega o tamanho do labirinto, gera o labirinto, calcula o chromossomeSize, inicia uma população de 1000 individuos baseados nesses valores.
    readNumber(Size), maze(Size, Maze), ln, showList(Maze), ln, 
    chromossomeSize(ChromossomeSize), initPopulation(ChromossomeSize, Population, 1000),
    solve(Population, Individuo, ChromossomeSize), sleep(5),
    mazeSpawn(S), drawIndividual(Maze,S,Individuo), writeln(Individuo).

mainTest :- maze(5,Maze), ln, showList(Maze), ln,
        initPopulation(5, Population, 5),
        showList(Population), ln,
        calculateFitnessPopulation(Population, NewPopulation),
        showList(NewPopulation), ln.

%Test
%buildIndividuo(10, Individual), drawIndividual(Individual).