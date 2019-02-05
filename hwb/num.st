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

numInc |t x d|
  x == '?' ifTrue: [^x].
  t.n := (self.n + 1).
  d := x - t.mu.
  t.mu = t.mu + (d/t.n).

  t.m2 := t.m2 + d*(x - t.mu)
  if x > t.hi then t.hi = x end
  if x < t.lo then t.lo = x end
  if (t.n>=2) then 
  t.sd = (t.m2/(t.n - 1 + 10^-32))^0.5 end
  return x
!
!
