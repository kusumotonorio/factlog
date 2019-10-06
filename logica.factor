! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel locals sequences classes.parser
words.symbol namespaces lexer parser words sets assocs
combinators quotations math hashtables lists classes
classes.tuple prettyprint prettyprint.custom formatting
compiler.units sequences.generalizations io strings ;

IN: logica

<<
SYMBOL: !!    ! cut operator         in prolog: !
SYMBOL: __    ! anonymous variable   in prolog: _
SYMBOL: ||    ! head-tail separator  in prolog: |
SYMBOL: vel   ! disjunction, or      in prolog: ;
SYMBOL: non   ! negation             in prolog: not, \+

<PRIVATE

SYMBOL: a-pred

TUPLE: logic-pred name defs ;

: <pred> ( name -- pred )
    logic-pred new
    swap >>name
    { } clone >>defs ;

:: parse-list ( seq -- list )
    seq [ || = ] find drop :> d-pos
    d-pos [
        d-pos 1 + seq nth
        seq d-pos head dup length 1 > [ reverse ] when
        [ swap cons ] each
    ] [ seq sequence>list ] if ;

MIXIN: LOGIC-VAR
SINGLETON: NORMAL-LOGIC-VAR
SINGLETON: ANONYMOUSE-LOGIC-VAR
INSTANCE: NORMAL-LOGIC-VAR LOGIC-VAR
INSTANCE: ANONYMOUSE-LOGIC-VAR LOGIC-VAR
>>

: logic-var? ( obj -- ? ) 
    dup symbol? [ get LOGIC-VAR? ] [ drop f ] if ; inline

SYMBOLS: *trace?* *trace-depth* ;

PRIVATE>

: trace ( -- ) t *trace?* set-global ;

: notrace ( -- ) f *trace?* set-global ;

<<
SYNTAX: LOGIC-VARS: ";"
    [ create-class-in dup define-symbol
      [ NORMAL-LOGIC-VAR swap set-global ]
      \ call
      [ suffix! ] tri@
    ] each-token ;

SYNTAX: LOGIC-PREDS: ";"
    [ create-class-in dup define-symbol
      [ dup <pred> swap set-global ]
      \ call
      [ suffix! ] tri@
    ] each-token ;

SYNTAX: L{ \ }
    [ >array parse-list ] parse-literal ;
>>

<PRIVATE

TUPLE: logic-goal pred args ;

: called-args ( args -- args' )
    [ dup callable? [ call( -- term ) ] when ] map ;

:: <goal> ( pred args -- goal )
    pred get args called-args logic-goal boa ; inline

: normalize ( goal-def/defs -- goal-defs )
    dup !! = [ 1array ] [
        dup length 0 > [
            dup first dup symbol? [
                get logic-pred? [ 1array ] when
            ] [ drop ] if
        ] when
    ] if ;

TUPLE: logic-env table ;

: <env> ( -- env ) logic-env new H{ } clone >>table ; inline

:: env-put ( x pair env -- ) pair x env table>> set-at ; inline

:: env-get ( x env -- pair/f ) x env table>> at ; inline

:: env-delete ( x env -- ) x env table>> delete-at ; inline

: env-clear ( env -- ) table>> clear-assoc ; inline

:: dereference ( term! env! -- term' env' )
    t :> loop?!
    [ term logic-var? loop? and ] [
        term env env-get :> pair!
        pair [ pair first2 env! term! ] [ f loop?! ] if
    ] while
    term env ;

SYMBOL: L{

M: cons-state pprint-delims drop \ L{ \ } ;

M:: cons-state >pprint-sequence ( x -- seq ) 
   x [ car ] [ cdr ] bi :> ( x-car x-cdr )
   x-cdr nil? [ x-car 1array ] [
        x-cdr cons-state? [
            x-car 1array x-cdr >pprint-sequence append
        ] [ x-car || x-cdr 3array ] if
   ] if ;

M: cons-state pprint* pprint-object ;

PRIVATE>

M:: logic-env at* ( term! env! -- value/f ? )
    term env dereference env! term!
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

DEFER: unify*
    
:: (unify*) ( x! x-env! y! y-env! trail tmp-env -- success? )
    f :> ret-value!  f :> ret?! f :> ret2?!
    t :> loop?!
    [ loop? ] [
        { { [ x logic-var? ] [
                x x-env env-get :> xp!
                xp not [
                    y y-env dereference y-env! y!
                    x y = x-env y-env eq? and [
                        x { y y-env } x-env env-put
                        x-env tmp-env eq? [
                            { x x-env } trail push
                        ] unless
                    ] unless
                    f loop?!  t ret?!  t ret-value!
                ] [
                    xp first2 x-env! x!
                    x x-env dereference x-env! x!
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
                              x-slots y-slots [ i swap nth ] bi@
                              :> ( x-item y-item )
                              x-item x-env y-item y-env trail tmp-env unify* [                           
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

:: unify* ( x x-env y y-env trail tmp-env -- success? )
    *trace?* get-global :> trace?
    0 :> depth!
    trace? [
        *trace-depth* counter depth!
        depth [ "\t" printf ] times
        "Unification of " printf x-env x of pprint
        " and " printf y pprint nl
    ] when
    x x-env y y-env trail tmp-env (unify*) :> success?
    trace? [
        depth [ "\t" printf ] times
        success? [ "==> Success\n" ] [ "==> Fail\n" ] if "%s\n" printf
        *trace-depth* get-global 1 - *trace-depth* set-global
    ] when
    success? ;

:: resolve-body ( body env cut quot: ( -- ) -- )   
    body empty? [
        quot call( -- )
    ] [
        body first :> first-goal!
        body rest  :> rest-goals!
        first-goal !! = [           ! cut
            rest-goals env cut [
                quot call( -- )
            ] resolve-body
            t cut set-info
        ] [
            first-goal callable? [ 
                first-goal call( -- goal ) first-goal! 
            ] when
            *trace?* get-global [
                first-goal
                [ pred>> name>> "in: { %s " printf ]
                [ args>> [ "%s " printf ] each "}\n" printf ] bi
            ] when
            <env> :> d-env!
            f <cut> :> d-cut!   
            first-goal pred>> defs>> [
                [ first ] [ second ] bi :> ( d-head d-body )
                d-cut cut? cut cut? or [ t ] [
                    V{ } clone :> trail
                    first-goal env d-head d-env trail d-env unify* [
                        d-body callable? [                  
                            d-env trail <callback-env> d-body call( cb-env -- ? ) [
                                rest-goals env cut [ quot call( -- ) ] resolve-body
                            ] when
                        ] [
                            d-body d-env d-cut [
                                rest-goals env cut [ quot call( -- ) ] resolve-body
                                cut cut? d-cut set-info-if-f
                            ] resolve-body
                        ] if
                    ] when
                    trail [ first2 env-delete ] each
                    d-env env-clear
                    f
                ] if
            ] find 2drop
        ] if
    ] if ;

SYMBOLS: anonymous(is) anonymous(t/f) ;

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

: reset-anonymouse-var-no ( -- ) 0 *anonymouse-var-no* set-global ;

: proxy-var-for-'__' ( -- var-symbol )
    [
        *anonymouse-var-no* counter "ANON-%d_" sprintf
        "logica" create-word dup dup
        define-symbol
        ANONYMOUSE-LOGIC-VAR swap set-global
    ] with-compilation-unit ;

: replace-'__' ( before -- after )
    {
        { [ dup __ = ] [ drop proxy-var-for-'__' ] }
        { [ dup sequence? ] [ [ replace-'__' ] map ] }
        { [ dup tuple? ] [
              [ tuple-slots [ replace-'__' ] map ]
              [ class-of slots>tuple ] bi ] }
        [ ]
    } cond ;

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

:: (resolve) ( goal-def/defs quot: ( env -- ) -- )
    goal-def/defs replace-'__' normalize [
        [ first ] [ rest ] bi <goal>
    ] map :> goals
    <env> :> env
    goals env f <cut> [ env quot call( env -- ) ] resolve-body ;

SYMBOL: dummy-item

:: non-goal ( goal -- non-goal )
    anonymous(t/f) <pred> :> f-pred
    f-pred { } clone logic-goal boa :> f-goal
    f-goal [ drop f ] 2array 1array f-pred defs<<

    anonymous(t/f) <pred> :> t-pred
    t-pred { } clone logic-goal boa :> t-goal
    t-goal [ drop t ] 2array 1array t-pred defs<<
    
    goal pred>> name>> "non-%s" sprintf <pred> :> non-pred
    non-pred goal args>> clone logic-goal boa :> non-goal
    ! not P :- P, !, fail ; true  
    non-goal goal !! f-goal 3array 2array
    non-goal t-goal 1array 2array
    2array
    non-pred defs<<  
    non-goal ;

PRIVATE>

:: si ( head body -- )
    reset-anonymouse-var-no
    head replace-'__' [ first ] [ rest ] bi <goal> :> head-goal
    body replace-'__' normalize split-body  ! disjunction
    dup empty? [
        head-goal swap 2array
        head-goal pred>> [ swap 1array append ] change-defs drop
    ] [
        f :> non?!
        [
            [
                {
                    { [ dup non = ] [ drop dummy-item t non?! ] }
                    { [ dup array? ] [
                          [ first ] [ rest ] bi <goal> non? [ non-goal ] when 
                          f non?!
                      ] }
                    { [ dup callable? ] [
                          call( -- goal ) non? [ non-goal ] when
                          f non?!
                      ] }
                    { [ dup [ t = ] [ f = ] bi or ] [
                          :> t/f! non? [ t/f not t/f! ] when
                          anonymous(t/f) <pred> :> t/f-pred
                          { } clone :> args
                          t/f-pred args logic-goal boa :> t/f-goal
                          t/f-goal [ drop t/f ] 2array 1array t/f-pred defs<<
                          t/f-goal
                          f non?!
                      ] }
                    { [ dup !! = ] [ f non?! ] }  ! as '!!'     
                    [ drop dummy-item f non?! ]
                } cond
            ] map dummy-item swap remove :> body-goals
            head-goal body-goals 2array
            head-goal pred>> [ swap 1array append ] change-defs drop
        ] each    
    ] if ;

: semper ( head -- ) { } clone si ;

:: voca ( head quot: ( callback-env -- ? ) -- )
    head [ first ] [ rest ] bi <goal> :> head-goal
    head-goal quot 2array head-goal pred>>
    [ swap 1array append ] change-defs drop ;

:: unify ( cb-env x y -- success? )
    cb-env env>> :> env
    x env y env cb-env trail>> env (unify*) ;

:: is ( quot: ( env -- value ) dist -- goal )
    quot collect-logic-vars
    dup dist swap member? [ dist 1array append ] unless :> args 
    anonymous(is) <pred> :> is-pred
    is-pred args logic-goal boa :> is-goal
    is-goal [| env | env dist env quot call( env -- value ) unify ] 2array
    1array is-pred defs<<
    is-goal ;

M: array >list sequence>list ;

: resolve ( goal-def/defs quot: ( env -- ) -- ) (resolve) ;

: resolve* ( goal-def/defs -- ) [ drop ] resolve ;

:: query ( goal-def/defs -- bindings-array/success? )
    *trace?* get-global :> trace?
    f :> success?!
    V{ } clone :> bindings-seq
    goal-def/defs normalize
    [| env |
     V{ } clone :> bindings
     env table>>
     keys [| key |
           key dup env at 2array bindings push
           trace? [
               key "%s: " printf key env at pprint nl
           ] when
          ] each
     bindings >hashtable bindings-seq push
     t success?!
    ] (resolve)
    bindings-seq >array
    {
        { [ dup empty? ] [ drop success? ] }
        { [ dup first keys [ get NORMAL-LOGIC-VAR? ] filter empty? ] [
              drop success?
          ] }
        [ ]
        } cond ;

    
! Built-in definition -----------------------------------------------------

LOGIC-PREDS: (<) (>) (>=) (=<) (=:=) (=\=) (==) (\==) (=) (\=)
             trueo failo
             varo nonvaro
             writeo writenlo nlo
             membero appendo lengtho conco listo
;

LOGIC-VARS: A_ B_ C_ X_ Y_ Z_ ;

{ (<) X_ Y_ } [
    [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ < ] [ 2drop f ] if
] voca

{ (>) X_ Y_ } [
    [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ > ] [ 2drop f ] if
] voca

{ (>=) X_ Y_ } [
    [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ >= ] [ 2drop f ] if
] voca

{ (=<) X_ Y_ } [
    [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ <= ] [ 2drop f ] if
] voca

{ (=:=) X_ Y_ } [
    [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ = ] [ 2drop f ] if
] voca

{ (=\=) X_ Y_ } [
    [ X_ of ] [ Y_ of ] bi 2dup [ number? ] both? [ = not ] [ 2drop f ] if
] voca

{ (==) X_ Y_ } [ [ X_ of ] [ Y_ of ] bi = ] voca

{ (\==) X_ Y_ } [ [ X_ of ] [ Y_ of ] bi = not ] voca

{ (=) X_ Y_ } [ dup [ X_ of ] [ Y_ of ] bi unify ] voca

{ (\=) X_ Y_ } [ dup [ X_ of ] [ Y_ of ] bi unify not ] voca


{ trueo } [ drop t ] voca

{ failo } [ drop f ] voca


{ varo X_ }    [ X_ of logic-var? ] voca

{ nonvaro X_ } [ X_ of logic-var? not ] voca


{ writeo X_ } [
    X_ of [ dup string? [ printf ] [ pprint ] if ] each t
] voca

{ writenlo X_ } [
    X_ of [ dup string? [ printf ] [ pprint ] if ] each nl t
] voca

{ nlo } [ drop nl t ] voca


{ membero X_ L{ X_ || Z_ } } semper
{ membero X_ L{ Y_ || Z_ } } { membero X_ Z_ } si

{ appendo L{ } A_ A_ } semper
{ appendo L{ A_ || X_ } Y_ L{ A_ || Z_ } } {
    { appendo X_ Y_ Z_ }
} si


LOGIC-VARS: Tail_ N_ N1_ ;

{ lengtho L{ } 0 } semper
{ lengtho L{ __ || Tail_ } N_ } {
    { lengtho Tail_ N1_ }
    [ [ N1_ of 1 + ] N_ is ]
} si


LOGIC-VARS: L_ L1_ L2_ L3_ ;

{ conco L{ } L_ L_ } semper
{ conco L{ X_ || L1_ } L2_ L{ X_ || L3_ } } {
    { conco L1_ L2_ L3_ }
} si


{ listo L{ } } semper
{ listo L{ __ || __ } } semper
