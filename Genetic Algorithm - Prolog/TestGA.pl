:- use_module('GA').
:- use_module('Util').

ln :- writeln("").
cls :- write('\e[H\e[2J').
showMove(Msg, Moves) :- atomic_list_concat(Moves, ',', MC), string_concat(Msg, MC, MovesConcat), writeln(MovesConcat).

main :-

    Mommy = individual(MommyGen,MommyFitness,MommyMoves),
    Daddy = individual(DaddyGen,DaddyFitness,DaddyMoves),
    individual(MommyGen,MommyFitness,MommyMoves) = individual(1,1000000, ["U","U","L","L","D","D"]),
    individual(DaddyGen,DaddyFitness,DaddyMoves) = individual(1,1000000, ["D","R","R","R","D","U"]),

    writeln("Test FindGroup: "),
    findGroup(L1, L2),
    string_concat("Group1: ", L1, Out1),
    string_concat("Group2: ", L2, Out2),
    writeln(Out1), writeln(Out2), ln,

    writeln("Test Crossover Mommy: "),
    coMommy(3,MommyMoves,Son,StoppingPoint,Last),
    showMove("Mommy Moves: ", MommyMoves),
    showMove("Mommy's Son Moves: ", Son),
    string_concat("Stopping Point: ", StoppingPoint, SP),
    string_concat("Last Move: ", Last, L),
    writeln(SP), writeln(L), ln,

    writeln("Test Add CoherentMoves: "),
    addCoherentMoves(Son, Last, AddedCM),
    showMove("Son Moves: ", Son),
    showMove("Son Moves Added CM: ", AddedCM),ln,

    writeln("Test Crossover Individual Aux: "),
    crossOverIndividual_(6, MommyMoves, DaddyMoves, CompletedSon),
    showMove("Mommy Moves: ", MommyMoves),
    showMove("Daddy Moves: ", DaddyMoves),
    showMove("Son Moves: ", CompletedSon), ln,

    writeln("Test Crossover Individual: "),
    crossOverIndividual(6, Daddy, Mommy, NewCompletedSon),
    showMove("Mommy Moves: ", MommyMoves),
    showMove("Daddy Moves: ", DaddyMoves),
    showMove("Son Moves: ", NewCompletedSon), ln,

    writeln("Test Mutation: "),
    mutation(MommyMoves, Mutant),
    showMove("Normal Moves: ", MommyMoves),
    showMove("Mutant Moves: ", Mutant).


testDrawIndividual :- mazetest(Maze), Moves = ["U","U","D","D","L","L","L","U","U","R","R"],
    drawIndividual(Maze, (3,3), individual(_,_,Moves)), showMove("", Moves).

mazetest([["#", "#", "#", "#", "#"],
          ["#", " ", " ", " ", "E"],
          ["#", " ", "#", "#", "#"],
          ["#", " ", " ", "S", "#"],
          ["#", "#", "#", "#", "#"]]).

sumVector((X1,Y1), (X2,Y2), (X3, Y3)) :- X3 is X1 + X2, Y3 is Y1 + Y2.

icon(X, Y, Icon) :- mazetest(Maze), getIndex(X, Maze, Line), getIndex(Y, Line, Icon).
isValid(X, Y) :- mazetest(Maze), length(Maze, Len), X < Len, Y < Len.
isAWall(X, Y) :- isValid(X, Y), icon(X, Y, Icon), Icon =:= "#".
makeAMove_((X, Y), Direction, Result) :- getMove(Direction, CoorMove), sumVector((X, Y), CoorMove, Result).
isValidMove_((X, Y)) :- isValid(X, Y), not(isAWall(X, Y)).

drawAsterisk(Y, [L|Line], [L|NewLine]) :- K is Y - 1, drawAsterisk(K, Line, NewLine).
drawAsterisk(0, [_|L], ["*"|L]).

drawPoint((0, Y), [L|Maze]) :- drawAsterisk(Y, L, NewL), writeln(NewL), showList(Maze).
drawPoint((X, Y), [L|Maze]) :- K is X - 1, writeln(L), drawPoint((K, Y), Maze).

drawIndividual_(_,_,[]).
drawIndividual_(Maze, S, [M|Moves]) :-
    makeAMove_(S, M, Result),
    (isValidMove_(Result), cls, drawPoint(Result, Maze), sleep(0.5), drawIndividual_(Maze, Result, Moves));
    (cls, drawPoint(S, Maze), sleep(0.5), drawIndividual_(Maze, S, Moves)).

drawIndividual(Maze, Spawn, individual(_,_,Moves)) :- drawIndividual_(Maze, Spawn, Moves).