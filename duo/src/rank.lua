-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro   
--------- --------- --------- --------- --------- ---------  

require "lib"
require "num"
require "sym"
require "rows"

-- This code rewrites the contents of
-- the numeric independent variables as ranges (e.g. 23:45).
-- Such columns `c` are sorted then explored for a `cut` where
-- the expected value of the variance after cutting is 
-- minimized. Note that this code endorses a cut only if:
--
-- - _Both_ the expected value of
--   the standard deviation of `c` and the goal column
--   `goal` are  minimized
-- - The minimization is create than some trivially
--   small change (defaults to 5%, see `Lean.super.margin`);
-- - The number of items in each cut is greater than 
--   some magic constant `enough` (which defaults to
--   the square root of the number of rows, see
--   `Lean.super.enough`)
--
-- After finding a cut, this code explores both 
-- sides of the cut for recursive cuts.
-- 
-- Important note: this code **rewrites** the table
-- so the only thing to do when it terminates is
-- dump the new table and quit.


local function klasses(file,      both,all, blank,k)
  both={}
  all = rows(file and io.input(file) or io.input(),
             data(),
             header, 
             function(t,cells,  k)
                blank = blank or clone(t)
                k     = cells[#cells]
                both[k] = both[k] or clone(blank)
                row(t,cells)
                row(both[k],cells) end)
  return all, both
end

local function bestRest(both,   order,best,rest)
  order={}
  for k,t in pairs(both) do -- initialize the best rest tables
    order[#order+1] = {t.nums[t.col['>dom']].mu, k} end
  ksort(1,order)
  rest = order[1][2]
  best = order[2][2]
  return best,rest
end

local function look2(t,c,x,default,  tmp)
  tmp = t.syms[c] 
  if tmp then return tmp.counts[x] or default end
  return default
end

local function  main(file,   all,both,best,rest,nb,nr,order,b,r,s)
  all,both  = klasses(file)
  best,rest = bestRest(both)
  nb        = #both[best].rows
  nr        = #both[rest].rows
  order={}
  for c,_ in pairs(all.name) do -- for all columns
    if indep(all,c) then        -- for all independent columns
      for x,_ in pairs(all.syms[c].counts) do -- for all symbols in column
        b = look2(both[best],c,x,0.001)
        r = look2(both[rest],c,x,0.001)
        b = b/(nb + 0.00001)
        r = r/(nr + 0.00001)
        if b > r then
          order[#order+1] = {-1*b^2/(b+r), c,x,b,r} end end end end
  ksort(1,order)
  s = function (x) return int(100*x) end
  for i,t in pairs(order) do
    print(i,s(-1*t[1]), 
            all.name[t[2]],t[3],s(t[4]),s(t[5]))
  end
end

-- Main function, if this is cbothed top-level.

return {main= main}
