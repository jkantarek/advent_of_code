defmodule AdventOfCode.Y2021.Day7 do
  @moduledoc """

  """

  @doc """
  Day 1 - Part 1

  ## Examples

    iex> AdventOfCode.Y2021.Day7.part1()
    340056

  """

  def part1() do
    res =
      setup()
      |> Enum.sort()

    target = Statistics.median(res) |> round()

    res
    |> Enum.reduce(0, fn start_pos, acc -> calculate_fuel(start_pos, target) + acc end)
  end

  def calculate_fuel(start_pos, target) when start_pos >= target, do: start_pos - target
  def calculate_fuel(start_pos, target), do: target - start_pos

  def setup() do
    AdventOfCode.etl_file(
      "lib/y_2021/d7/input.txt",
      &to_int/1,
      &AdventOfCode.split_comma/1
    )
  end

  def to_int(s) do
    {n, _s} = Integer.parse(s)
    n
  end

  @doc """
  Day 7 - Part 2

  ## Examples

    iex> AdventOfCode.Y2021.Day7.part2()
    nil

  """

  def part2() do
  end
end
