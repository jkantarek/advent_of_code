defmodule Utils do
  def partition_at(top, bottom, count) when length(top) == count, do: {top, bottom}

  def partition_at(top, [], _count), do: {top, []}

  def partition_at(top, [first | rest], count) do
    partition_at([first] ++ top, rest || [], count)
  end
end
