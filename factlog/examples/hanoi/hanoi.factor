! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: factlog kernel assocs math ;
IN: factlog.examples.hanoi

! hanoi(N) :- move(N, left, centre, right).
! move(0, _, _, _) :- !.
! move(N, A, B, C) :- M is N-1,
!   move(M, A, C, B), % 1
!   inform(A, B),     % 2
!   move(M, C, B, A). % 3
! inform(X,Y) :-
! write([move, disk, from, X, to, Y]), nl.

LOGIC-PREDS: hanoi moveo informo ;
LOGIC-VARS: A B C M N X Y ;
SYMBOLS: left center right ;

{ hanoi N } { moveo N left center right } rule

{ moveo 0 __ __ __ } !! rule

{ moveo N A B C } {
    [ [ N of 1 - ] M is ]
    { moveo M A C B }
    { informo A B }
    { moveo M C B A }
} rule

{ informo X Y } {
    { writeo { "move disk from " X " to " Y } } { nlo }
} rule


