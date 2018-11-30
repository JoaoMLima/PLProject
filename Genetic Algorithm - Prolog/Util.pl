:- module('Util', [
    contains/3,
    concat/3,
    getIndex/3,
    newRandom/3,
    partOfList/4,
    isEmpty/1,
    revert/2,
    revertAux/3,
    insertAtEnd/3,
    first/2,
    showList/1
]).

contains(_, [], false).
contains(Element, [Element|_], true).
contains(Element, [_|Tail], false) :- contains(Element, Tail, false).

concat([ ],L,L).
concat([X|L1],L2,[X|L3]) :- concat(L1,L2,L3).

getIndex(0, [Head|_], Head).
getIndex(X, [_|Tail], Element) :- K is X - 1, getIndex(K, Tail, Element).

newRandom(Left, Right, Result) :- (Left > Right) -> random_between(Right, Left, Result) ; random_between(Left, Right, Result).

partOfList(0,_,[],[]).
partOfList(0, 0, _, []).
partOfList(0, Right, [H|List], [H|OutputList]) :- R is Right - 1, partOfList(0, R, List, OutputList).
partOfList(Left, Right, [_|List], OutputList) :- L is Left - 1, partOfList(L, Right, List, OutputList).
partOfList(_,_,[],[]).

isEmpty([]).

revert(Moves, NewMoves) :- revertAux(Moves,[],NewMoves).
revertAux([],Acc,Acc).
revertAux([H|T],Acc,R) :- revertAux(T,[H|Acc],R).

insertAtEnd(X,Y,Z) :- append(Y,[X],Z).

first([Head|_], Head).

last([H|[]], H).
last([_|T], L) :- last(T, L).

showList([]).
showList([Head|Tail]) :-
    writeln(Head),
    showList(Tail).