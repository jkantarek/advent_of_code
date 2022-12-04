defmodule AdventOfCode.Y2022.Day4 do
  @moduledoc """

  """

  @doc """
  Day 4 - Part 1

  --- Day 4: Camp Cleanup ---

  Space needs to be cleared before the last supplies can be unloaded from the ships, and so several Elves have been assigned the job of cleaning up sections of the camp. Every section has a unique ID number, and each Elf is assigned a range of section IDs.

  However, as some of the Elves compare their section assignments with each other, they've noticed that many of the assignments overlap. To try to quickly find overlaps and reduce duplicated effort, the Elves pair up and make a big list of the section assignments for each pair (your puzzle input).

  For example, consider the following list of section assignment pairs:

  2-4,6-8
  2-3,4-5
  5-7,7-9
  2-8,3-7
  6-6,4-6
  2-6,4-8

  For the first few pairs, this list means:

      Within the first pair of Elves, the first Elf was assigned sections 2-4 (sections 2, 3, and 4), while the second Elf was assigned sections 6-8 (sections 6, 7, 8).
      The Elves in the second pair were each assigned two sections.
      The Elves in the third pair were each assigned three sections: one got sections 5, 6, and 7, while the other also got 7, plus 8 and 9.

  This example list uses single-digit section IDs to make it easier to draw; your actual list might contain larger numbers. Visually, these pairs of section assignments look like this:

  .234.....  2-4
  .....678.  6-8

  .23......  2-3
  ...45....  4-5

  ....567..  5-7
  ......789  7-9

  .2345678.  2-8
  ..34567..  3-7

  .....6...  6-6
  ...456...  4-6

  .23456...  2-6
  ...45678.  4-8

  Some of the pairs have noticed that one of their assignments fully contains the other. For example, 2-8 fully contains 3-7, and 6-6 is fully contained by 4-6. In pairs where one assignment fully contains the other, one Elf in the pair would be exclusively cleaning sections their partner will already be cleaning, so these seem like the most in need of reconsideration. In this example, there are 2 such pairs.

  In how many assignment pairs does one range fully contain the other?


  ## Examples

    iex> AdventOfCode.Y2022.Day4.part1()
    483

  """

  def part1() do
    setup()
    |> count_overlaps()
  end

  defp count_overlaps(sets) do
    sets
    |> Enum.count(fn %{containment: c} = _s ->
      c
    end)
  end

  defp setup() do
    AdventOfCode.etl_file(
      "lib/y_2022/d4/input.txt",
      &split_parse_and_range/1,
      &AdventOfCode.split_newline/1,
      %{reject_blanks: true, reject_nils: true}
    )
  end

  defp split_parse_and_range(x) do
    [r11, r12, r21, r22] = split_and_parse(x)
    r1 = Range.new(r11, r12)
    r2 = Range.new(r21, r22)
    disjoint = Range.disjoint?(r1, r2)

    %{
      r1: r1,
      r2: r2,
      disjoint: disjoint,
      containment: compute_containment(disjoint, r1, r2)
    }
  end

  @doc """
    ## Examples

      iex> AdventOfCode.Y2022.Day4.compute_containment(false, 6..6, 4..6)
      true

      iex> AdventOfCode.Y2022.Day4.compute_containment(false, 4..6, 6..6)
      true

      iex> AdventOfCode.Y2022.Day4.compute_containment(false, 4..4, 4..6)
      true

      iex> AdventOfCode.Y2022.Day4.compute_containment(false, 4..6, 4..4)
      true

      iex> AdventOfCode.Y2022.Day4.compute_containment(false, 4..6, 4..6)
      true

      iex> AdventOfCode.Y2022.Day4.compute_containment(false, 4..4, 1..6)
      true
  """

  def compute_containment(true, _r1, _r2), do: false

  def compute_containment(false, r11..r12, r21..r22) when r11 <= r21 and r12 >= r22, do: true
  def compute_containment(false, r11..r12, r21..r22) when r21 <= r11 and r22 >= r12, do: true

  def compute_containment(false, _r1, _r2), do: false

  defp split_and_parse(x) do
    x
    |> String.split(",")
    |> Enum.flat_map(fn y ->
      y
      |> String.split("-")
      |> Enum.map(fn n ->
        {n, ""} = Integer.parse(n)
        n
      end)
    end)
  end

  @doc """
  Day 4 - Part 2

  ## Examples

    iex> AdventOfCode.Y2022.Day4.part2()
    nil

  """

  def part2() do
  end
end
