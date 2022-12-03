defmodule AdventOfCode.Y2022.Day3 do
  @moduledoc """

  """

  @doc """
  Day 3 - Part 1
  --- Day 3: Rucksack Reorganization ---

  One Elf has the important job of loading all of the rucksacks with supplies for the jungle journey. Unfortunately, that Elf didn't quite follow the packing instructions, and so a few items now need to be rearranged.

  Each rucksack has two large compartments. All items of a given type are meant to go into exactly one of the two compartments. The Elf that did the packing failed to follow this rule for exactly one item type per rucksack.

  The Elves have made a list of all of the items currently in each rucksack (your puzzle input), but they need your help finding the errors. Every item type is identified by a single lowercase or uppercase letter (that is, a and A refer to different types of items).

  The list of items for each rucksack is given as characters all on a single line. A given rucksack always has the same number of items in each of its two compartments, so the first half of the characters represent items in the first compartment, while the second half of the characters represent items in the second compartment.

  For example, suppose you have the following list of contents from six rucksacks:

  vJrwpWtwJgWrhcsFMMfFFhFp
  jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
  PmmdzqPrVvPwwTWBwg
  wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
  ttgJtRGJQctTZtZT
  CrZsJsPPZsGzwwsLwLmpwMDw

      The first rucksack contains the items vJrwpWtwJgWrhcsFMMfFFhFp, which means its first compartment contains the items vJrwpWtwJgWr, while the second compartment contains the items hcsFMMfFFhFp. The only item type that appears in both compartments is lowercase p.
      The second rucksack's compartments contain jqHRNqRjqzjGDLGL and rsFMfFZSrLrFZsSL. The only item type that appears in both compartments is uppercase L.
      The third rucksack's compartments contain PmmdzqPrV and vPwwTWBwg; the only common item type is uppercase P.
      The fourth rucksack's compartments only share item type v.
      The fifth rucksack's compartments only share item type t.
      The sixth rucksack's compartments only share item type s.

  To help prioritize item rearrangement, every item type can be converted to a priority:

      Lowercase item types a through z have priorities 1 through 26.
      Uppercase item types A through Z have priorities 27 through 52.

  In the above example, the priority of the item type that appears in both compartments of each rucksack is 16 (p), 38 (L), 42 (P), 22 (v), 20 (t), and 19 (s); the sum of these is 157.

  Find the item type that appears in both compartments of each rucksack. What is the sum of the priorities of those item types?



  ## Examples

    iex> AdventOfCode.Y2022.Day3.part1()
    7766

  """

  @lowercases [
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z"
  ]

  @uppercases [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
  ]

  def part1() do
    {_sets, sum} =
      setup()
      |> split_and_decode()

    sum
  end

  defp setup() do
    AdventOfCode.etl_file(
      "lib/y_2022/d3/input.txt",
      fn x -> x end,
      &AdventOfCode.split_newline/1,
      %{reject_blanks: true, reject_nils: true}
    )
  end

  def split_and_decode(packs) do
    packs
    |> Enum.map_reduce(0, fn str, acc ->
      len = (String.length(str) / 2) |> trunc()

      {first, last} =
        str
        |> String.split_at(len)

      f_l = String.graphemes(first) |> MapSet.new()
      l_l = String.graphemes(last) |> MapSet.new()

      [overlap] = MapSet.intersection(f_l, l_l) |> MapSet.to_list()
      f_f = MapSet.delete(f_l, overlap)
      l_f = MapSet.delete(l_l, overlap)

      priority = compute_priority(overlap)

      {
        %{
          first: first,
          first_final: f_f,
          last: last,
          last_final: l_f,
          overlap: overlap,
          overlap_priority: priority
        },
        acc + priority
      }
    end)
  end

  defp compute_priority(overlap) when overlap in @lowercases do
    res =
      @lowercases
      |> Enum.find_index(fn e -> e == overlap end)

    res + 1
  end

  defp compute_priority(overlap) when overlap in @uppercases do
    res =
      @uppercases
      |> Enum.find_index(fn e -> e == overlap end)

    res + 27
  end

  @doc """
  Day 3 - Part 2

  ## Examples

    iex> AdventOfCode.Y2022.Day3.part2()
    nil

  """

  def part2() do
  end
end
