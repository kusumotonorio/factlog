! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel locals sequences classes.parser
words.symbol namespaces continuations lexer parser words sets
assocs combinators quotations math hashtables lists classes
classes.tuple prettyprint prettyprint.custom formatting
compiler.units io strings ;

IN: logica

SYMBOL: |     ! cut                  in prolog: !
SYMBOL: _     ! anonymous variable
SYMBOL: vel   ! disjunction, or      in prolog: ;
SYMBOL: non   ! negation             in prolog: not, \+

<PRIVATE

<<
SYMBOL: a-pred

TUPLE: logic-pred name defs ;

: <pred> ( name -- pred )
    logic-pred new
    swap >>name
    { } clone >>defs ;

SINGLETON: LOGIC-VAR
>>

: logic-var? ( obj -- ? )
    dup symbol? [ get LOGIC-VAR? ] [ drop f ] if ; inline

PRIVATE>

<<
SYNTAX: LOGIC-VARS:
    ";"
    [ create-class-in dup define-symbol
      [ LOGIC-VAR swap set-global ]
      \ call
      [ suffix! ] tri@
    ] each-token ;

SYNTAX: LOGIC-PREDS:
    ";"
    [ create-class-in dup define-symbol
      [ dup <pred> swap set-global ]
      \ call
      [ suffix! ] tri@
    ] each-token ;

SYNTAX: L{ \ }
    [ >array sequence>list ] parse-literal ;
>>

<PRIVATE

TUPLE: logic-goal pred args not? ;

: called-args ( args -- args' )
    [ dup callable? [ call( -- term ) ] when ] map ;

:: <goal> ( pred args -- goal )
    pred get args called-args f logic-goal boa ; inline

: normalize ( goal-def/defs -- goal-defs )
    dup | = [ 1array ] [
        dup length 0 > [
            dup first dup symbol? [
                get logic-pred? [ 1array ] when
            ] [ drop ] if
        ] when
    ] if ;

TUPLE: logic-env table ;

: <env> ( -- env ) logic-env new H{ } clone >>table ; inline

:: env-put ( env x pair -- ) pair x env table>> set-at ; inline

:: env-get ( env x -- pair/f ) x env table>> at ; inline

:: env-delete ( env x -- ) x env table>> delete-at ; inline

: env-clear ( env -- ) table>> clear-assoc ; inline

:: dereference ( env! term! -- env' term' )
    t :> loop?!
    f :> p!
    [ term logic-var? loop? and ] [
        env term env-get p!
        p [ p first2 env! term! ] [ f loop?! ] if
    ] while
    env term ;

: list-except-nil? ( obj -- ? ) [ list? ] [ nil? not ] bi and ; inline

SYMBOL: L{

M: cons-state pprint-delims drop \ L{ \ } ;

M:: cons-state >pprint-sequence ( x -- seq ) 
   x [ car ] [ cdr ] bi :> ( x-car x-cdr )
   x-cdr nil? [ x-car 1array ] [
        x-cdr cons-state? [
            x-car 1array x-cdr >pprint-sequence append
        ] [ x-car \ . x-cdr 3array ] if
   ] if ;

M: cons-state pprint* pprint-object ;

PRIVATE>

M:: logic-env at* ( term! env! -- value/f ? )
    env term dereference term! env!
    term {
        { [ dup logic-goal? ] [
              drop term pred>> term args>> env at <goal> t
          ] }
        { [ dup tuple? ] [
              drop
              term [ tuple-slots [ env at ] map ]
              [ class-of slots>tuple ] bi t
          ] }
        { [ dup sequence? ] [
              drop term [ env at ] map t
          ] }
        [ drop term t ]
    } cond ;

<PRIVATE

TUPLE: callback-env env trail ;

: <callback-env> ( env trail -- cb-env ) callback-env boa ;

M:: callback-env at* ( term cb-env -- value/f ? )
    term cb-env env>> at* ;

TUPLE: cut-info cut? ;

C: <cut> cut-info

: cut? ( cut-info -- ? ) cut?>> ; inline

: set-info ( ? cut-info -- ) cut?<< ; inline

: set-info-if-f ( ? cut-info -- )
    dup cut?>> [ 2drop ] [ cut?<< ] if ; inline
 
:: unify* ( x! x-env! y! y-env! trail tmp-env -- success? )
    f :> ret-value!  f :> ret?! f :> ret2?!
    t :> loop?!
    [ loop? ] [
        { { [ x logic-var? ] [
                x-env x env-get :> xp!
                xp not [
                    y-env y dereference y! y-env!
                    x y = x-env y-env eq? and [
                        x-env x { y y-env } env-put
                        x-env tmp-env eq? [
                            { x x-env } trail push
                        ] unless
                    ] unless
                    f loop?!  t ret?!  t ret-value!
                ] [
                    xp first2 x-env! x!
                    x-env x dereference x! x-env!
                ] if
            ] }
          { [ y logic-var? ] [
                x y x! y!  x-env y-env x-env! y-env!
            ] }                 
          [ f loop?! ]
        } cond
    ] while
    
    ret? [
        t ret-value!
         x y [ logic-goal? ] both? [
             x pred>> y pred>> = [
                 x args>> x!  y args>> y!
             ] [
                 f ret-value! t ret2?!
             ] if
         ] when
         ret2? [           
            {
                { [ x y [ tuple? ] both? ] [                      
                      x y [ class-of ] same? [
                          x y [ tuple-slots ] bi@ :> ( x-slots y-slots )
                          0 :> i!  x-slots length 1 - :> stop-i  t :> loop?!
                          [ i stop-i <= loop? and ] [
                              x-slots y-slots [ i swap nth ] bi@ :> ( x-value y-value )
                              x-value x-env y-value y-env trail tmp-env unify* [                           
                                  f loop?!
                                  f ret-value!
                              ] unless
                              i 1 + i!
                          ] while
                      ] [ f ret-value! ] if     
                  ] }                
                { [ x y [ sequence? ] both? ] [
                      x y [ class-of ] same? x y [ length ] same? and [
                          0 :> i!  x length 1 - :> stop-i  t :> loop?!
                          [ i stop-i <= loop? and ] [
                              x y [ i swap nth ] bi@ :> ( x-item y-item )
                              x-item x-env y-item y-env trail tmp-env unify* [
                                  f loop?!
                                  f ret-value!
                              ] unless
                              i 1 + i!
                          ] while
                      ] [ f ret-value! ] if
                  ] }              
                [  x y = ret-value! ]
            } cond
        ] unless
    ] unless
    ret-value ;

:: resolve-body ( body env cut quot: ( -- ) -- success? )
    f :> satisfied!    
    body empty? [
        quot call( -- )
        t satisfied!
    ] [
        body first :> first-goal!
        body rest  :> rest-goals    
        first-goal | = [          ! cut
            rest-goals env cut [ quot call( -- ) ] resolve-body satisfied!
            t cut set-info
        ] [
            first-goal callable? [ 
                first-goal call( -- goal ) first-goal! 
            ] when
            <env> :> d-env!
            f <cut> :> d-cut!            
            t :> loop?!
            first-goal pred>> defs>> :> defs
            0 :> i!  defs length 1 - :> stop-i
            [
                i defs nth [ first ] [ second ] bi :> ( d-head d-body )
                d-cut cut? cut cut? or [ f loop?! ] [
                    V{ } clone :> trail
                    first-goal env d-head d-env trail d-env unify* first-goal not?>> xor [
                        d-body callable? [
                            d-env trail <callback-env> d-body call( cb-env -- ? ) [
                                rest-goals env cut [ quot call( -- ) ] resolve-body satisfied!
                            ] when
                        ] [
                            d-body d-env d-cut
                            [ rest-goals env cut [ quot call( -- ) ] resolve-body satisfied!
                              cut cut? d-cut set-info-if-f ]
                            resolve-body satisfied!
                        ] if
                    ] when
                    trail [ first2 swap env-delete ] each
                    d-env env-clear
                ] if
                i 1 + i!
                loop? i stop-i <= and
            ] loop                
        ] if
    ] if
    satisfied ;

SYMBOL: anonymous(is)
SYMBOL: anonymous(t/f)

:: split-body ( body -- bodies )
    V{ } clone :> bodies
    V{ } clone :> goals!
    body [
        dup vel = [
            drop goals >array bodies push
            V{ } clone goals!
        ] [ goals push ] if
    ] each
    goals empty? [ goals >array bodies push ] unless
    bodies >array ;

SYMBOL: *anonymouse-var-no*

: reset-anonymouse-var-no ( -- )  0 *anonymouse-var-no* set-global ;

: proxy-var-for-'_' ( -- var-symbol )
    [
        *anonymouse-var-no* counter "ANONYMOUSE-VAR-%d_" sprintf
        "logica" create-word dup dup
        define-symbol
        LOGIC-VAR swap set-global
    ] with-compilation-unit ;

: replace-'_' ( before -- after )
    {
        { [ dup _ = ] [ drop proxy-var-for-'_' ] }
        { [ dup sequence? ] [ [ replace-'_' ] map ] }
        { [ dup tuple? ] [
              [ tuple-slots [ replace-'_' ] map ]
              [ class-of slots>tuple ] bi ] }
        [ ]
    } cond ;

PRIVATE>

:: si ( head body -- )
    reset-anonymouse-var-no
    head replace-'_' [ first ] [ rest ] bi <goal> :> head-goal
    body replace-'_' normalize split-body  ! disjunction
    dup empty? [
        head-goal swap 2array head-goal pred>>
        [ swap 1array append ] change-defs drop
    ] [
        [
            [
                f :> negation-goal?!
                {
                    { [ dup array? ] [
                          [ first ] [ rest ] bi <goal> negation-goal? >>not?
                          f negation-goal?!
                      ] }
                    { [ dup callable? ] [
                          call( -- goal ) negation-goal? >>not?
                          f negation-goal?!
                      ] }
                    { [ dup [ t = ] [ f = ] bi or ] [
                          :> t/f
                          V{ } clone :> defs
                          f [ drop t/f ] 2array defs push
                          anonymous(t/f) defs logic-pred boa { } clone <goal>
                          negation-goal? >>not?
                          f negation-goal?!
                      ] }
                    { [ dup non = ] [
                          drop f                           ! dummy
                          t negation-goal?! 
                      ] }
                    { [ dup | = ] [ f negation-goal?! ] }  ! as '|'     
                    [ drop f f negation-goal?! ]           ! dummy
                } cond
            ] map f swap remove :> body-goals
            head-goal body-goals
            2array head-goal pred>> [ swap 1array append ] change-defs drop

        ] each    
    ] if ;

: semper ( head -- ) { } clone si ;

:: voca ( head quot: ( callback-env -- ? ) -- )
    head [ first ] [ rest ] bi <goal> :> head-goal
    head-goal quot 2array head-goal pred>>
    [ swap 1array append ] change-defs drop ;

:: unify ( cb-env x y -- success? )
    cb-env env>> :> env
    x env y env cb-env trail>> env unify* ;

:: (resolve) ( goal-def/defs quot: ( env -- ) -- success? )
    goal-def/defs replace-'_' normalize [
        [ first ] [ rest ] bi <goal>
    ] map :> goals
    <env> :> env
    goals env f <cut> [ env quot call( env -- ) ] resolve-body ;

: resolve ( goal-def/defs quot: ( env -- ) -- ) (resolve) drop ;

: resolve* ( goal-def/defs -- ) [ drop ] resolve ;

:: query ( goal-def/defs -- bindings-array/success? )
    V{ } clone :> bindings-seq
    goal-def/defs normalize
    [| env |
     V{ } clone :> bindings
     env table>> keys [ dup env at 2array bindings push ] each
     bindings >hashtable bindings-seq push ]
    (resolve) :> success?
    bindings-seq >array
    dup empty? [
        drop success?
    ] [    
        dup [ length 1 = ] [ first H{ } = ] bi and [
            drop success?
        ] when
    ] if ;

SYMBOL: anonymous(is)

:: collect-logic-vars ( seq -- vars-array )
    V{ } clone :> vars
    seq [
        { { [ dup logic-var? ] [
                dup vars member? [ drop ] [ vars push ] if 
            ] }
          { [ dup sequence? ] [
                collect-logic-vars [
                    dup vars member? [ drop ] [ vars push ] if
                ] each
            ] }
          [ drop ]
        } cond
    ] each
    vars >array ;

:: is ( quot: ( env -- value ) dist -- goal )
    quot collect-logic-vars
    dup dist swap member? [ dist 1array append ] unless :> args 
    anonymous(is) <pred> :> is-pred
    is-pred args f logic-goal boa :> is-goal
    is-goal [| env | env dist env quot call( env -- value ) unify ]
    2array is-goal pred>> [ swap 1array append ] change-defs drop
    is-pred args f logic-goal boa ;

M: array >list sequence>list ;

    
! Built-in definition -----------------------------------------------------

LOGIC-PREDS: (<) (>) (>=) (=<) (=:=) (=\=) (==) (\==) (=) (\=)
             writeo writenlo nlo
             true false
             membero appendo lengtho conco
;

{ true }  [ drop t ] voca
{ false } [ drop f ] voca

LOGIC-VARS: A_ B_ C_ X_ Y_ Z_ ;

{ (<)   X_ Y_ } [ [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ < ] [ 2drop f ] if ] voca
{ (>)   X_ Y_ } [ [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ > ] [ 2drop f ] if ] voca
{ (>=)  X_ Y_ } [ [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ >= ] [ 2drop f ] if ] voca
{ (=<)  X_ Y_ } [ [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ <= ] [ 2drop f ] if ] voca
{ (=:=) X_ Y_ } [ [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ = ] [ 2drop f ] if ] voca
{ (=\=) X_ Y_ } [ [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ = not ] [ 2drop f ] if ] voca
{ (==)  X_ Y_ } [ [ X_ of ] [ Y_ of ] bi = ] voca
{ (\==) X_ Y_ } [ [ X_ of ] [ Y_ of ] bi = not ] voca

{ (=)   X_ Y_ } [ dup [ X_ of ] [ Y_ of ] bi unify ] voca
{ (\=)  X_ Y_ } [ dup [ X_ of ] [ Y_ of ] bi unify not ] voca


{ writeo X_ } [
    X_ of [ dup string? [ printf ] [ pprint ] if ] each t
] voca

{ writenlo X_ } [
    X_ of [ dup string? [ printf ] [ pprint ] if ] each nl t
] voca

{ nlo } [ drop nl t ] voca


{ membero X_ [ X_ Z_ cons ] } semper
{ membero X_ [ Y_ Z_ cons ] } { membero X_ Z_ } si

{ appendo +nil+ A_ A_ } semper
{ appendo [ A_ X_ cons ] Y_ [ A_ Z_ cons ] } {
    { appendo X_ Y_ Z_ }
} si


LOGIC-VARS: Tail_ N_ N1_ ;

{ lengtho +nil+ 0 } semper
{ lengtho [ _ Tail_ cons ] N_ } {
    { lengtho Tail_ N1_ }
    [ [ N1_ of 1 + ] N_ is ]
} si


LOGIC-VARS: L_ L1_ L2_ L3_ ;

{ conco +nil+ L_ L_ } semper
{ conco [ X_ L1_ cons ] L2_ [ X_ L3_ cons ] } {
    { conco L1_ L2_ L3_ }
} si
