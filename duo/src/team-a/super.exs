defmodule M do
  import Enum


  def main do
    # list of input lines, each one long string
    lines = filter(IO.stream(:stdio, :line), fn x ->
      first = String.at(x, 0)
      cond do
        (first != "-" and first != "|") -> true
        true -> false
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
          cell != nil -> acc ++ [cell]
          true -> acc ++ []
        end
        # acc ++ [at(x, index)]
      end )
  end


  def cuts(column) do
    cond do
      # only work with independent variable columns (prefix is $)
      at(column, 0) |> String.at(0) == "$" ->
        # TODO:
        IO.puts "stuff will go here"
      true -> ""
    end

  end


end

M.main()


