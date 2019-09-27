! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: logica lists arrays ;
IN: logica.test.zebra-short

! Do the same as this Prolog program
!
! neighbor(L,R,[L,R|_]).
! neighbor(L,R,[_|Xs]) :- neighbor(L,R,Xs).
!
! zebra(X) :- Street = [H1,H2,H3],
!             member(house(red,english,_), Street),
!             member(house(_,spanish,dog), Street),
!             neighbor(house(_,_,cat), house(_,japanese,_), Street),
!             neighbor(house(_,_,cat), house(blue,_,_), Street),
!             member(house(_,X,zebra),Street).

LOGIC-PREDS: neighboro zebrao ;
LOGIC-VARS: L R X Xs H1 H2 H3 Street ;
SYMBOLS: red blue ;
SYMBOLS: english spanish japanese ;
SYMBOLS: dog cat zebra ;
TUPLE: house color nationality pet ;

{ neighboro L R [ L R _ cons cons ] } semper
{ neighboro L R [ _ Xs cons ] } { neighboro L R Xs } si

{ zebrao X } {
   { (=) Street [ { H1 H2 H3 } >list ] }
   { membero [ T{ house f red english _ } ] Street }
   { membero [ T{ house f _ spanish dog } ] Street }
   { neighboro [ T{ house f _ _ cat } ] [ T{ house f _ japanese _ } ]  Street }
   { neighboro [ T{ house f _ _ cat } ] [ T{ house f blue _ _ } ] Street }
   { membero [ T{ house f _ X zebra } ] Street }
} si

