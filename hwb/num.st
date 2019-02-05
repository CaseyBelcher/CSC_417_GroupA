#!/usr/bin/env gst 
 
FileStream fileIn: 'my.st' !

Magic sub: #Num has: 'n mu m2 sd id lo hi txt w'

! Num methods !
init
   self n: 0;
        mu: 0;
        m2: 0;
        sd: 0;
        id: 0;
        lo: 0;
        hi: 0;
        txt: 'txt';
        w: 1 !
 
printOn: aStream
   aStream
      nextPutAll: 'Num(';
      nextPutAll: ', n=',n s;
      nextPutAll: ', mu=',mu s;
      nextPutAll: ', m2=',m2 s;
      nextPutAll: ', sd=',sd s;
      nextPutAll: ', id=',id s;
      nextPutAll: ', lo=',lo s;
      nextPutAll: ', hi=',hi s;
      nextPutAll: ', txt=',txt s;
      nextPutAll: ', w=',w s;
      nextPutAll: ')'!
!
      
