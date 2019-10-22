! Copyright (C) 2019 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test logica logica.examples.zebra-short ;
IN: logica.examples.zebra-short.tests

{
    { H{ { X japanese } } H{ { X japanese } } }
}
[ { zebrao X } query ] unit-test

