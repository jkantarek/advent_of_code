defmodule AdventOfCode do
  @moduledoc """
  Documentation for `AdventOfCode`.
  """

  @doc """
  ETL Files from a new line dileneated file. it will turn an array based on how you transform each row

  ## Examples

      iex> AdventOfCode.etl_file("lib/input.txt", fn(s) -> s end)
      ["157", "148", "149"]

  """
  def etl_file(filename, etl_func) do
    {:ok, file} = File.read(filename)

    file
    |> String.split("\n")
    |> Enum.reject(fn elem -> elem == "" || is_nil(elem) end)
    |> Enum.map(fn s ->
      etl_func.(s)
    end)
  end
end
