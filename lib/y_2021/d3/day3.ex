defmodule AdventOfCode.Y2021.Day3 do
  @moduledoc """

  --- Day 3: Binary Diagnostic ---

  The submarine has been making some odd creaking noises, so you ask it to produce a diagnostic report just in case.

  The diagnostic report (your puzzle input) consists of a list of binary numbers which, when decoded properly, can tell you many useful things about the conditions of the submarine. The first parameter to check is the power consumption.

  You need to use the binary numbers in the diagnostic report to generate two new binary numbers (called the gamma rate and the epsilon rate). The power consumption can then be found by multiplying the gamma rate by the epsilon rate.

  Each bit in the gamma rate can be determined by finding the most common bit in the corresponding position of all numbers in the diagnostic report. For example, given the following diagnostic report:

  00100
  11110
  10110
  10111
  10101
  01111
  00111
  11100
  10000
  11001
  00010
  01010

  Considering only the first bit of each number, there are five 0 bits and seven 1 bits. Since the most common bit is 1, the first bit of the gamma rate is 1.

  The most common second bit of the numbers in the diagnostic report is 0, so the second bit of the gamma rate is 0.

  The most common value of the third, fourth, and fifth bits are 1, 1, and 0, respectively, and so the final three bits of the gamma rate are 110.

  So, the gamma rate is the binary number 10110, or 22 in decimal.

  The epsilon rate is calculated in a similar way; rather than use the most common bit, the least common bit from each position is used. So, the epsilon rate is 01001, or 9 in decimal. Multiplying the gamma rate (22) by the epsilon rate (9) produces the power consumption, 198.

  Use the binary numbers in your diagnostic report to calculate the gamma rate and epsilon rate, then multiply them together. What is the power consumption of the submarine? (Be sure to represent your answer in decimal, not binary.)


  ## Examples

      iex> AdventOfCode.Y2021.Day3.part1()
      1092896

  """

  def part1() do
    parse_file()
    |> compute_gamma_eps()
  end

  def compute_gamma_eps(columns) do
    columns
    |> Enum.map(fn col ->
      Enum.frequencies(col)
      |> get_max_val()
    end)
    |> build_gamma_eps()
    |> solve()
  end

  def build_gamma_eps(gamma) do
    eps =
      gamma
      |> Enum.map(fn dig ->
        case dig do
          0 -> 1
          1 -> 0
        end
      end)

    [gamma, eps]
  end

  def solve([gamma, eps]) do
    [gamma, eps]
    |> Enum.reduce(1, fn arr, acc ->
      {bin_int, ""} = Enum.join(arr) |> Integer.parse(2)
      acc * bin_int
    end)
  end

  def get_max_val(%{0 => zeros, 1 => ones}) when zeros > ones, do: 0
  def get_max_val(%{0 => zeros, 1 => ones}) when zeros < ones, do: 1

  def solve_gamma(weights, rows) do
    rows
    |> Enum.map(fn row -> row ++ weights end)
  end

  def parse_file() do
    AdventOfCode.etl_file("lib/y_2021/d3/input.txt", &parse_row/1)
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def parse_row(s) do
    s
    |> String.split("")
    |> Enum.reduce([], fn ss, acc ->
      if ss != "" do
        acc ++ [get_int(Integer.parse(ss), s)]
      else
        acc
      end
    end)
  end

  defp get_int({n, ""}, _), do: n

  def part2() do
  end
end
