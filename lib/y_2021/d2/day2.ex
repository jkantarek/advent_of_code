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
  def part1 do
    {x, y} =
      AdventOfCode.etl_file("lib/y_2021/d2/input.txt", &parse_row/1)
      |> Enum.reduce({0, 0}, fn [direction, change], {x, y} ->
        compute_change(direction, change, {x, y})
      end)

    %{position: %{x: x, y: y}, answer: x * y}
  end

  defp parse_row(s) do
    s
    |> String.split(" ")
    |> normalize_input()
  end

  defp normalize_input([direction, s]) do
    {n, ""} = Integer.parse(s)
    [direction, n]
  end

  defp compute_change("forward", change, {x, y}), do: {x + change, y}
  defp compute_change("down", change, {x, y}), do: {x, y + change}
  defp compute_change("up", change, {x, y}) when y > change, do: {x, y - change}
  defp compute_change("up", _change, {x, _y}), do: {x, 0}

  @doc """
  Part 2

  --- Part Two ---

  Based on your calculations, the planned course doesn't seem to make any sense. You find the submarine manual and discover that the process is actually slightly more complicated.

  In addition to horizontal position and depth, you'll also need to track a third value, aim, which also starts at 0. The commands also mean something entirely different than you first thought:

      down X increases your aim by X units.
      up X decreases your aim by X units.
      forward X does two things:
          It increases your horizontal position by X units.
          It increases your depth by your aim multiplied by X.

  Again note that since you're on a submarine, down and up do the opposite of what you might expect: "down" means aiming in the positive direction.

  Now, the above example does something different:

      forward 5 adds 5 to your horizontal position, a total of 5. Because your aim is 0, your depth does not change.
      down 5 adds 5 to your aim, resulting in a value of 5.
      forward 8 adds 8 to your horizontal position, a total of 13. Because your aim is 5, your depth increases by 8*5=40.
      up 3 decreases your aim by 3, resulting in a value of 2.
      down 8 adds 8 to your aim, resulting in a value of 10.
      forward 2 adds 2 to your horizontal position, a total of 15. Because your aim is 10, your depth increases by 2*10=20 to a total of 60.

  After following these new instructions, you would have a horizontal position of 15 and a depth of 60. (Multiplying these produces 900.)

  Using this new interpretation of the commands, calculate the horizontal position and depth you would have after following the planned course. What do you get if you multiply your final horizontal position by your final depth?


  ## Examples

    iex> AdventOfCode.Y2021.Day2.part2()
    %{answer: 1968*1060092, position: %{aim: 1063, x: 1968, y: 1060092}}

    iex> AdventOfCode.Y2021.Day2.compute_change_with_aim("forward", 5, {0, 0, 0})
    {5, 0, 0}

    iex> AdventOfCode.Y2021.Day2.compute_change_with_aim("down", 5, {5, 0, 0})
    {5, 0, 5}

    iex> AdventOfCode.Y2021.Day2.compute_change_with_aim("forward", 8, {5, 0, 5})
    {13, 40, 5}

    iex> AdventOfCode.Y2021.Day2.compute_change_with_aim("up", 3, {13, 40, 5})
    {13, 40, 2}

    iex> AdventOfCode.Y2021.Day2.compute_change_with_aim("down", 8, {13, 40, 2})
    {13, 40, 10}

    iex> AdventOfCode.Y2021.Day2.compute_change_with_aim("forward", 2, {13, 40, 10})
    {15, 60, 10}

  """

  def part2() do
    {f_x, f_y, f_aim} =
      AdventOfCode.etl_file("lib/y_2021/d2/input.txt", &parse_row/1)
      |> Enum.reduce({0, 0, 0}, fn [direction, change], {x, y, aim} ->
        compute_change_with_aim(direction, change, {x, y, aim})
      end)

    %{position: %{x: f_x, y: f_y, aim: f_aim}, answer: f_x * f_y}
  end

  def compute_change_with_aim("forward", change, {x, y, aim}) when change > 0 and aim > 0,
    do: {x + change, y + change * aim, aim}

  def compute_change_with_aim("forward", change, {x, y, aim}),
    do: {x + change, y, aim}

  def compute_change_with_aim("down", change, {x, y, aim}),
    do: {x, y, aim + change}

  def compute_change_with_aim("up", change, {x, y, aim}),
    do: {x, y, aim - change}
end
