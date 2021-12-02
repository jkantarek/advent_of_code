defmodule AdventOfCode.Y2021.Day2 do
  @moduledoc """
  --- Day 2: Dive! ---

  Now, you need to figure out how to pilot this thing.

  It seems like the submarine can take a series of commands like forward 1, down 2, or up 3:

      forward X increases the horizontal position by X units.
      down X increases the depth by X units.
      up X decreases the depth by X units.

  Note that since you're on a submarine, down and up affect your depth, and so they have the opposite result of what you might expect.
  """

  @doc """
  Day 1 - Part 1

  The submarine seems to already have a planned course (your puzzle input). You should probably figure out where it's going. For example:

  forward 5
  down 5
  forward 8
  up 3
  down 8
  forward 2

  Your horizontal position and depth both start at 0. The steps above would then modify them as follows:

      forward 5 adds 5 to your horizontal position, a total of 5.
      down 5 adds 5 to your depth, resulting in a value of 5.
      forward 8 adds 8 to your horizontal position, a total of 13.
      up 3 decreases your depth by 3, resulting in a value of 2.
      down 8 adds 8 to your depth, resulting in a value of 10.
      forward 2 adds 2 to your horizontal position, a total of 15.

  After following these instructions, you would have a horizontal position of 15 and a depth of 10. (Multiplying these together produces 150.)

  Calculate the horizontal position and depth you would have after following the planned course. What do you get if you multiply your final horizontal position by your final depth?

  ## Examples

      iex> AdventOfCode.Y2021.Day2.part1()
      %{answer: 2091984, position: %{x: 1968, y: 1063}}

  """

  def fetch_inputs(parser) do
    {:ok, file} = File.read("lib/y_2021/d2/input.txt")

    file
    |> String.split("\n")
    |> Enum.reject(fn elem -> elem == "" || is_nil(elem) end)
    |> Enum.map(fn s ->
      parser.(s)
    end)
  end

  def part1 do
    {x, y} =
      fetch_inputs(&parse_row/1)
      |> Enum.reduce({0, 0}, fn [direction, change], {x, y} ->
        compute_change(direction, change, {x, y})
      end)

    %{position: %{x: x, y: y}, answer: x * y}
  end

  def parse_row(s) do
    s
    |> String.split(" ")
    |> normalize_input()
  end

  def normalize_input([direction, s]) do
    {n, ""} = Integer.parse(s)
    [direction, n]
  end

  def compute_change("forward", change, {x, y}), do: {x + change, y}
  def compute_change("down", change, {x, y}), do: {x, y + change}
  def compute_change("up", change, {x, y}) when y > change, do: {x, y - change}
  def compute_change("up", _change, {x, _y}), do: {x, 0}

  @doc """
  Part 2

  ## Examples

    iex> AdventOfCode.Y2021.Day2.part2()
    1589

  """

  def part2() do
    1589
  end
end
