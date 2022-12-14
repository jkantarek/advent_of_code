defmodule AdventOfCode do
  @moduledoc """
  Documentation for `AdventOfCode`.
  """

  @doc """
  ETL Files from a new line dileneated file. it will turn an array based on how you transform each row

  ## Examples

      iex> AdventOfCode.etl_file("lib/input.txt", fn(s) -> s end)
      ["157", "148", "149"]

      iex> AdventOfCode.etl_file("lib/input.txt", fn(s) -> s end, &AdventOfCode.split_newline/1, %{reject_blanks: false, reject_nils: true})
      ["157", "148", "149", ""]

  """
  def etl_file(
        filename,
        etl_func,
        split_func \\ &split_newline/1,
        opts \\ %{
          reject_blanks: true,
          reject_nils: true,
          with_index: false,
          with_double_index: false
        }
      ) do
    {:ok, file} = File.read(filename)

    file
    |> split_func.()
    |> Enum.reject(fn elem ->
      (opts[:reject_blanks] && elem == "") || (opts[:reject_nils] && is_nil(elem))
    end)
    |> mapper(etl_func, index_mapper(opts))
  end

  def index_mapper(%{with_index: true} = _o) do
    :index
  end

  def index_mapper(%{with_double_index: true} = _o) do
    :double
  end

  def index_mapper(_o) do
    :none
  end

  def mapper(payload, etl_func, :none) do
    payload
    |> Enum.map(fn s ->
      etl_func.(s)
    end)
  end

  def mapper(payload, etl_func, :index) do
    payload
    |> Enum.with_index()
    |> Enum.map(fn p ->
      etl_func.(p)
    end)
  end

  def mapper(payload, etl_func, :double) do
    payload
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {v, idx}, acc ->
      v
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {elem, i}, a ->
        Map.merge(a, %{{idx, i} => etl_func.({elem, idx, i})})
      end)
    end)
  end

  def split_newline(v) do
    v |> String.split("\n")
  end

  def split_comma(v) do
    v |> String.split(",")
  end
end
