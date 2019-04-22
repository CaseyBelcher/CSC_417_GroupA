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

--param: data = the table
-- param: goal = index of the goal / dom column (the last column) 
-- param: enough = arbitrary constant for size of segments 
function super(data,goal,enough,       rows,most,cohen)
  rows   = data.rows
  goal   = goal or #(rows[1])
  enough = enough or (#rows)^Lean.super.enough 

-- -------------------------------------------
-- This generates a print string for a band
-- that streches from `lo` to `hi`.


  local function band(c,lo,hi)
    if lo==1 then
      return "..".. rows[hi][c]
    elseif hi == most then
      return rows[lo][c]..".."
    else
      return rows[lo][c]..".."..rows[hi][c] end
  end

-- Find one best cut, as follows.
--
-- - First all everything to a _right_ counter
--   (abbreviated here as `r`).
-- - Then work from `lo` to `hi` taking away
--   values from the _right_ and adding them
--   to a _left_ counter (abbreviated here as `l`).
-- - Using the information in these _right_ and
--   _left_ counters, work out where the best `cut` is.
-- - If no such `cut` found, return `nil`.
--
-- Tehcnical note: actually, we run two _right_
-- and two _left_ counters:
--
-- - two for the independent column (`xl` and `xr`)
-- - and two for the goal column  (`yl` and `yr`)

  local function argmin(c,lo,hi, cohen,    
                          x,nl,nr,bestx,tmpx,
                          y,sl,sr,
                          cut) 
    nl,nr = num(), num()
    sl,sr = sym(), sym()
    
    -- get statistical info on this column and the goal column 
    for i=lo,hi do 
      numInc(nr, rows[i][c]) 
      symInc(sr, rows[i][goal]) end
    
    -- get entropy for the goal column? 
    bestx = symEnt(sr)
    
    -- if there is enough room for a cut within this range 
    if (hi - lo > 2*enough) then
      -- for every row in this range 
      for i=lo,hi do
        -- move a value from right to left for both columns 
        x = rows[i][c]
        y = rows[i][goal]
        numInc(nl, x); numDec(nr, x) 
        symInc(sl, y); symDec(sr, y) 
        
        -- if both sections have enough rows 
        if nl.n >= enough and nr.n >= enough then
          -- if the diff in values in target column is greater than some constant 
          if nl.hi - nl.lo > cohen then
            -- if the diff in values in goal column is greater than some constant 
            if nr.hi - nr.lo > cohen then
              -- weird calculation 
              tmpx = symXpect(sl,sr) * Lean.super.margin
              if tmpx < bestx then
                -- set cut to the row index we just added to the left 
                cut,bestx = i, tmpx end end end end end end 
    return cut
  end

-- If we can find one good cut:
--
-- - Then recurse to, maybe, find other cuts. 
-- - Else, rewrite all values in `lo` to `hi` to
--   the same string `s` representing the range..

  local function cuts(c,lo,hi,pre,cohen,       cut,txt,s,mu)
    txt = pre..rows[lo][c]..".."..rows[hi][c]
    -- attempt to find cut in range 
    cut,mu = argmin(c,lo,hi,cohen)
    -- if found, recurse on both sides of the cut 
    if cut then
      fyi(txt)
      cuts(c,lo,   cut, pre.."|.. ",cohen)
      cuts(c,cut+1, hi, pre.."|.. ",cohen)
    -- if not found, rewrite the column according to the current lo and hi values 
    else
      s = band(c,lo,hi)
      fyi(txt)
      for r=lo,hi do
        rows[r][c]=s end end
  end

-- Our data sorts such that all the "?" unknown values
-- are pushed to the end. This function tells us
-- where to stop so we don't run into those values.

  function stop(c,t)
    for i=#t,1,-1 do if t[i][c] ~= "?" then return i end end
    return 0
  end

-- For all numeric indpendent columns, sort it and 
-- try to cut it. Then `dump` the results to standard output.

  -- for every independent column 
  for _,c  in pairs(data.indeps) do
    -- if there are entries in this column 
    if data.nums[c] then
      -- sorts the rows on column `c`.
      ksort(c,rows) 
      -- find what row the data actually stops 
      most = stop(c,rows)
      
      -- get statistical data on this column 
      local all = num()
      for i=1,#data.rows  do numInc(all, rows[i][c]) end
      
      -- just logging info 
      fyi("\n-- ".. data.name[c] .. " ----------")
      
      -- for this column, perform cuts and rewrite 
      cuts(c,1,most,"|.. ",all.sd*Lean.super.cohen) end end
  
  -- print header 
  print(gsub( cat(data.name,", "), 
              "%$","")) -- dump dollars since no more nums
  -- print rows 
  dump(rows)
end

-- Main function, if this is called top-level.

return {main=function() return super(rows()) end}


