:- module('Maze', [
    maze/2,
    sumVector/3,
    mazeExit/1,
    freeSpace/1,
    mazeSpawn/1
    ]).

%Auxiliar
sumVector((X1, Y1), (X2, Y2), (X3, Y3)) :- X3 is X1 + X2, Y3 is Y1 + Y2.
move(0, (-2, 0)).
move(1, (2, 0)).
move(2, (0, -2)).
move(3, (0, 2)).
abs(A, B) :- (A >= 0, B is A); B is -A.
swap(0, C, C).
swap(1, (X, Y), (Y, X)).

%MazeInfo
isValid((X, Y)) :- lengthMaze(Len), X >= 0, X < Len, Y >= 0, Y < Len.
icon(Pos, Ch) :- (mazeExit(Pos), Ch = 'E');
    (mazeSpawn(Pos), Ch = 'S'); (freeSpace(Pos), Ch = ' '); Ch = '#'.
isAWall(Pos) :- isValid(Pos), icon(Pos, Icon), Icon =:= "#".




%Aleatoriedades
getMoves([], []).
getMoves([H|T], [Mv|RestMvs]) :- getMoves(T, RestMvs), move(H, Mv).
randomFourMoves(Mvs) :- random_permutation([0, 1, 2, 3], List), getMoves(List, Mvs).


%Maze recursions
setExit() :- lengthMaze(Len), HalfLen is (Len - 1) / 2, random(0, HalfLen, R1), random(0, 2, R2), random(0, 2, R3),
    Coord1 is R1 * 2 + 1, Coord2 is R2 * (Len - 1), T1 is Coord2 - 1, abs(T1, Coord3), 
    swap(R3, (Coord1, Coord2), E), swap(R3, (Coord1, Coord3), R), assert(mazeExit(E)), assert(root(R)).

setSpawn() :- lengthMaze(Len), HalfLen is (Len - 1) / 2, random(0, HalfLen, R1), random(0, HalfLen, R2),
    Coord1 is R1 * 2 + 1, Coord2 is R2 * 2 + 1, assert(mazeSpawn((Coord1, Coord2))).

mazeGen() :- setExit(), setSpawn(), mazeExit(E), root(R), assert(freeSpace(E)), assert(freeSpace(R)), recMazeGen(R).
recMazeGen(Pos) :- randomFourMoves(Mvs), recurCallerMazeGen(Pos, Mvs).

recurCallerMazeGen(_, []) .
recurCallerMazeGen(P, [(X1, Y1)|T]) :- (X2 is X1 / 2, Y2 is Y1 / 2,
    sumVector(P, (X1, Y1), Next), sumVector(P, (X2, Y2), Intermed), isValid(Next),  (\+ freeSpace(Next)),
    assert(freeSpace(Next)), assert(freeSpace(Intermed)), recMazeGen(Next), recurCallerMazeGen(P, T)); recurCallerMazeGen(P, T).


maze(Len, M) :- assert(lengthMaze(Len)), mazeGen(), getMazeLine(0, M).

getMazeLine(I, []) :- lengthMaze(Len), I >= Len.
getMazeLine(I, M) :- NextI is I + 1, getMazeLine(NextI, NextM), getMazeCol(I, 0, L), M = [L|NextM].
getMazeCol(_, J, []) :- lengthMaze(Len), J >= Len.
getMazeCol(I, J, L) :- NextJ is J + 1, getMazeCol(I, NextJ, NextL), icon((I, J), Ch), L = [Ch|NextL].
