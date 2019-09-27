! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: logica lists kernel assocs math ;
IN: logica.test.fib

LOGIC-VARS: F F1 F2 N N1 N2 L A ;
LOGIC-PREDS: fib F_is_F1+F2 N2_is_N-1 ;

{ fib N [ F F1 F2 L cons cons cons ] } {
    { (>) N 1 }
    [ [ N of 1 - ] N2 is ] 
    { fib N2 [ F1 F2 L cons cons ] }
    [ [ [ F1 of ] [ F2 of ] bi + ] F is ] |
} si
{ fib 0 L{ 0 } } | si
{ fib 1 L{ 1 0 } } semper

