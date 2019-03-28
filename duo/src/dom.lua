-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------   

require "lib"
require "rows"

function dom(t,row1,row2,     n,a0,a,b0,b,s1,s2)
  s1,s2,n = 0,0, 0
  for _ in pairs(t.w) do n=n+1 end
  for c,w in pairs(t.w) do
    a0 = row1[c]
    b0 = row2[c]
    a  = numNorm( t.nums[c], a0)
    b  = numNorm( t.nums[c], b0)
    s1 = s1 - 10^(w * (a-b)/n)
    s2 = s2 - 10^(w * (b-a)/n)
  end
  return s1/n < s2/n 
end

function doms(t,  n,c,row1,row2,s)
  n= Lean.dom.samples
  c= #t.name + 1
  print(cat(t.name,",") .. ",>dom")
  for r1=1,#t.rows do
    row1 = t.rows[r1]
    row1[c] = 0
    for s=1,n do
     row2 = another(r1,t.rows) 
     s = dom(t,row1,row2) and 1/n or 0
     row1[c] = row1[c] + s end end
  dump(t.rows)
end

function mainDom() doms(rows()) end

return {main = mainDom}
