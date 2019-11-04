! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: factlog kernel assocs math ;
IN: factlog.examples.fib

LOGIC-PREDS: fib ;
LOGIC-VARS: F F1 F2 N N1 L ;

{ fib N L[ F F1 F2 | L ] } {
    { (>) N 1 }
    [ [ N of 1 - ] N1 is ]
    { fib N1 L[ F1 F2 | L ] }
    [ [ [ F1 of ] [ F2 of ] bi + ] F is ] !!
} rule

{ fib 0 L[ 0 ] } !! rule

{ fib 1 L[ 1 0 ] } fact
