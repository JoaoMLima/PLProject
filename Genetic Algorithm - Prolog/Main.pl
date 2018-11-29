:- use_module('GA').
:- use_module('Maze').
:- use_module('Util').
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

%Corrigir isso aqui pra ficar maneiro.
drawIndividual(Maze, individual(_, Moves)) :- mazeSpawn((Xs, Ys)), drawIndividual(Moves, Maze, (Xs, Ys)).

showTitle():- cls, writeln("#####################################################################################################################"),
sleep(0.3),
writeln(".___  ___.      ___      ________   _______         _______.  ______    __      ____    ____  _______ .______      "),
sleep(0.3),
writeln("|   \\/   |     /   \\    |       /  |   ____|       /       | /  __  \\  |  |     \\   \\  /   / |   ____||   _  \\     "),
sleep(0.3),
writeln("|  \\  /  |    /  ^  \\   `---/  /   |  |__         |   (----`|  |  |  | |  |      \\   \\/   /  |  |__   |  |_)  |    "),
sleep(0.3),
writeln("|  |\\/|  |   /  /_\\  \\     /  /    |   __|         \\   \\    |  |  |  | |  |       \\      /   |   __|  |      /     "),
sleep(0.3),
writeln("|  |  |  |  /  _____  \\   /  /----.|  |____    .----)   |   |  `--'  | |  `----.   \\    /    |  |____ |  |\\ \\----."),
sleep(0.3),
writeln("|__|  |__| /__/     \\__\\ /________||_______|   |_______/     \\______/  |_______|    \\__/     |_______|| _| `._____|"),
sleep(0.3),
writeln("\n#####################################################################################################################\n"),
sleep(0.5),
writeln("                                                                                             FINAL EDITION ™"),
sleep(1),
writeln("O SOLUCIONADOR MAIS EFICIENTE DO MERCADO PROPORCIONADO PELO GRUPO:\n"),
sleep(2),
writeln("Wesley: o CYKA BLYAT da recursão"),
sleep(1),
writeln("Eduardo: o MUTANTE com chicungunha"),
sleep(1),
writeln("João Marcos: o GERADOR de caminhos"),
sleep(1),
writeln("Henrique: o FINISHER burocrático"),
sleep(1),
writeln("Flavio: o DEBUGGER quântico").

% Fazer Esse Método
chromossomeSize(ChromossomeSize):- findall(X, freeSpace(X), Xs), length(Xs, ChromossomeSize).

% Calcula o fitness, ordena a população, pega o mais fitness, printa os movimentos do mais fitness, pega o fitness do individuo, verifica se ele solucionou o labirinto. Se sim, termina a recursão.
% se não terminou a recursão, faz o crossover e chama solve de novo.

solve(Maze,Population, individual(Fitness, Moves), ChromossomeSize):- 
    calculateFitnessPopulation(Population, NewPopulation),sortPopulation(NewPopulation,SortedPopulation),
    first(SortedPopulation, individual(FitnessFirst, MovesFirst)), write("Geracao X: "), write(FitnessFirst), writeln(MovesFirst),
    (Fitness < 1000000) -> (crossover(SortedPopulation,PopulationCrossover, ChromossomeSize), solve(Maze,PopulationCrossover,individual(FitnessFirst, MovesFirst), ChromossomeSize));
    Fitness is FitnessFirst; Moves is MovesFirst.

%solve(Maze,Population, Ind, ChromossomeSize, GenNumber):- 
 %   calculateFitnessPopulation(Population, NewPopulation),sortPopulation(NewPopulation,SortedPopulation),
  % first(SortedPopulation, individual(FitnessFirst, MovesFirst)), write("Geracao "), write(GenNumber), write(": "), writeln(MovesFirst),
   % (FitnessFirst < 1000000) -> crossover(SortedPopulation,PopulationCrossover, ChromossomeSize), NextGen is GenNumber +1, solve(Maze,PopulationCrossover,individual(Fitness, Moves), ChromossomeSize,NextGen); Ind is individual(FitnessFirst, MovesFirst).

% myNewSolve(Maze,Population,individual(Fitness,Moves),ChromossomeSize,GenNumber):-
%     calculateFitnessPopulation(Population,FitnessPopulation), sortPopulation(FitnessPopulation,SortedPopulation),
%     first(SortedPopulation, individual(Fitness,Moves)),
%     write("Geracao "), write(GenNumber), write(": "), writeln(Moves),
%     solveAux(Maze,SortedPopulation, Ind ,ChromossomeSize,GenNumber).

% solveAux(Maze,Population,individual(Fitness,Moves), ChromossomeSize,GenNumber):-
%     (Fitness =< 1000000) -> (NextGen is GenNumber + 1, Individual = individual(Fitness,Moves), myNewSolve(Maze, Population,Individual, ChromossomeSize, NextGen));writeln("acabou").

%solve(Maze,Population,Ind,ChromossomeSize,GenNumber):-
%    calculateFitnessPopulation(Population,FitnessPopulation), 
%    sortPopulation(FitnessPopulation,SortedPopulation),
%    first(SortedPopulation, individual(Fitness, Moves)),
%    write("Geracao: "), write(GenNumber), write(": "), writeln(Moves),
%    (Fitness =< 1000000) -> (solve(Maze,SortedPopulation, Ind,ChromossomeSize,(GenNumber + 1)));
%    Ind = individual(Fitness,Moves).

solve(Maze,Population,Ind,ChromossomeSize,GenNumber):-
    calculateFitnessPopulation(Population,FitnessPopulation), 
    sortPopulation(FitnessPopulation,SortedPopulation),
    crossover(SortedPopulation, NewPopulation, ChromossomeSize),
    first(SortedPopulation, individual(Gen, Fitness, Moves)),
    last(SortedPopulation, individual(LGen, LFit, LMov)),
    %getIndex(999, SortedPopulation, individual(LFit, LMov)),
    write("Geracao: "), write(GenNumber), write(": "), write(Gen), write(" - "), write(Fitness), write(" - "), writeln(Moves),
    write("Geracao: "), write(GenNumber), write(": "), write(LGen), write(" - "), write(LFit), write(" - "), writeln(LMov),
    RetractGen is Gen -1,
    retractall(individual(RetractGen, _, _)),
    aux(Maze, NewPopulation, Ind, ChromossomeSize, GenNumber, individual(Fitness, Moves)).

aux(Maze, SortedPopulation, Ind, ChromossomeSize, GenNumber, individual(Fitness, Moves)):- 
    (Fitness =< 1000000) -> (G is GenNumber +1, solve(Maze,SortedPopulation, Ind, ChromossomeSize, G));
    Ind = individual(Fitness, Moves).

readNumber(Number) :- read_line_to_codes(user_input, Codes),
                      string_to_atom(Codes, Atom),
                      atom_number(Atom, Number).
main :-   
    % Pega o tamanho do labirinto, gera o labirinto, calcula o chromossomeSize, inicia uma população de 1000 individuos baseados nesses valores.
    readNumber(Size), maze(Size, Maze), ln, showList(Maze), ln, 
    %(10, Individual), drawIndividual(Maze, Individual),
    ChromossomeSize is 10, initPopulation(ChromossomeSize, Population, 1000),
    % Começa a solucionar o labirinto, dado o labirinto e sua população inicial. Ao fim retorna um individuo que terminou o labirinto.
    solve(Maze,Population, Individuo, ChromossomeSize, 0), sleep(5),
    % Desenha o individuo solucionando o labirinto. Ajeitar o método.
    drawIndividual(Maze,Individuo), writeln(Individuo).

mainTest :- maze(5,Maze), ln, showList(Maze), ln,
        initPopulation(5, Population, 5),
        showList(Population), ln,
        calculateFitnessPopulation(Population, NewPopulation),
        showList(NewPopulation), ln.

%Test
%buildIndividuo(10, Individual), drawIndividual(Individual).