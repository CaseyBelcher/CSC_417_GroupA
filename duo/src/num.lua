--vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 


-- ## Example

--
--      n = nums{ 4,10,15,38,54,57,62,83,100,100,174,190,
--                215,225,233,250,260,270,299,300,306,
--                333,350,375,443,475,525,583,780,1000}
--      print(n.mu, n.sd) ==> 270.3, 231.946
--    
-- Inside a `num`:
function num(txt)  
    return {n=0, mu=0, m2=0, sd=0, id = id(), 
            lo=10^32, hi=-1*10^32, txt=txt,
            w=1}
end
--
-- Bulk add to a `num`:

function nums(t,f,      n)
  f=f or function(x) return x end
  n=num()
  for _,x in pairs(t) do numInc(n, f(x)) end
  return n
end

-- Incremenally, add `x` to a `num`.
-- This is [Welford's algorithm](https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Online_algorithm)

function numInc(t,x,    d) 
  if x == "?" then return x end
  t.n  = t.n + 1
  d    = x - t.mu
  t.mu = t.mu + d/t.n
  t.m2 = t.m2 + d*(x - t.mu)
  if x > t.hi then t.hi = x end
  if x < t.lo then t.lo = x end
  if (t.n>=2) then 
    t.sd = (t.m2/(t.n - 1 + 10^-32))^0.5 end
  return x  
end

-- Aside: this can be generalized to 
-- higher order moments; e.g. to calcuate
-- [skew and kurtosis](https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Higher-order_statistics). 
--
-- ![](https://www.scratchapixel.com/images/upload/monte-carlo-methods/skew.png?)
--
-- Note that mean, variance, skew,
-- kurtosis may not be enough to characterize
-- real world data sets. e.g
-- see [these plots](https://raw.githubusercontent.com/txt/fss17/master/img/notnorm8.png) of CPU wait times for disk access time for numerous SQL queries from one program on one system. So whenever I can, I cluster the data and build
-- different models for different small local regions.
--
-- Remove `x` from a `num`. Note: due to
-- the approximation of this method, this
-- gets inaccurate for small `x` numbers
-- and very small sample sizes (small `n`,
-- say, less than 5)

function numDec(t,x,    d) 
  if (x == "?") then return x end
  if (t.n == 1) then return x end
  t.n  = t.n - 1
  d    = x - t.mu
  t.mu = t.mu - d/t.n
  t.m2 = t.m2 - d*(x- t.mu)
  if (t.n>=2) then
    t.sd = (t.m2/(t.n - 1 + 10^-32))^0.5 end
  return x
end

-- Normalization

function numNorm(t,x,     y) 
  return x=="?" and 0.5 or (x-t.lo) / (t.hi-t.lo + 10^-32)
end

-- Likiehood

function numPdf(t,x)
  return math.exp(-1*(x - t.mu)^2/(2*t.sd^2)) *
         1 / (t.sd * ((2*math.pi)^0.5))
end


-- Misc

function numXpect(i,j,   n)  
  n = i.n + j.n +0.0001
  return i.n/n * i.sd+ j.n/n * j.sd
end



