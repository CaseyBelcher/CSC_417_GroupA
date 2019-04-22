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
    columns = map(columns, &cuts(&1))



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


end

M.main()


