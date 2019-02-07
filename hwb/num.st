#!/usr/bin/env gst

FileStream fileIn: 'my.st' !

"==================== 1b1 ===================="
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

"==================== 1b2 ===================="
! Collection methodsFor: 'iterators' !
eject: aBlock
  ^self select: [:x| (aBlock value: x) not]
!

"==================== 1b3 ===================="
b4Now: aBlock
  | b4 |
  self do: [:now|
    b4 = nil
    ifFalse: [aBlock value: b4 value: now].
    b4 := now
  ]
!!

"=========== 1b2+1b3 test methods ============"
!Collection class methodsFor: 'testing' !
goodB4Now
  #(10 21 32 43 54) b4Now: [:b4 :now|
    ((now-b4)/b4) asFloat oo] !
        
goodEject
  ^#(1 2 3) eject: [:x | x > 1.5 ] !
!

"==================== 1b4 ===================="
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

"==================== 1b5 ===================="
! Object class methodsFor: 'tst' !
testEverything
Object allSubclasses visit: [:class|
  class methodDictionary ifNotNil: [:dict|
    MethodInfo dict oo
  ]
]
  "Object allSubclasses do: [:class|
    'hi' oo.
    class methodDictionary do: [:method|
      'hi' oo.
      method oo.
    ]
  ]."
!!





"(Object withAllSubclasses collect: [ :cls |
    cls methodDictionary ifNotNil: [ :dict |
        dict values select: [ :method |
            (method selector asLowercase indexOfSubCollection: 'convert' asLowercase) > 0 and: [
            (method selector asLowercase indexOfSubCollection: 'string' asLowercase) > 0 ]
        ]
    ]
]) join"