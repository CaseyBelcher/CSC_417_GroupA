#!/usr/bin/env gst 
 
FileStream fileIn: 'my.st' !

Magic sub: #Num has: 'n mu m2 sd id lo hi txt w'

! Num methods !
init
   n := 0.
   mu := 0.
   m2 := 0.
   sd := 0.
   id := 0.
   lo := 10 raisedTo 32.
   hi := -10 raisedTo 32.
   txt := 'txt'.
   w := 1. 
 !
