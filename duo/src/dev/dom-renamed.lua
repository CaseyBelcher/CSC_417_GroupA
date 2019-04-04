
require "lib"
require "rows"


function numNorm(column, x)
  -- If ignored (?), then give it a 50/50 weight, otherwise give it the score
  return x == "?" and 0.5 or (x - column.lo) / (column.hi - column.lo + 10^-32)
end

-- True if row1 dominates row2
function dom(table ,row1,row2,     n,a0,a,b0,b,s1,s2)
  s1, s2, n = 0, 0, 0
  for _ in pairs(table.w) do
    -- Finds the count of table.w
    n = n + 1
  end
  -- Iterate over each column's "w" value
  -- We think "w" is either "?" or a number
  
  -- i=column index of the row 
  -- w is either -1 or 1 for min or max 
  for i, w in pairs(table.w) do
    -- Column i of row 1
    -- Can be either a "?" or a number (probably)
    a0 = row1[i]
    -- Column i of row 2
    b0 = row2[i]
    a  = numNorm(table.column_data[i], a0)
    b  = numNorm(table.column_data[i], b0)
    s1 = s1 - 10^(w * (a-b)/n)
    s2 = s2 - 10^(w * (b-a)/n)
  end
  return s1/n < s2/n 
end

function doms(table,  n,c,row1,row2,s)
  -- Number of rows choosing to compare against this row
  n= Lean.dom.samples
  -- Index where dom is supposed to go
  -- #table.name == length of table
  c= #table.name + 1
  print(cat(t.name,",") .. ",>dom")
  -- Iterate each row
  for r1=1,#table.rows do
    row1 = table.rows[r1]
    -- Initializing dom score
    row1[c] = 0
    for s=1,n do
     row2 = another(r1,table.rows) 
     -- Intermediary dom score. 1/n => dominates this row, otherwise 0 (doesn't dominate)
     s = dom(table, row1, row2) and 1/n or 0
     row1[c] = row1[c] + s
    end
  end
  dump(table.rows)
end

function mainDom() doms(rows()) end

return {main = mainDom}