! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factlog assocs math kernel
factlog.examples.factorial
factlog.examples.fib
factlog.examples.hanoi
factlog.examples.hanoi2
factlog.examples.money
factlog.examples.zebra
factlog.examples.zebra-short
factlog.examples.zebra2
;

IN: factlog.tests

LOGIC-PREDS: cato mouseo creatureo ;
LOGIC-VARS: X Y ;
SYMBOLS: Tom Jerry Nibbles ;
{ cato Tom } fact
{ mouseo Jerry } fact
{ mouseo Nibbles } fact

{ t } [ { cato Tom } query ] unit-test
{ f } [ { { cato Tom } { cato Jerry } } query ] unit-test
{ { H{ { X Jerry } } H{ { X Nibbles } } } } [
    { mouseo X } query
] unit-test

{ creatureo X } { cato X } rule

{ { H{ { Y Tom } } } } [ { creatureo Y } query ] unit-test

LOGIC-PREDS: youngo young-mouseo ;
{ youngo Nibbles } fact
{ young-mouseo X } {
    { mouseo X }
    { youngo X }
} rule

{ { H{ { X Nibbles } } } } [ { young-mouseo X } query ] unit-test

{ creatureo X } { mouseo X } rule

{ { H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } } } [
    { creatureo X } query
] unit-test

creatureo clear-pred
{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule

{ { H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } } } [
    { creatureo X } query
] unit-test

{ { H{ { Y Tom } } H{ { Y Jerry } } } } [
    { creatureo Y } 2 query-n
] unit-test

LOGIC-PREDS: likes-cheeseo dislikes-cheeseo ;
{ likes-cheeseo X } { mouseo X } rule
{ dislikes-cheeseo Y } {
    { creatureo Y }
    \+ { likes-cheeseo Y }
} rule

{ f } [ { dislikes-cheeseo Jerry } query ] unit-test
{ t } [ { dislikes-cheeseo Tom } query ] unit-test

{ L[ Tom Jerry Nibbles ] } [ L[ Tom Jerry Nibbles ] ] unit-test
{ t } [ { membero Jerry L[ Tom Jerry Nibbles ] } query ] unit-test

SYMBOL: Spike

{ f } [
    { membero Spike [ Tom Jerry Nibbles L[ ] cons cons cons ] } query
] unit-test

TUPLE: house living dining kitchen in-the-wall ;
LOGIC-PREDS: houseo ;
{ houseo T{ house
            { living Tom }
            { dining f }
            { kitchen Nibbles }
            { in-the-wall Jerry }
          }
} fact

{ { H{ { X Nibbles } } } } [
    { houseo T{ house
                { living __ }
                { dining __ }
                { kitchen X }
                { in-the-wall __ }
              }
    } query
] unit-test

LOGIC-PREDS: is-ao consumeso ;
SYMBOLS: mouse cat milk cheese fresh-milk Emmentaler ;
{
    { is-ao Tom cat }
    { is-ao Jerry mouse }
    { is-ao Nibbles mouse }
    { is-ao fresh-milk milk }
    { is-ao Emmentaler cheese }
} facts
{
    {
        { consumeso X milk } {
            { is-ao X mouse } ;;
            { is-ao X cat }
        }
    }
    { { consumeso X cheese } { is-ao X mouse } }
    { { consumeso Tom mouse } { !! f } }
    { { consumeso X mouse } { is-ao X cat } }
} rules

{
    {
        H{ { X milk } { Y fresh-milk } }
        H{ { X cheese } { Y Emmentaler } }
    }
} [
    { { consumeso Jerry X } { is-ao Y X } } query
] unit-test
{ { H{ { X milk } { Y fresh-milk } } } } [
    { { consumeso Tom X } { is-ao Y X } } query
] unit-test

LOGIC-PREDS: factorialo N_>_0  N2_is_N_-_1  F_is_F2_*_N ;
LOGIC-VARS: N N2 F F2 ;
{ factorialo 0 1 } fact
{ factorialo N F } {
    { N_>_0 N }
    { N2_is_N_-_1 N2 N }
    { factorialo N2 F2 }
    { F_is_F2_*_N F F2 N }
} rule
{ N_>_0 N } [ N of 0 > ] callback
{
    { { N2_is_N_-_1 N2 N } [ dup N of 1 - N2 unify ] }
    { { F_is_F2_*_N F F2 N } [ dup [ N of ] [ F2 of ] bi * F unify ] }
} callbacks

{ { H{ { F 1 } } } } [ { factorialo 0 F } query ] unit-test
{ { H{ { F 1 } } } } [ { factorialo 1 F } query ] unit-test
{ { H{ { F 3628800 } } } } [ { factorialo 10 F } query ] unit-test

factorialo clear-pred
{ factorialo 0 1 } fact
{ factorialo N F } {
    { (>) N 0 }
    [ [ N of 1 - ] N2 is ]
    { factorialo N2 F2 }
    [ [ [ F2 of ] [ N of ] bi * ] F is ]
} rule

{ { H{ { F 1 } } } } [ { factorialo 0 F } query ] unit-test
{ { H{ { F 1 } } } } [ { factorialo 1 F } query ] unit-test
{ { H{ { F 3628800 } } } } [ { factorialo 10 F } query ] unit-test
