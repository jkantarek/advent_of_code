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
    96592275

    iex> AdventOfCode.Y2021.Day7.exp_fuel(16, 5)
    66

    iex> AdventOfCode.Y2021.Day7.exp_fuel(1, 5)
    10

    iex> AdventOfCode.Y2021.Day7.exp_fuel(2, 5)
    6

  """

  def part2() do
    res =
      setup()
      |> Enum.sort()

    means = compute_mean_sum(res)
    means[:total]
  end

  def split_and_sum(type, value, res) do
    %{true: above, false: below} = res |> Enum.group_by(fn v -> v > value end)

    sum_above = sum_direct(above, value)
    sum_below = sum_direct(below, value)

    %{
      type: type,
      value: value,
      above: above,
      above_sum: sum_above,
      below: below,
      below_sum: sum_below,
      total: sum_above + sum_below,
      difference: sum_above - sum_below
    }
  end

  def compute_mean_sum(res) do
    mean = Statistics.mean(res) |> trunc()

    split_and_sum(:mean, mean, res)
  end

  def compute_median_sum(res) do
    median = Statistics.median(res) |> trunc()

    split_and_sum(:median, median, res)
  end

  # def find_target(median, freq, last_spend) do
  #   %{false: above, true: below} =
  #     freq
  #     |> Enum.group_by(fn {k, _v} -> k <= median end)
  #
  #   spend_lower = sum_grouping(below, median)
  #   spend_above = sum_grouping(above, median)
  #
  #   eval_median(median, above, below, spend_lower, spend_above, freq)
  # end
  #
  # def eval_median(median, above, below, spend_lower, spend_above, freq)
  #     when spend_lower == spend_above do
  # end

  def sum_direct(arr, target) do
    arr
    |> Enum.reduce(0, fn pos, acc ->
      exp_fuel(pos, target) + acc
    end)
  end

  def sum_grouping(group, target) do
    group
    |> Enum.reduce(0, fn {pos, count}, acc ->
      exp_fuel(pos, target) * count + acc
    end)
  end

  def exp_fuel(start_pos, end_pos) when start_pos <= end_pos do
    exp_fun(end_pos - start_pos)
  end

  def exp_fuel(start_pos, end_pos) do
    exp_fun(start_pos - end_pos)
  end

  def exp_fun(n) do
    (n * (n + 1) / 2) |> round()
  end
end
