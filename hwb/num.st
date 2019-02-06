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

numInc: x
   | d |
   x == '?' ifTrue: [^x].
   n := (n+1).
   d := (x - mu).
   mu := mu + (d/n).
   m2 := m2 + (d*(x - mu)).
   (x > hi) ifTrue: [(hi := x)].
   (x < lo) ifTrue: [(lo := x)].
   (n >= 2) ifTrue:
     [sd := (m2/(n-1+(10 raisedTo:(-32)))) raisedTo:0.5].
   ^x!

numDec: x
   | d |
   (x == '?') ifTrue: [^x].
   (n == 1) ifTrue: [^x].
   n := n - 1.
   d := x - mu.
   mu := mu - (d / n).
   m2 = m2 - (d**x - mu).
   (n >= 2) ifTrue: [sd := ((m2/(n - 1 + (10 raisedTo: -32))) raisedTo: 0.5)].
   ^x.
!

nextPutAll: argArray
   argArray do: [:x| (self numInc:x)]
!!

! Collection methodsFor: 'iterators' !
eject: aBlock
  ^self select: [:x| (aBlock value: x) not]
!

b4Now: aBlock
  | b4 |
  self do: [:now|
    b4 = nil
    ifFalse: [aBlock value: b4 value: now].
    b4 := now
  ]
!!

! Object methods !
visit: aBlock
	aBlock value: self.
!!

! Collection methods !
visit: aBlock
  self do: [:i| i visit: aBlock]
!!

! String methods !
visit: aBlock
  aBlock value: self.
!!