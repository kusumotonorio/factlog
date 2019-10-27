! Copyright (C) 2019 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test logica logica.examples.money ;
IN: logica.examples.money.tests

{
    {
        H{
            { N1 LL{ 0 9 5 6 7 } }
            { N2 LL{ 0 1 0 8 5 } }
            { N  LL{ 1 0 6 5 2 } }
        }
    }
}
[
    { { moneyo N1 N2 N } { sumo N1 N2 N } } query
    S-and-M-can't-be-zero
] unit-test

{
    {
        H{
            { N1 LL{ 5 2 6 4 8 5 } }
            { N2 LL{ 1 9 7 4 8 5 } }
            { N  LL{ 7 2 3 9 7 0 } }
        }
    }
}
[
    { { donaldo N1 N2 N } { sumo N1 N2 N } } query
] unit-test
