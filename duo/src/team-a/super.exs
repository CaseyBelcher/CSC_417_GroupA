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
# 	Attempt to find cut with argMin()
# 	If cut found, recurse cuts() on either side of cut
# 	If not found, rewrite the column according to current lo and hi values

defmodule M do
  import Enum


  def main do
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
    numColumns = Enum.to_list(Range.new(0, length(at(rows,0))))
    # create a list of columns instead of rows, because it will be easier to work with
    columns = List.foldl(numColumns, [], fn x, acc -> acc ++ [getColumn(x, rows)] end)

    # rewrite each column as neccessary using recursive cuts()
    # columns = map(columns, &cuts(&1))

    # printTable(columns, length(columns), 0, length(at(columns, 0))) #all columns are assumed to be of the same length
    printTable(columns, length(columns), 0, length(at(columns, 0))) #all columns are assumed to be of the same length


    # TODO: print out columns as a table again

  end


  # returns a list representing a column of the table, including header
  def getColumn(index, rows) do
    List.foldl(rows, [], fn x,
      acc ->
        cell = at(x, index)
        cond do
          (cell != nil and cell != "?") -> acc ++ [cell]
          true -> acc ++ []
        end
        # acc ++ [at(x, index)]
      end )
  end


  def cuts(column) do
    cond do
      # only work with independent variable columns (prefix is $)
      at(column, 0) |> String.at(0) == "$" ->

        IO.puts "\n-- #{at(column,0)} ----------"

        # convert column from strings to floats
        column = map(column, fn x ->
          float = Float.parse(x)
          cond do
            float != :error ->
              {floatValue, discard} = float
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
    IO.puts txt

    # return
    column
  end

  defmodule Num do
    defstruct hi: 0, lo: 0, mu: 0, m2: 0, n: 0, sd: 0, label: ""
  end


  def numInc(x, original) do
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


  # # TODO: print out columns as a table again
  # printTable(columns, length(columns), 0, length(at(columns, 0))) #all columns are assumed to be of the same length


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

end

M.main()


