# If running the following, know that I forgot the input actually looks like this:

# -- >dom----------
# |.. 0
# |.. |..0.29
# $atleast, >d, $done_percent, <ep, $learning_curve, <np, $nprod, $optimism, $pomposity, $productivity_exp, $productivity_new, $r, $to, $ts, >dom,!klass
# 4.02,0.61,6.87,1,6.19,16,3.77,60.6,94.12,7.85,0.98,355.39,62.57,88.97,0,..0.28
# 3.63,1,4.58,8,21.56,9,8.86,15.69,73.08,7.01,0.5,411.39,19.07,83.07,0.04,..0.28
# 4.02,89.32,6.87,16.96,6.19,0.04,3.77,60.6,94.12,7.85,0.98,266.68,62.57,88.97,0.07,..0.28
# 4.02,89.32,6.87,16.98,6.19,0.02,3.77,60.6,94.12,7.85,0.98,266.68,62.57,88.97,0.08,..0.28
# 4.02,89.32,6.87,16.98,6.19,0.02,3.77,60.6,94.12,7.85,0.98,266.68,62.57,88.97,0.1,..0.28
# 4.02,89.32,6.87,13.49,6.19,3.51,3.77,60.6,94.12,7.85,0.98,266.68,62.57,88.97,0.11,..0.28
# 4.02,89.32,6.87,16.64,6.19,0.36,3.77,60.6,94.12,7.85,0.98,266.68,62.57,88.97,0.12,..0.28


# Rather than just:

# $atleast, >d, $done_percent, <ep, $learning_curve, <np, $nprod, $optimism, $pomposity, $productivity_exp, $productivity_new, $r, $to, $ts, >dom,!klass
# 4.02,0.61,6.87,1,6.19,16,3.77,60.6,94.12,7.85,0.98,355.39,62.57,88.97,0,..0.28
# 3.63,1,4.58,8,21.56,9,8.86,15.69,73.08,7.01,0.5,411.39,19.07,83.07,0.04,..0.28
# 4.02,89.32,6.87,16.96,6.19,0.04,3.77,60.6,94.12,7.85,0.98,266.68,62.57,88.97,0.07,..0.28
# 4.02,89.32,6.87,16.98,6.19,0.02,3.77,60.6,94.12,7.85,0.98,266.68,62.57,88.97,0.08,..0.28
# 4.02,89.32,6.87,16.98,6.19,0.02,3.77,60.6,94.12,7.85,0.98,266.68,62.57,88.97,0.1,..0.28
# 4.02,89.32,6.87,13.49,6.19,3.51,3.77,60.6,94.12,7.85,0.98,266.68,62.57,88.97,0.11,..0.28
# 4.02,89.32,6.87,16.64,6.19,0.36,3.77,60.6,94.12,7.85,0.98,266.68,62.57,88.97,0.12,..0.28


# So we need to find a way to ignore those first couple of lines.


defmodule M do
  import Enum


  def main do
    rows = buildTable()

    # numColumns = a range of 0..numberOfColumns
    numColumns = Enum.to_list(Range.new(0, length(at(rows,0))))
    # create a list of columns instead of rows, because it'll be easier to work with
    columns = List.foldl(numColumns, [], fn x, acc -> acc ++ [getColumn(x, rows)] end)
    # rewrite each column as neccessary using recursive cuts()
    columns = map(columns, &cuts(&1))


    # TODO: print out columns as a table again

  end


  def buildTable do
    # z is a list of input lines, each one long string
    z = map(IO.stream(:stdio, :line), &(&1))

    # transform z into a list of lists of strings, i.e. a table
    List.foldl(z, [], fn x, acc -> acc ++ [String.split(x, ",") |> map(&String.trim/1)] end )
  end


  # returns a list representing a column of the table, including header
  def getColumn(index, rows) do
    List.foldl(rows, [], fn x, acc -> acc ++ [at(x, index)] end )
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


