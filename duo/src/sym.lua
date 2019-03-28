--vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

-- ## Example

--
--      s=syms{ 'y','y','y','y','y','y','y','y','y',
--              'n','n','n','n','n'}
--      print(symEnt(s)) ==> 0.9402
--

-- Inside a `sym`:

function sym()
  return {counts={},mode=nil,most=0,n=0,_ent=nil}
end

-- Add `x` to a `sym`:

function symInc(t,x,   new,old)
  if x=="?" then return x end
  t._ent= nil
  t.n = t.n + 1
  old = t.counts[x]
  new = old and old + 1 or 1
  t.counts[x] = new
  if new > t.most then
    t.most, t.mode = new, x end
  return x
end

-- Remove `x` from a `sym`.

function symDec(t,x)
  t._ent= nil
  if t.n > 0 then
    t.n = t.n - 1
    t.counts[x] = t.counts[x] - 1
  end
  return x
end

-- Buld add to a `sym`:

function syms(t,f,       s)
  f=f or function(x) return x end
  s=sym()
  for _,x in pairs(t) do symInc(s, f(x)) end
  return s
end

-- Computing the entropy: don't recompute if you've
-- already done it before.

function symEnt(t,  p)
  if not t._ent then
    t._ent=0
    for x,n in pairs(t.counts) do
      p      = n/t.n
      t._ent = t._ent - p * math.log(p,2) end end
  return t._ent
end

function symXpect(i,j,   n)  
  n = i.n + j.n +0.0001
  return i.n/n * symEnt(i) + j.n/n * symEnt(j)
end
