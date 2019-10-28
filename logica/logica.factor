! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.parser
classes.tuple combinators compiler.units continuations
formatting fry hashtables io kernel lexer locals make
math namespaces parser prettyprint prettyprint.backend
prettyprint.config prettyprint.custom prettyprint.sections
quotations sequences sequences.deep sets splitting strings
words words.symbol ;

IN: logica

<<
SYMBOL: !!    ! cut operator         in prolog: !
SYMBOL: __    ! anonymous variable   in prolog: _
SYMBOL: |     ! head-tail separator  in prolog: |
SYMBOL: vel   ! disjunction, or      in prolog: ;
SYMBOL: non   ! negation             in prolog: not, \+

TUPLE: cons-pair cons-car cons-cdr ;

C: cons cons-pair

: car ( cons-pair -- car ) cons-car>> ; inline

: cdr ( cons-pair -- cdr ) cons-cdr>> ; inline

: uncons ( cons-pair -- car cdr ) [ car ] [ cdr ] bi ; inline

SINGLETON: NIL

MIXIN: logica-list
INSTANCE: cons-pair logica-list
INSTANCE: NIL logica-list

<PRIVATE

TUPLE: logic-pred name defs ;

: <pred> ( name -- pred )
    logic-pred new
        swap >>name
        { } clone >>defs ;

:: parse-list ( seq -- cons-pair )
    seq [ | = ] find drop :> d-pos!
    d-pos [
        d-pos 1 + seq nth
    ] [
        seq length d-pos!
        NIL
    ] if
    seq d-pos head dup length 1 > [ reverse ] when
    [ swap cons ] each ;

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
      [ dup "%s" sprintf <pred> swap set-global ]
      \ call
      [ suffix! ] tri@
    ] each-token ;

SYNTAX: L[ \ ]
    [ >array parse-list ] parse-literal ;
>>

<PRIVATE

TUPLE: logic-goal pred args ;

: called-args ( args -- args' )
    [ dup callable? [ call( -- term ) ] when ] map ;

:: <goal> ( pred args -- goal )
    pred get args called-args logic-goal boa ; inline

: def>goal ( goal-def -- goal ) unclip swap <goal> ; inline

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

: dereference ( term env -- term' env' )
    [ 2dup env-get [ 2nip first2 t ] [ f ] if* ] loop ;

M: logica-list pprint-delims drop \ L[ \ ] ;

M: logica-list pprint*
    [
        <flow
        dup pprint-delims [
            pprint-word
            dup pprint-narrow? <inset
            [
                building get
                length-limit get
                '[ dup cons-pair? _ length _ < and ]
                [ uncons swap , ] while
            ] { } make
            [ pprint* ] each
            dup logica-list? [
                NIL? [ "~more~" text ] unless
            ] [
                "|" text pprint*
            ] if
            block>
        ] dip pprint-word block>
    ] check-recursion ;

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

: each-until ( seq quot -- ) find 2drop ; inline

:: resolve-body ( body env cut quot: ( -- ) -- )
    body empty? [
        quot call( -- )
    ] [
        body unclip :> ( rest-goals! first-goal! )
        first-goal !! = [  ! cut
            rest-goals env cut [ quot call( -- ) ] resolve-body
            t cut set-info
        ] [
            first-goal callable? [
                first-goal call( -- goal ) first-goal!
            ] when
            *trace?* get-global [
                first-goal
                [ pred>> name>> "in: { %s " printf ]
                [ args>> [ "%u " printf ] each "}\n" printf ] bi
            ] when
            <env> :> d-env!
            f <cut> :> d-cut!
            first-goal pred>> defs>> [
                first2 :> ( d-head d-body )
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
            ] each-until
        ] if
    ] if ;

: split-body ( body -- bodies )
    { vel } split [ >array ] map ;

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

: collect-logic-vars ( seq -- vars-array )
    [ logic-var? ] deep-filter members ;

:: (resolve) ( goal-def/defs quot: ( env -- ) -- )
    goal-def/defs replace-'__' normalize [ def>goal ] map :> goals
    <env> :> env
    goals env f <cut> [ env quot call( env -- ) ] resolve-body ;

SYMBOL: dummy-item

:: non-goal ( goal -- non-goal )
    "failo" <pred> :> f-pred
    f-pred { } clone logic-goal boa :> f-goal
    { { f-goal [ drop f ] } } f-pred defs<<
    "trueo" <pred> :> t-pred
    t-pred { } clone logic-goal boa :> t-goal
    { { t-goal [ drop t ] } } t-pred defs<<
    goal pred>> name>> "non-%s_" sprintf <pred> :> non-pred
    non-pred goal args>> clone logic-goal boa :> non-goal
    {
        { non-goal { goal !! f-goal } }
        { non-goal { t-goal } }
    } non-pred defs<<  ! non-P_ { P !! { failo } vel { trueo } } si
    non-goal ;

SYMBOLS: at-the-beginning at-the-end ;

:: (si) ( head body pos -- )
    reset-anonymouse-var-no
    head replace-'__' def>goal :> head-goal
    body replace-'__' normalize split-body  ! disjunction
    dup empty? [
        head-goal swap 2array
        head-goal pred>> [ swap suffix ] change-defs drop
    ] [
        f :> non?!
        [
            [
                {
                    { [ dup non = ] [ drop dummy-item t non?! ] }
                    { [ dup array? ] [
                          def>goal non? [ non-goal ] when
                          f non?!
                      ] }
                    { [ dup callable? ] [
                          call( -- goal ) non? [ non-goal ] when
                          f non?!
                      ] }
                    { [ dup [ t = ] [ f = ] bi or ] [
                          :> t/f! non? [ t/f not t/f! ] when
                          t/f [ "trueo" ] [ "failo" ] if <pred> :> t/f-pred
                          { } clone :> args
                          t/f-pred args logic-goal boa :> t/f-goal
                          { { t/f-goal [ drop t/f ] } } t/f-pred defs<<
                          t/f-goal
                          f non?!
                      ] }
                    { [ dup !! = ] [ f non?! ] }  ! as '!!'
                    [ drop dummy-item f non?! ]
                } cond
            ] map dummy-item swap remove :> body-goals
            { head-goal body-goals }
            head-goal pred>> [
                swap 1array pos at-the-beginning = [ swap ] when append
            ] change-defs drop
        ] each
    ] if ;

: (semper) ( head pos -- ) { } clone swap (si) ;

PRIVATE>

: si ( head body -- ) at-the-end (si) ; inline

: si* ( head body -- ) at-the-beginning (si) ; inline

: semper ( head -- ) at-the-end (semper) ; inline

: semper* ( head -- ) at-the-beginning (semper) ; inline

:: voca ( head quot: ( callback-env -- ? ) -- )
    head def>goal :> head-goal
    head-goal pred>> [
        { head-goal quot } suffix
    ] change-defs drop ;

:: unify ( cb-env x y -- success? )
    cb-env env>> :> env
    x env y env cb-env trail>> env (unify*) ;

:: is ( quot: ( env -- value ) dist -- goal )
    quot collect-logic-vars
    dup dist swap member? [ dist suffix ] unless :> args
    quot dist "[ %u %s is ]" sprintf <pred> :> is-pred
    is-pred args logic-goal boa :> is-goal
    {
        {
            is-goal
            [| env | env dist env quot call( env -- value ) unify ]
        }
    } is-pred defs<<
    is-goal ;

:: =:= ( quot1: ( env -- value ) quot2: ( env -- value ) -- goal )
    quot1 quot2 [ collect-logic-vars ] bi@ union :> args
    quot1 quot2 "[ %u %u =:= ]" sprintf <pred> :> =:=-pred
    =:=-pred args logic-goal boa :> =:=-goal
    {
        {
            =:=-goal
            [| env |
                env quot1 call( env -- value )
                env quot2 call( env -- value )
                2dup [ number? ] both? [ = ] [ 2drop f ] if ]
        }
    } =:=-pred defs<<
    =:=-goal ;

:: =\= ( quot1: ( env -- value ) quot2: ( env -- value ) -- goal )
    quot1 quot2 [ collect-logic-vars ] bi@ union :> args
    quot1 quot2 "[ %u %u =\\= ]" sprintf <pred> :> =\=-pred
    =\=-pred args logic-goal boa :> =\=-goal
    {
        {
            =\=-goal
            [| env |
                env quot1 call( env -- value )
                env quot2 call( env -- value )
                2dup [ number? ] both? [ = not ] [ 2drop f ] if ]
        }
    } =\=-pred defs<<
    =\=-goal ;

: >list ( seq -- cons-pair ) parse-list ; inline

:: list>array ( list -- array )
    list NIL? [
        { } clone
    ] [
        list [ car ] [ cdr ] bi :> ( l-car l-cdr )
        l-car cons-pair? [ l-car list>array ] [ list car ] if 1array
        l-cdr logica-list? [ l-cdr list>array append ] when
    ] if ;

: resolve ( goal-def/defs quot: ( env -- ) -- ) (resolve) ;

: resolve* ( goal-def/defs -- ) [ drop ] resolve ;

:: query-n ( goal-def/defs n/f -- bindings-array/success? )
    *trace?* get-global :> trace?
    0 :> count!
    f :> success?!
    V{ } clone :> bindings-seq
    [
        goal-def/defs normalize
        [| env |
            V{ } clone :> bindings
            env table>>
            keys [| key |
                key get NORMAL-LOGIC-VAR? [
                    key dup env at 2array bindings push
                    trace? [ key "%u: " printf key env at pprint nl ] when
                ] when
            ] each
            bindings >hashtable bindings-seq push
            t success?!
            n/f [
                count 1 + count!
                count n/f >= [ return ] when
            ] when
        ] (resolve)
    ] with-return
    bindings-seq >array
    {
        { [ dup empty? ] [ drop success? ] }
        { [ dup first keys [ get NORMAL-LOGIC-VAR? ] filter empty? ] [
              drop success?
          ] }
        [ ]
    } cond ;

: query ( goal-def/defs -- bindings-array/success? ) f query-n ;


! Built-in predicate definitions -----------------------------------------------------

LOGIC-PREDS: trueo failo
             varo nonvaro
             asserto assertao assertzo retracto callo
             (<) (>) (>=) (=<) (==) (\==) (=) (\=)
             writeo writenlo nlo
             membero appendo lengtho conco listo
;

{ trueo } [ drop t ] voca

{ failo } [ drop f ] voca


LOGIC-VARS: A_ B_ C_ X_ Y_ Z_ ;

{ asserto X_ } [ X_ of call( -- ) t ] voca

{ assertzo X_ } [ X_ of call( -- ) t ] voca

{ assertao X_ } [| env |
                 [ ] clone :> quot!
                 env X_ of [
                     {
                         { [ dup \ semper = ] [ drop semper* ] }
                         { [ dup \ si = ] [ drop si* ] }
                         [ ]
                     } cond
                     1array quot swap append quot!
                 ] each
                 quot call( -- )
                 t
                ] voca

{ retracto X_ } [
    X_ of get [ dup length 1 >= [ rest ] when ] change-defs drop t
] voca


{ varo X_ } [ X_ of logic-var? ] voca

{ nonvaro X_ } [ X_ of logic-var? not ] voca


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

{ (==) X_ Y_ } [ [ X_ of ] [ Y_ of ] bi = ] voca

{ (\==) X_ Y_ } [ [ X_ of ] [ Y_ of ] bi = not ] voca

{ (=) X_ Y_ } [ dup [ X_ of ] [ Y_ of ] bi unify ] voca

{ (\=) X_ Y_ } [
    clone [ clone ] change-env [ clone ] change-trail
    dup [ X_ of ] [ Y_ of ] bi unify not
] voca


{ writeo X_ } [
    X_ of dup sequence? [
        [ dup string? [ printf ] [ pprint ] if ] each
    ] [
        dup string? [ printf ] [ pprint ] if
    ] if t
] voca

{ writenlo X_ } [
    X_ of dup sequence? [
        [ dup string? [ printf ] [ pprint ] if ] each
    ] [
        dup string? [ printf ] [ pprint ] if
    ] if nl t
] voca

{ nlo } [ drop nl t ] voca


{ membero X_ L[ X_ | Z_ ] } semper
{ membero X_ L[ Y_ | Z_ ] } { membero X_ Z_ } si

{ appendo L[ ] A_ A_ } semper
{ appendo L[ A_ | X_ ] Y_ L[ A_ | Z_ ] } {
    { appendo X_ Y_ Z_ }
} si


LOGIC-VARS: Tail_ N_ N1_ ;

{ lengtho L[ ] 0 } semper
{ lengtho L[ __ | Tail_ ] N_ } {
    { lengtho Tail_ N1_ }
    [ [ N1_ of 1 + ] N_ is ]
} si


LOGIC-VARS: L_ L1_ L2_ L3_ ;

{ conco L[ ] L_ L_ } semper
{ conco L[ X_ | L1_ ] L2_ L[ X_ | L3_ ] } {
    { conco L1_ L2_ L3_ }
} si


{ listo L[ ] } semper
{ listo L[ __ | __ ] } semper

