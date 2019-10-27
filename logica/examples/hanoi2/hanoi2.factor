! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: logica lists sequences assocs formatting ;
IN: logica.examples.hanoi2

LOGIC-PREDS: hanoi write-move ;
LOGIC-VARS: A B C X Y Z ;

{ write-move X } [ X of [ printf ] each t ] voca

{ hanoi LL{ } A B C } semper

{ hanoi LL{ X | Y } A B C } {
    { hanoi Y A C B }
    { write-move { "move " X " from " A " to " B "\n" } }
    { hanoi Y C B A }
} si
