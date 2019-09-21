! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: factor-logica ;
IN: factor-logica.test.zebra2

LOGIC-PREDS: existso righto middleo firsto nexto
             houseso zebrao watero ;
LOGIC-VARS: A B L R Hs X Y ;
SYMBOLS: red blue green white yellow ;
SYMBOLS: english swede dane german norwegian ;
SYMBOLS: dog birds zebra cat horse ;
SYMBOLS: coffee tea milk beer water ;
SYMBOLS: prince dunhill pall-mall blend blue-master ;

TUPLE: house color nationality drink smoke pet ;

{ existso A L{ A  _  _  _  _ } } semper 
{ existso A L{ _  A  _  _  _ } } semper
{ existso A L{ _  _  A  _  _ } } semper
{ existso A L{ _  _  _  A  _ } } semper
{ existso A L{ _  _  _  _  A } } semper

{ righto R L L{ L R _ _ _ } } semper
{ righto R L L{ _ L R _ _ } } semper
{ righto R L L{ _ _ L R _ } } semper
{ righto R L L{ _ _ _ L R } } semper
                                        
{ middleo A L{ _ _ A _ _ } } semper

{ firsto A L{ A _ _ _ _ } } semper

{ nexto A B L{ B A _ _ _ } } semper
{ nexto A B L{ _ B A _ _ } } semper
{ nexto A B L{ _ _ B A _ } } semper
{ nexto A B L{ _ _ _ B A } } semper
{ nexto A B L{ A B _ _ _ } } semper
{ nexto A B L{ _ A B _ _ } } semper
{ nexto A B L{ _ _ A B _ } } semper
{ nexto A B L{ _ _ _ A B } } semper

{ houseso Hs X Y } {
    { existso T{ house f red english _ _ _ } Hs }                            ! #2
    { existso T{ house f _ swede _ _ dog } Hs }                              ! #3
    { existso T{ house f _ dane tea _ _ } Hs }                               ! #4
    { righto T{ house f white _ _ _ _ } T{ house f green _ _ _ _ } Hs }      ! #5
    { existso T{ house f green _ coffee _ _ } Hs }                           ! #6
    { existso T{ house f _ _ _ pall-mall birds } Hs }                        ! #7
    { existso T{ house f yellow _ _ dunhill _ } Hs }                         ! #8
    { middleo T{ house f _ _ milk  _ _ } Hs }                                ! #9
    { firsto T{ house f _ norwegian _ _ _ } Hs }                             ! #10
    { nexto T{ house f _ _ _ blend _ } T{ house f _ _ _ _ cat } Hs }         ! #11
    { nexto T{ house f _ _ _ dunhill _ } T{ house f _ _ _ _ horse } Hs }     ! #12
    { existso T{ house f _ _ beer blue-master _ } Hs }                       ! #13
    { existso T{ house f _ german _ prince _ } Hs }                          ! #14
    { nexto T{ house f _ norwegian _ _  _ } T{ house f blue _ _ _ _ } Hs }   ! #15
    { nexto T{ house f _ _ water _ _ } T{ house f _ _ _ blend _ } Hs }       ! #16     
    { existso T{ house f _ X water _ _ } Hs }
    { existso T{ house f _ Y _ _ zebra } Hs }
} si
