-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

package.path = '../src/?.lua;' .. package.path
require "lib"
require "ok"

ok {fails = function() assert(1==2) end }
ok {passes = function() assert(1==1) end }

ok { random = function(    a,b)
                rseed(1)
                a= rand()
                rseed(1)
                b=rand()
                assert(a==b) end }

ok { ordered = function(    t)
        t={zz=1,cc=2,aa=1}
        for k,v in ordered(t) do print(k,v) end
        for k,_ in ordered(t) do
          return assert(k=="aa") end end }

ok { splits = function(   t)
          t= split("abcdab","a")
          assert("bcd" == t[1])
          assert("b" == t[2])
          end }

o{a=1,b={k={ll=234,m={}},d=44},c=3,d={30,20,10}}

for i=1,100 do
  io.write(another(2,{"a","!","c","d"}))
end

ok { cols = function()
     local t={ {"name", "age", "shoesize"},
               {"tim Menzies", 20, 40},
               {"jane", 2.312211, 20 } }
     cols(t, "%5.2f")
end}
