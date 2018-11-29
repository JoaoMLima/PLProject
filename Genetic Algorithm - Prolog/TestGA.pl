:- use_module('GA').

ln :- writeln("").
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
