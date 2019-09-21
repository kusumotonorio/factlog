! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: factor-logica lists ;
IN: factor-logica.test.zebra
LOGIC-PREDS: houseso neighboro zebrao watero nexto lefto ;
LOGIC-VARS: Hs A B Ls X Y ;
SYMBOLS: red blue green white yellow ;
SYMBOLS: english swede dane norwegian german ;
SYMBOLS: dog cat birds horse zebra ;
SYMBOLS: tea coffee beer milk water ;
SYMBOLS: pall-mall dunhill blue-master prince blend ;
TUPLE: house color nationality drink smoke pet ;

{ houseso Hs X Y } {        
    { (=) Hs L{                                                            ! #1
          T{ house f _ norwegian _ _ _ }                                   ! #10
          T{ house f blue _ _ _ _ }                                        ! #15
          T{ house f _ _ milk _ _ } _ _ } }                                ! #9
    { membero T{ house f red english _ _ _ } Hs }                          ! #2
    { membero T{ house f _ swede _ _ dog } Hs }                            ! #3
    { membero T{ house f _ dane tea _ _ } Hs }                             ! #4
    { lefto T{ house f green _ _ _ _ } T{ house f white _ _ _ _ } Hs }     ! #5
    { membero T{ house f green _ coffee _ _ } Hs }                         ! #6
    { membero T{ house f _ _ _ pall-mall birds } Hs }                      ! #7
    { membero T{ house f yellow _ _ dunhill _ } Hs }                       ! #8
    { nexto T{ house f _ _ _ blend _ } T{ house f _ _ _ _ cat } Hs }       ! #11
    { nexto T{ house f _ _ _ dunhill _ } T{ house f _ _ _ _ horse } Hs }   ! #12
    { membero T{ house f _ _ beer blue-master _ } Hs }                     ! #13
    { membero T{ house f _ german _ prince _ } Hs }                        ! #14
    { nexto T{ house f _ _ water _ _ } T{ house f _ _ _ blend _ } Hs }     ! #16
    { membero T{ house f _ X water _ _ } Hs }
    { membero T{ house f _ Y _ _ zebra } Hs }
} si

{ nexto A B Ls } {
    { appendo _ [ A B _ cons cons ] Ls } vel
    { appendo _ [ B A _ cons cons ] Ls }
} si

{ lefto A B Ls } { appendo _ [ A B _ cons cons ] Ls } si
