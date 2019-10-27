! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: logica assocs sequences kernel math
locals formatting io ;
IN: logica.examples.money

LOGIC-PREDS: sumo sum1o digitsumo delo donaldo moneyo ;
LOGIC-VARS: S E N D M O R Y A L G B T
            N1 N2 C C1 C2 D1 D2 L1
            Digits Digs Digs1 Digs2 Digs3 ;

{ sumo N1 N2 N } {
    { sum1o N1 N2 N 0 0 L[ 0 1 2 3 4 5 6 7 8 9 ] __ }
} si

{ sum1o L[ ] L[ ] L[ ] 0 0 Digits Digits } semper
{ sum1o L[ D1 | N1 ] L[ D2 | N2 ] L[ D | N ] C1 C Digs1 Digs } {
    { sum1o N1 N2 N C1 C2 Digs1 Digs2 }
    { digitsumo D1 D2 C2 D C Digs2 Digs }
} si

{ digitsumo D1 D2 C1 D C Digs1 Digs } {
    { delo D1 Digs1 Digs2 }
    { delo D2 Digs2 Digs3 }
    { delo D Digs3 Digs }
    [ [ [ D1 of ] [ D2 of ] [ C1 of ] tri + + ] S is ]
    [ [ S of 10 mod ] D is ]
    [ [ S of 10 / >integer ] C is ]
} si

{ delo A L L } { { nonvaro A } !! } si
{ delo A L[ A | L ] L } semper
{ delo A L[ B | L ] L[ B | L1 ] } { delo A L L1 } si

{ moneyo
  L[ 0 S E N D ]
  L[ 0 M O R E ]
  L[ M O N E Y ]
} semper

{ donaldo
  L[ D O N A L D ]
  L[ G E R A L D ]
  L[ R O B E R T ]
} semper

:: S-and-M-can't-be-zero ( seq -- seq' )
    seq [| hash |
         1 hash N1 of list>array nth 0 = not
         1 hash N2 of list>array nth 0 = not and
    ] filter ;

:: print-puzzle ( hash-array -- )
    hash-array
    [| hash |
     "   " printf hash N1 of list>array [ "%d " printf ] each nl
     "+  " printf hash N2 of list>array [ "%d " printf ] each nl
     "----------------" printf nl
     "   " printf hash N  of list>array [ "%d " printf ] each nl nl
    ] each ;
