! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test logica logica.examples.zebra2 ;
IN: logica.examples.zebra2.tests

{
    {
        H{
            {
                Hs
                L[
                    T{ house
                       { color yellow }
                       { nationality norwegian }
                       { drink water }
                       { smoke dunhill }
                       { pet cat }
                     }
                    T{ house
                       { color blue }
                       { nationality dane }
                       { drink tea }
                       { smoke blend }
                       { pet horse }
                     }
                    T{ house
                       { color red }
                       { nationality english }
                       { drink milk }
                       { smoke pall-mall }
                       { pet birds }
                     }
                    T{ house
                       { color green }
                       { nationality german }
                       { drink coffee }
                       { smoke prince }
                       { pet zebra }
                     }
                    T{ house
                       { color white }
                       { nationality swede }
                       { drink beer }
                       { smoke blue-master }
                       { pet dog }
                     }
                ]
            }
            { X norwegian }
            { Y german }
        }
    }
}
[ { houseso Hs X Y } query ] unit-test
