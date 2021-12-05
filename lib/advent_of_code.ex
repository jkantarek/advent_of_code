defmodule AdventOfCode do
  @moduledoc """
  Documentation for `AdventOfCode`.
  """

  @doc """
  ETL Files from a new line dileneated file. it will turn an array based on how you transform each row

  ## Examples

      iex> AdventOfCode.etl_file("lib/input.txt", fn(s) -> s end)
      ["157", "148", "149"]

      iex> AdventOfCode.etl_file("lib/input.txt", fn(s) -> s end, %{reject_blanks: false, reject_nils: true})
      ["157", "148", "149", ""]

  """
  def etl_file(filename, etl_func, opts \\ %{reject_blanks: true, reject_nils: true}) do
    {:ok, file} = File.read(filename)

    file
    |> String.split("\n")
    |> Enum.reject(fn elem ->
      (opts[:reject_blanks] && elem == "") || (opts[:reject_nils] && is_nil(elem))
    end)
    |> Enum.map(fn s ->
      etl_func.(s)
    end)
  end
end
