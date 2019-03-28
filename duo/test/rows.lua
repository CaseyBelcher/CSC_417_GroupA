-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

package.path = '../src/?.lua;' .. package.path
require "lib"
require "ok"
require "rows"

ok { rows = function (    d) 
    d=rows("../test/data/weather.csv") 
    assert(#d._use == 4)
    assert(d.nums[2].lo == 64)  end }


