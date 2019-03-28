--vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

require "num"
require "sym"

-- ## Example 
-- This code handles tables of data, like the following.
--
--     outlook, $temp, <humid, wind, !play
--     over,	64,	65,	TRUE,	yes
--     over,	64,	65,	TRUE,	yes
--     over,	72,	90,	TRUE,	yes
--     over,	83,	86,	FALSE,	yes
--     sunny,	69,	70,	FALSE,	yes
--     sunny,	69,	70,	FALSE,	yes
--     rainy,	65,	70,	TRUE,	no
--     sunny,	75,	70,	TRUE,	yes
--     sunny,	75,	70,	TRUE,	yes
--     sunny,	85,	85,	FALSE,	no
--     rainy,	71,	91,	TRUE,	no
--     rainy,	70,	96,	FALSE,	yes
--     rainy,	70,	96,	FALSE,	yes
--
-- Note that first row describes each columns.
-- The special sympols `$<>!` will be defined below.
--
-- Tables can be created two ways
--
-- - From ram data: using the function `header` and `row` to handle
--   the first, then subsequent lines
-- - From disk data: using `rows` which internally calls `header` and `row`.
--
-- These functions are discussed further, below.
--
-- ## Inside  a `data`
--
-- A `data` object holds lists of various things, including `rows` of the actual data
-- plus some meta knowledge. 
--
-- - E.g. `name[c]` is the name of column `c`. 
-- - Some columns are goals we want to achienge and each of
--   those has a weight `w` (and `w[c]==-1` means _minimize_
--   and w[c]==1 means _maximize_).
-- - `Data` may have one (and only) one `class` column.

function data()
  return {w={}, syms={}, nums={}, class=nil, 
          rows={}, name= {}, col={}, _use={}} 
end

-- Columns can be `indep`endent or `dep`endent (and the goal
-- of learning is often to find what parts of the former
-- predict for the latter).

function indep(t,c) return not t.w[c] and t.class ~= c end
function dep(t,c)   return not indep(t,c) end

-- ## Making `data`
-- ### Step1: `header`

-- The function `header` reads and processes special symbols
-- that define a table.
--
-- - '<' is a dependent goal to be maximized (it is also numeric);
-- - '>' is a dependent goal to be minimized (it is also numeric);
-- - '$' is an independent  numeric colum;
-- - '!' is a class column (and is not numeric).

function header(cells,t,       c,w)
  t = t or data()
  t.indeps = {}
  for c0,x in pairs(cells) do
    if not x:match("%?")  then
      c = #t._use+1
      t._use[c] = c0
      t.name[c] = x
      t.col[x]  = c
      if x:match("[<>%$]") 
	 then t.nums[c] = num() 
	 else t.syms[c] = sym() 
      end 
      if     x:match("<") then t.w[c]  = -1 
      elseif x:match(">") then t.w[c]  =  1  
      elseif x:match("!") then t.class =  c 
      else   t.indeps[ #t.indeps+1 ] = c end end end
  return t
end

-- For example, the above example call to `header` initializes
-- a `data` with the following structure. 
-- Note that columns 2 and 3
--    have each been given a [`num`](num) object or
--    a [`sym`](sym) object (we will use those to
--    collect statistics on each column). 
-- Also, observe how
--    column three has a weight of `w[3]==-1`.

--
--        _use:
--        |  1: 1
--        |  2: 2
--        |  3: 3
--        |  4: 4
--        |  5: 5
--        class: 5
--        name:
--        |  1: outlook
--        |  2: $temp
--        |  3: <humid
--        |  4: wind
--        |  5: !play
--        nums:
--        |  2:  <an empyy num>
--        |  3:  <an empty num>
--        rows:
--        syms:
--        |  1:  <an empty sym>
--        |  4:  <an empty sym>
--        |  5:  <an empty sym>
--        w:
--        |  3: -1
--

-- Another thing to observe is that the `rows` and `syms`
-- and `nums` are empty.
-- Why? Because we have yet to add any data to this `data`.
-- That task is handled by `row`.


-- ### Step2: Add a `row`
-- The only tricky bits of adding a row is handling the 
-- string to number conversions, and when to skip
-- cells with an unknown value.

function row(t,cells,     x,r)
  r= #t.rows+1
  t.rows[r] = {}
  for c,c0 in pairs(t._use) do
    x = cells[c0]
    if x ~= "?" then
      if t.nums[c] then 
	      x = tonumber(x)
        numInc(t.nums[c], x)
      else
	      symInc(t.syms[c], x)
    end end
    t.rows[r][c] = x  end
  return t
end  

function clone(data0, rows,   data1)
   data1 = header(data0.name)
   for _,cells in pairs(rows or data0.rows) do 
     row(data1, cells) end
   return data1
end

-- ## Making `data` from Ram 
--
-- Reading data from disk, is handled by the
-- `rows` function (that sets some defaults), after
-- which time it calls `rows1` to do the actually
-- stream over the disk data. 

function rows1(stream, t,f0,f,   first,line,cells)
  first,line = true,io.read()
  while line do
    line= line:gsub("[\t\r ]*","")
              :gsub("#.*","")
    cells = split(line)
    line = io.read()
    if #cells > 0 then
      if first then f0(cells,t) else f(t,cells) end end
      first = false
  end 
  io.close(stream)
  return t
end

function rows(file,t,f0,f,      stream,txt,cells,r,line)
  return rows1( file and io.input(file) -- reading from some specified file
                      or io.input(),    -- reading from standard input
                t  or data(), f0 or header, f or row) end 

-- ## Making `data` from Ram 
-- Note that if your data
-- was in RAM, you would **not** use `rows`. Rather,
-- your code would:
--
-- - would call `header` to create a `data`,
-- - then call `row` for each row of data.
--
-- For example, to select all rows from `old` whose last cells is `happy`...
--   
--     new = header(old.names)
--     for _,cells in pairs(old.rows) do
--        if cells[#cells] == 'happy' then
--            row(new, cells) end end
