! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: logica ;
IN: logica.examples.zebra2

LOGIC-PREDS: existso righto middleo firsto nexto
             houseso zebrao watero ;
LOGIC-VARS: A B L R Hs X Y ;
SYMBOLS: red blue green white yellow ;
SYMBOLS: english swede dane german norwegian ;
SYMBOLS: dog birds zebra cat horse ;
SYMBOLS: coffee tea milk beer water ;
SYMBOLS: prince dunhill pall-mall blend blue-master ;

TUPLE: house color nationality drink smoke pet ;

{ existso A LL{ A  __  __  __  __ } } semper
{ existso A LL{ __  A  __  __  __ } } semper
{ existso A LL{ __  __  A  __  __ } } semper
{ existso A LL{ __  __  __  A  __ } } semper
{ existso A LL{ __  __  __  __  A } } semper

{ righto R L LL{ L R __ __ __ } } semper
{ righto R L LL{ __ L R __ __ } } semper
{ righto R L LL{ __ __ L R __ } } semper
{ righto R L LL{ __ __ __ L R } } semper

{ middleo A LL{ __ __ A __ __ } } semper

{ firsto A LL{ A __ __ __ __ } } semper

{ nexto A B LL{ B A __ __ __ } } semper
{ nexto A B LL{ __ B A __ __ } } semper
{ nexto A B LL{ __ __ B A __ } } semper
{ nexto A B LL{ __ __ __ B A } } semper
{ nexto A B LL{ A B __ __ __ } } semper
{ nexto A B LL{ __ A B __ __ } } semper
{ nexto A B LL{ __ __ A B __ } } semper
{ nexto A B LL{ __ __ __ A B } } semper

{ houseso Hs X Y } {
    { existso T{ house f red english __ __ __ } Hs }                               ! #2
    { existso T{ house f __ swede __ __ dog } Hs }                                 ! #3
    { existso T{ house f __ dane tea __ __ } Hs }                                  ! #4
    { righto T{ house f white __ __ __ __ } T{ house f green __ __ __ __ } Hs }    ! #5
    { existso T{ house f green __ coffee __ __ } Hs }                              ! #6
    { existso T{ house f __ __ __ pall-mall birds } Hs }                           ! #7
    { existso T{ house f yellow __ __ dunhill __ } Hs }                            ! #8
    { middleo T{ house f __ __ milk  __ __ } Hs }                                  ! #9
    { firsto T{ house f __ norwegian __ __ __ } Hs }                               ! #10
    { nexto T{ house f __ __ __ blend __ } T{ house f __ __ __ __ cat } Hs }       ! #11
    { nexto T{ house f __ __ __ dunhill __ } T{ house f __ __ __ __ horse } Hs }   ! #12
    { existso T{ house f __ __ beer blue-master __ } Hs }                          ! #13
    { existso T{ house f __ german __ prince __ } Hs }                             ! #14
    { nexto T{ house f __ norwegian __ __  __ } T{ house f blue __ __ __ __ } Hs } ! #15
    { nexto T{ house f __ __ water __ __ } T{ house f __ __ __ blend __ } Hs }     ! #16
    { existso T{ house f __ X water __ __ } Hs }
    { existso T{ house f __ Y __ __ zebra } Hs }
} si

