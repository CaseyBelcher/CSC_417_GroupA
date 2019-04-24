# run with needed dependencies:
#
# mix deps.get
# mix deps.compile
# mix run super.exs < superInput
#
#
# original pipeline super implementation:
#
# For each independent variable column (prefix is $):
# 	Sort the rows based on that column
# 	Call recursive cuts() on that column
# cuts():
# 	Attempt to find cut with ()
# 	If cut found, recurse cuts() on either side of cut
# 	If not found, rewrite the column according to current lo and hi values

defmodule M do
  import Enum

  defmodule Sym do
    defstruct counts: %{}, mode: nil, most: 0, n: 0, _ent: nil
  end         
                    
  defmodule Num do
    defstruct hi: 0, lo: 0, mu: 0, m2: 0, n: 0, sd: 0, label: ""
  end
  
  defmodule Storage do
    def begin() do
      Agent.start_link(fn -> %{} end, name: __MODULE__)
    end
      
    def get() do
      Agent.get(__MODULE__, fn x -> x end)
    end
      
    def get(key) do
      get()[key]
    end

    def set(key, value) do
      Agent.update(__MODULE__, fn x -> Map.put(x, key, value) end)
    end
  end

  def main() do
    Storage.begin
    # list of input lines, each one long string
    lines = filter(IO.stream(:stdio, :line), fn x ->
      first = String.at(x, 0)
      cond do
        (first != "-" and first != "|") -> true
        true ->
          IO.write x
          false
      end end )

    # transform lines into a list of lists of strings, i.e. a table
    rows = List.foldl(lines, [], fn x, acc -> acc ++ [String.split(x, ",") |> map(&String.trim/1)] end )

    # numColumns = a range of 0..numberOfColumns
    numColumns = Enum.to_list(Range.new(0, rows |> at(0) |> length))
    # create a list of columns instead of rows, because it will be easier to work with
    columns = List.foldl(numColumns, [], fn x, acc -> acc ++ [getColumn(x, rows)] end)
    goalColumn = columns |> at(length(columns) - 2) |> map(fn x ->
          float = Float.parse(x)
          cond do
            float != :error ->
              {floatValue, _} = float
              floatValue
            true -> x
          end
        end)

    Storage.set(:goalColumn, goalColumn)
    Storage.set(:margin, 1.05)

    # rewrite each column as neccessary using recursive cuts()
    columns = map(columns, &cuts(&1))



    # TODO: print out columns as a table again
    printTable(columns, length(columns), 0, length(at(columns, 0))) #all columns are assumed to be of the same length
    

  end

  ########## jank/broken code ##########
  #prints the table when given a list of columns and the row to start on
  def printTable(cols, numCols, row, rowCount) do
    cond do
      row < rowCount ->
        printTableHelper(cols, numCols, row, rowCount)
      true -> ""
    end
  end

  #This method is used by printTable in its effort to print the table. It prints the
  #value at the given row and col, then calls printRow with the value of col incrimented by 1
  #param cols       : the list of columns in the table
  #param numCols    : the number of columns in the table
  #param row        : the row of the cell to print
  #param rowCount   : the number of rows in the table
  def printTableHelper(cols, numCols, row, rowCount) do
    printRow(cols, 0, numCols, row)
    printTable(cols, numCols, row + 1, rowCount)
  end

  #prints a specific row in the table
  #param cols      : the list of columns in the table
  #param col       : the column of the cell to print
  #param numCols   : the number of columns in the table
  #param row       : the row of the cell to print
  def printRow(cols, col, numCols, row) do
    cond do
      col < numCols ->
        printRowHelper(cols, col, numCols, row)
      true -> IO.puts "\n"
    end
  end

  #This method is used by printRow in its effort to print a single row of the table.
  #It prints the value at the given row and col, then calls printRow with the value
  #of col incrimented by 1
  #param cols: the list of columns in the table
  #param col: the column of the cell to print
  #param numCols: the number of columns in the table
  #param row: the row of the cell to print
  def printRowHelper(cols, col, numCols, row) do
    IO.write( at( at(cols, col), row ) )
    printRow(cols, col + 1, numCols, row)
  end
  ########## end jank/broken code ##########

  # returns a list representing a column of the table, including header
  def getColumn(index, rows) do
    List.foldl(rows, [], fn x, acc ->
        cell = at(x, index)
        cond do
          (cell != nil and cell != "?") -> acc ++ [cell]
          true -> acc
        end
        # acc ++ [at(x, index)]
      end )
  end


  def cuts(column) do
    cond do
      # Only work with independent variable columns (prefix is $)
      at(column, 0) |> String.at(0) == "$" ->

        IO.puts "\n-- #{at(column,0)} ----------"

        # convert column from strings to floats
        column = map(column, fn x ->
          float = Float.parse(x)
          cond do
            float != :error ->
              {floatValue, _} = float
              floatValue
            true -> x
          end
        end)

        # cohen is just a magic number he uses for calculation
        cohen = 0.3 * Statistics.stdev(tl(column))

        #return
        cutsRecursion(column, 1, length(column) - 1,  "|.. ", cohen)

      true -> column
    end

  end

  def cutsRecursion(column, lo, hi, preString, cohen) do
    # -- $nprod ----------
    # |.. 0.1..9.93
    # |.. |.. 0.1..2.55
    # |.. |.. |.. 0.1..2.02
    # |.. |.. |.. 2.02..2.55
    # |.. |.. 2.56..9.93

    # txt = pre..rows[lo][c]..".."..rows[hi][c]

    txt = "#{preString}#{at(column,lo)}..#{at(column,hi)}"
    # IO.puts txt
      histr = column |> at(hi) |> Float.to_string
      lostr = column |> at(lo) |> Float.to_string
      
      cut = argMin(column, lo, hi, cohen)
    if cut do
       IO.puts preString <> lostr <> ".." <> histr
      
      column = cutsRecursion(column, lo, cut, preString <> "|.. ", cohen)
      cutsRecursion(column,cut+1, hi, preString <> "|.. ", cohen)
    else 
     
     # Remap column
      s = cond do
        lo == 1 -> ".." <> histr
        hi == length(column) - 2 -> lostr <> ".."
        true -> lostr <> ".." <> histr
      end
      map(column, fn x -> s end)
    end
  end
    

  def argMin(column, lo, hi, cohen) do
    # x,nl,nr,bestx,tmpx, y,sl,sr, cut
    Storage.set(:cut, false)
    goalColumn = Storage.get(:goalColumn)     
         
    nl = %Num{}
    nr = %Num{}
    sl = %Sym{}
    sr = %Sym{}
                 
    # magic number in config.lua 
    enough = 0.5
                                   
    range = Range.new(lo, hi)
    nr = Enum.reduce(range, nr, fn i, acc -> numInc(acc, column |> at(i)) end)
    goalColumn |> at(1)
    sr = Enum.reduce(range, sr, fn i, acc -> symInc(acc, goalColumn |> at(i)) end)

    # bestx = symEnt(sr)
    # Storage.set(:bestx, tmpx)
    sr = symEnt(sr)
    Storage.set(:bestx, sr._ent)
      
    
    if hi - lo > 2 * enough do
      
      for i <- range do 
    
        x = column |> at(i)
        y = goalColumn |> at(i)
        
        # Im pretty sure this is how you can do it casey
        Range.new(1, i) |> Enum.reduce(%{nl: nl, sl: sl, nr: nr, sr: sr}, fn i, acc ->
          nl = numInc(acc.nl, x)
          sl = symInc(acc.sl, y)
          nr = numDec(acc.nr, x)
          sr = symDec(acc.sr, y)
          
          if nl.n >= enough
            and nr.n >= enough
            and nl.hi - nl.lo > cohen
            and nr.hi - nr.lo > cohen do
              {tmpx, sl, sr} = symXpect(sl, sr)
                                       
              tmpx = tmpx * Storage.get(:margin)   
             # Storage.get(:bestx) |> IO.inspect
             # tmpx |> IO.inspect
             # symXpect(sl, sr) |> IO.inspect
              # System.halt
              if tmpx < Storage.get(:bestx) do
                Storage.set(:cut, i)
                Storage.set(:bestx, tmpx)
              end
          end
                                
          %{nl: nl, sl: sl, nr: nr, sr: sr}
        end)
      end
    end
    Storage.get(:cut)
  end

  # local function argmin(c,lo,hi, cohen,    
  #                         x,nl,nr,bestx,tmpx,
  #                         y,sl,sr,
  #                         cut) 
  #   nl,nr = num(), num()
  #   sl,sr = sym(), sym()
  #   
  #   -- get statistical info on this column and the goal column 
  #   for i=lo,hi do 
  #     numInc(nr, rows[i][c]) 
  #     symInc(sr, rows[i][goal]) end
  #   
  #   -- get entropy for the goal column? 
  #   bestx = symEnt(sr)
  #   
  #   -- if there is enough room for a cut within this range 
  #   if (hi - lo > 2*enough) then
  #     -- for every row in this range 
  #     for i=lo,hi do
  #       -- move a value from right to left for both columns 
  #       x = rows[i][c]
  #       y = rows[i][goal]
  #       numInc(nl, x); numDec(nr, x) 
  #       symInc(sl, y); symDec(sr, y) 
  #       
  #       -- if both sections have enough rows 
  #       if nl.n >= enough and nr.n >= enough then
  #         -- if the diff in values in target column is greater than some constant 
  #         if nl.hi - nl.lo > cohen then
  #           -- if the diff in values in goal column is greater than some constant 
  #           if nr.hi - nr.lo > cohen then
  #             -- weird calculation 
  #             tmpx = symXpect(sl,sr) * Lean.super.margin
  #             if tmpx < bestx then
  #               -- set cut to the row index we just added to the left 
  #               cut,bestx = i, tmpx end end end end end end 
  #   return cut
  # end


# function symInc(t,x,   new,old)
  #   if x=="?" then return x end
  #   t._ent= nil
  #   t.n = t.n + 1
  #   old = t.counts[x]
  #   new = old and old + 1 or 1
  #   t.counts[x] = new
  #   if new > t.most then
  #      t.most, t.mode = new, x end
  #   return x
  # end  
  
  def symInc(t, x) do
    # if x == "?" do x end
    t = %{t | _ent: nil, n: t.n + 1}
    # IO.inspect(t.counts)


    
    #new = if t.counts == {} do 1 else (t.counts |> at(x)) + 1 end
    
    
    # t = %{t | counts: put_elem(t.counts, x, new)}
    t = %{t | counts: Map.put(t.counts, x, Map.get(t.counts, x, 0) + 1)}
    new = Map.get(t.counts, x)
      
    if new > t.most do
       %{t | most: new, mode: x}
    else
      t
    end
    
    
    # check if key in t.counts, if not, set new to 1, if so, add 1
    
    
  end
    
 # function symDec(t,x)
 #   t._ent= nil
 #   if t.n > 0 then
 #      t.n = t.n - 1
 #      t.counts[x] = t.counts[x] - 1
 #   end
 #   return x
 # end
  
  def symDec(t, x) do
    t = %{t | _ent: nil}
    t = if t.n > 0 do 
      %{t | n: t.n - 1, counts: Map.put(t.counts, x, Map.get(t.counts, x) - 1)}
      # %{t | n: t.n - 1, counts: put_elem(t.counts, x, elem(t.counts, x) - 1)}
    end
    t
  end
    
    
  # function symEnt(t,  p)
  #   if not t._ent then
  #     t._ent=0
  #     for x,n in pairs(t.counts) do
  #       p      = n/t.n
  #       t._ent = t._ent - p * math.log(p,2) end end
  #   return t._ent
  # end

  def symEnt(t) do
    %{t | _ent: if t._ent do t._ent else
      List.foldl(t.counts |> Map.values |> Enum.reverse, 0, fn n, acc ->
        tmp = t.n + 0.0001
                 
        p = n/tmp
          
        acc - p * :math.log(p + 2)
        end)
    end
      }
  end

  # function symXpect(i,j,   n)  
  #   n = i.n + j.n +0.0001
  #   return i.n/n * symEnt(i) + j.n/n * symEnt(j)
  # end

  def symXpect(i, j) do
    n = i.n + j.n + 0.0001
    ient = symEnt(i)
    jent = symEnt(j)
    
    {i.n/n * ient._ent + j.n/n * jent._ent, ient, jent}
  end

  def numInc(original, x) do
    original = %{original | n: original.n + 1}
    d = x - original.mu
    original = %{original | 
      mu: original.mu + d/original.n,
      m2: original.m2 + d * (x - original.mu)
    }
    %{original |
      hi: (if x > original.hi, do: x, else: original.hi),
      lo: (if x < original.lo, do: x, else: original.lo),
      sd: (if original.n >= 2, do: (original.m2/(original.n-1 + :math.pow(10, -32))) |> :math.pow(0.5), else: original.sd)
    }
  end

   # t here is self 
   #   function numDec(t,x) 
   # if (t.n == 1) then return x end
   # t.n  = t.n - 1
   # d    = x - t.mu
   # t.mu = t.mu - d/t.n
   # t.m2 = t.m2 - d*(x- t.mu)
   # if (t.n>=2) then
   #   t.sd = (t.m2/(t.n - 1 + 10^-32))^0.5 end
   # return x
   #    end
    
        
  def numDec(original, x) do 
    cond do
      original.n == 1 -> original
      true ->
        d = x - original.mu
        original = %{original | n: original.n - 1}
        original = %{original | mu: original.mu - d/original.n }
        original = %{original | m2: original.m2 - d*(x-original.mu)}
        %{original | sd: (if original.n >= 2, do: (original.m2/(original.n - 1 + :math.pow(10, -32))) |> abs |> :math.pow(0.5), else: original.sd)}
    end    
  end
end

M.main()