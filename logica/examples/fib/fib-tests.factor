! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test logica logica.examples.fib ;
IN: logica.examples.fib.tests

{ { H{ { L L{ 0 } } } } } [ { fib 0 L } query ] unit-test

{ { H{ { L L{ 1 1 0 } } } } } [ { fib 2 L } query ] unit-test

{ { H{ { L L{ 55 34 21 13 8 5 3 2 1 1 0 } } } } } [
    { fib 10 L } query
] unit-test
