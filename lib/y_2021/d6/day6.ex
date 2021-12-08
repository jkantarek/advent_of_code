defmodule AdventOfCode.Y2021.Day6 do
  @moduledoc """

  """

  @doc """
  Day 1 - Part 1

  ## Examples

    iex> AdventOfCode.Y2021.Day6.part1()
    388419

  """

  def part1() do
    setup()
    |> run_cycles(0, 80)
    |> length()
  end

  def setup() do
    AdventOfCode.etl_file(
      "lib/y_2021/d6/input.txt",
      &to_int/1,
      &AdventOfCode.split_comma/1
    )
  end

  def to_int(s) do
    {n, _s} = Integer.parse(s)
    n
  end

  def process_cycle_elem(v) when v == 0, do: [8, 6]
  def process_cycle_elem(v), do: [v - 1]

  def run_cycles(collection, current_cycle, end_cycle) when current_cycle == end_cycle,
    do: collection

  def run_cycles(collection, current_cycle, end_cycle) do
    collection
    |> Enum.flat_map(fn v ->
      process_cycle_elem(v)
    end)
    |> run_cycles(current_cycle + 1, end_cycle)
  end

  @doc """
  Day 6 - Part 2

  ## Examples

    iex> AdventOfCode.Y2021.Day6.part2()
    1740449478328

  """

  def part2() do
    setup()
    |> Enum.frequencies()
    |> merge_with_base()
    |> process_cycle_frequencies(0, 256)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.sum()
  end

  def merge_with_base(freqs) do
    %{0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0}
    |> Map.merge(freqs)
  end

  def process_cycle_frequencies(freqs, current_cycle, end_cycle) when current_cycle == end_cycle,
    do: freqs

  def process_cycle_frequencies(freqs, current_cycle, end_cycle) do
    next_freqs = %{
      0 => freqs[1],
      1 => freqs[2],
      2 => freqs[3],
      3 => freqs[4],
      4 => freqs[5],
      5 => freqs[6],
      6 => freqs[0] + freqs[7],
      7 => freqs[8],
      8 => freqs[0]
    }

    process_cycle_frequencies(next_freqs, current_cycle + 1, end_cycle)
  end
end
