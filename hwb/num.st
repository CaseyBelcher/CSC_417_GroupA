#!/usr/bin/env gst 
 
FileStream fileIn: 'my.st' !

Magic sub: #Num has: 'n mu m2 sd id lo hi txt w'

! Num methods !

 init 
    self n: 0;
      mu: 0;
      m2: 0;
      sd: 0;
      id: self;
      lo: (10 raisedTo:32);
      hi: -1 * (10 raisedTo:32); 
      txt: '';  
      w: 1 !
   
  " 
   function numInc(t,x,    d) 
   if x == ""?"" then return x end
   t.n  = t.n + 1
   d    = x - t.mu
   t.mu = t.mu + d/t.n
   t.m2 = t.m2 + d*(x - t.mu)
   if x > t.hi then t.hi = x end
   if x < t.lo then t.lo = x end
   if (t.n>=2) then 
     t.sd = (t.m2/(t.n - 1 + 10^-32))^0.5 end
   return x  
 end " 
  
 numInc: newNum  
    | d |
    newNum == '?' ifTrue: [^newNum] .
    n := (n+1) . 
    d := (newNum - mu) . 
    mu := mu + (d/n) . 
    m2 := m2 + (d*(newNum - mu)) . 
    (newNum > hi) ifTrue: [(hi := newNum)]   .
    (newNum < lo) ifTrue: [(lo := newNum)]   . 
    (n >= 2) ifTrue: 
      [^(sd := (m2/(n-1+(10 raisedTo:(-32)))) raisedTo:0.5  )] . 
    ^newNum   !
    
  
  nextPutAll: argArray 
    argArray do: [:x| (self numInc:x)] !
    
    

   
     
  

!
