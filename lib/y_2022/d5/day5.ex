defmodule AdventOfCode.Y2022.Day5 do
  require IEx

  @moduledoc """

  """

  @doc """
  Day 5 - Part 1

    --- Day 5: Supply Stacks ---

  The expedition can depart as soon as the final supplies have been unloaded from the ships. Supplies are stored in stacks of marked crates, but because the needed supplies are buried under many other crates, the crates need to be rearranged.

  The ship has a giant cargo crane capable of moving crates between stacks. To ensure none of the crates get crushed or fall over, the crane operator will rearrange them in a series of carefully-planned steps. After the crates are rearranged, the desired crates will be at the top of each stack.

  The Elves don't want to interrupt the crane operator during this delicate procedure, but they forgot to ask her which crate will end up where, and they want to be ready to unload them as soon as possible so they can embark.

  They do, however, have a drawing of the starting stacks of crates and the rearrangement procedure (your puzzle input). For example:

      [D]
  [N] [C]
  [Z] [M] [P]
  1   2   3

  move 1 from 2 to 1
  move 3 from 1 to 3
  move 2 from 2 to 1
  move 1 from 1 to 2

  In this example, there are three stacks of crates. Stack 1 contains two crates: crate Z is on the bottom, and crate N is on top. Stack 2 contains three crates; from bottom to top, they are crates M, C, and D. Finally, stack 3 contains a single crate, P.

  Then, the rearrangement procedure is given. In each step of the procedure, a quantity of crates is moved from one stack to a different stack. In the first step of the above rearrangement procedure, one crate is moved from stack 2 to stack 1, resulting in this configuration:

  [D]
  [N] [C]
  [Z] [M] [P]
  1   2   3

  In the second step, three crates are moved from stack 1 to stack 3. Crates are moved one at a time, so the first crate to be moved (D) ends up below the second and third crates:

          [Z]
          [N]
      [C] [D]
      [M] [P]
  1   2   3

  Then, both crates are moved from stack 2 to stack 1. Again, because crates are moved one at a time, crate C ends up below crate M:

          [Z]
          [N]
  [M]     [D]
  [C]     [P]
  1   2   3

  Finally, one crate is moved from stack 1 to stack 2:

          [Z]
          [N]
          [D]
  [C] [M] [P]
  1   2   3

  The Elves just need to know which crate will end up on top of each stack; in this example, the top crates are C in stack 1, M in stack 2, and Z in stack 3, so you should combine these together and give the Elves the message CMZ.

  After the rearrangement procedure completes, what crate ends up on top of each stack?


  ## Examples

    iex> AdventOfCode.Y2022.Day5.part1()
    "SHMSDGZVC"

  """

  def part1() do
    setup()
    |> process_stack()
    |> get_message()
  end

  def get_message(stacks) do
    stacks
    |> Enum.map(fn {_k, v} -> extract_letter(v) end)
    |> Enum.join("")
  end

  def extract_letter([]), do: ""
  def extract_letter([{_pos, v} | _rest]), do: v

  defp process_stack(%{instructions: inst, stacks: stacks}, partitioner \\ &Utils.partition_at/3) do
    organized_stacks = organize_stacks(stacks)

    inst
    |> Enum.reduce(organized_stacks, fn instruction, stacks ->
      {taken, remainder} = partitioner.([], stacks[instruction.from], instruction.amount)

      Map.merge(stacks, %{
        instruction.from => remainder,
        instruction.to => taken ++ stacks[instruction.to]
      })
    end)
  end

  defp organize_stacks(stacks) do
    stacks
    |> Enum.group_by(fn {{col, _row}, _v} -> col end)
    |> Enum.reduce(%{}, fn {k, stack}, acc ->
      sorted_stack = stack |> Enum.sort_by(fn {{_c, r}, _v} -> r end)
      Map.merge(acc, %{k => sorted_stack})
    end)
  end

  def decoder({line, idx}) when idx <= 7 do
    line
    |> String.codepoints()
    |> Enum.chunk_every(4)
    |> Enum.with_index()
    |> Enum.map(fn {[_z, val | _rest], col} ->
      %{
        type: :stack,
        row: idx,
        col: col + 1,
        val: val
      }
    end)
  end

  def decoder({_line, idx}) when idx in [8] do
    %{}
  end

  def decoder({line, idx}) do
    [amt, from, to] =
      line
      |> String.split(" ")
      |> Enum.reduce([], fn part, acc ->
        select_numbers(part, acc)
      end)

    %{
      idx: idx - 8,
      type: :instruction,
      amount: amt,
      from: from,
      to: to
    }
  end

  defp select_numbers(var, acc) when var in ["move", "from", "to"], do: acc

  defp select_numbers(var, acc) do
    {num, ""} = Integer.parse(var)
    acc ++ [num]
  end

  def setup() do
    AdventOfCode.etl_file(
      "lib/y_2022/d5/input.txt",
      &decoder/1,
      &AdventOfCode.split_newline/1,
      %{reject_blanks: true, reject_nils: true, with_index: true}
    )
    |> collapse_and_group()
  end

  defp collapse_and_group(groups) do
    groups
    |> Enum.reduce(%{instructions: [], stacks: %{}}, fn elem, acc ->
      stacks = Map.merge(acc.stacks, build_collection(acc.stacks, elem))

      %{
        stacks: stacks,
        instructions: acc.instructions ++ build_instruction(elem)
      }
    end)
  end

  defp build_instruction(%{type: :instruction} = instruction), do: [instruction]
  defp build_instruction(_item), do: []

  defp build_collection(existing_coll, elem) when is_list(elem) do
    elem
    |> Enum.reduce(existing_coll, fn item, acc ->
      Map.merge(acc, build_element(item))
    end)
  end

  defp build_collection(ex, _e), do: ex

  defp build_element(%{val: " "} = _item), do: %{}

  defp build_element(%{col: col, row: row, type: :stack, val: v}) do
    %{
      {col, row} => v
    }
  end

  @doc """
  Day 5 - Part 2

  ## Examples

    iex> AdventOfCode.Y2022.Day5.part2()
    "VRZGHDFBQ"

  """

  def part2() do
    setup()
    |> process_stack(&group_partition/3)
    |> get_message()
  end

  def group_partition(top, bottom, count) when length(top) == count, do: {top, bottom}

  def group_partition(top, [], _count), do: {top, []}

  def group_partition(top, [first | rest], count) do
    group_partition(top ++ [first], rest || [], count)
  end
end
