#!/usr/bin/env gst 

FileStream fileIn: 'my.st' "mytricks" !
FileStream fileIn: 'num.st' "yourcode" !

'1b1 - Num: ' oo !
| num |
num := Num new.
num nextPutAll: #( 2 3 4 4 4 4 5 5 6 7 7
                 8 9 9 9 9 10 11 12 12).

num sd oo. "==> 3.06"
num mu oo. "==> 7"
num n  oo. "==> 20" ! 

'1b2 - eject: ' oo !
Collection goodEject oo!

'1b3 - b4Now: ' oo !
Collection goodB4Now !

'1b4 - Generic Visit: ' oo !
Object goodVisit.

'1b5 - testEverything: ' oo !
Object testEverything !
