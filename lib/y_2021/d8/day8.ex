defmodule AdventOfCode.Y2021.Day8 do
  @moduledoc """
  --- Day 8: Seven Segment Search ---

  You barely reach the safety of the cave when the whale smashes into the cave mouth, collapsing it. Sensors indicate another exit to this cave at a much greater depth, so you have no choice but to press on.

  As your submarine slowly makes its way through the cave system, you notice that the four-digit seven-segment displays in your submarine are malfunctioning; they must have been damaged during the escape. You'll be in a lot of trouble without them, so you'd better figure out what's wrong.

  Each digit of a seven-segment display is rendered by turning on or off any of seven segments named a through g:

    0:      1:      2:      3:      4:
   aaaa    ....    aaaa    aaaa    ....
  b    c  .    c  .    c  .    c  b    c
  b    c  .    c  .    c  .    c  b    c
   ....    ....    dddd    dddd    dddd
  e    f  .    f  e    .  .    f  .    f
  e    f  .    f  e    .  .    f  .    f
   gggg    ....    gggg    gggg    ....

    5:      6:      7:      8:      9:
   aaaa    aaaa    aaaa    aaaa    aaaa
  b    .  b    .  .    c  b    c  b    c
  b    .  b    .  .    c  b    c  b    c
   dddd    dddd    ....    dddd    dddd
  .    f  e    f  .    f  e    f  .    f
  .    f  e    f  .    f  e    f  .    f
   gggg    gggg    ....    gggg    gggg

   0 = 8 - p6 => 6
   1 = p1 + p2 => 2
   2 = 8 - p2 - p5 => 5
   3 = 8 - p4 - p5 => 5
   4 = p1 + p2 + p4 + p6 => 4
   5 = 8 - p2 - p4 => 5
   6 = 8 - p1 => 6
   7 = p0 + p1 + p2 => 3
   8 = p0 + p1 + p2 + p3 + p4 + p5 + p6 => 7
   9 = 8 - p4 => 6


  So, to render a 1, only segments c and f would be turned on; the rest would be off. To render a 7, only segments a, c, and f would be turned on.

  The problem is that the signals which control the segments have been mixed up on each display. The submarine is still trying to display numbers by producing output on signal wires a through g, but those wires are connected to segments randomly. Worse, the wire/segment connections are mixed up separately for each four-digit display! (All of the digits within a display use the same connections, though.)

  So, you might know that only signal wires b and g are turned on, but that doesn't mean segments b and g are turned on: the only digit that uses two segments is 1, so it must mean segments c and f are meant to be on. With just that information, you still can't tell which wire (b/g) goes to which segment (c/f). For that, you'll need to collect more information.

  For each display, you watch the changing signals for a while, make a note of all ten unique signal patterns you see, and then write down a single four digit output value (your puzzle input). Using the signal patterns, you should be able to work out which pattern corresponds to which digit.

  For example, here is what you might see in a single entry in your notes:

  acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab |
  cdfeb fcadb cdfeb cdbaf

  (The entry is wrapped here to two lines so it fits; in your notes, it will all be on a single line.)

  Each entry consists of ten unique signal patterns, a | delimiter, and finally the four digit output value. Within an entry, the same wire/segment connections are used (but you don't know what the connections actually are). The unique signal patterns correspond to the ten different ways the submarine tries to render a digit using the current wire/segment connections. Because 7 is the only digit that uses three segments, dab in the above example means that to render a 7, signal lines d, a, and b are on. Because 4 is the only digit that uses four segments, eafb means that to render a 4, signal lines e, a, f, and b are on.

  Using this information, you should be able to work out which combination of signal wires corresponds to each of the ten digits. Then, you can decode the four digit output value. Unfortunately, in the above example, all of the digits in the output value (cdfeb fcadb cdfeb cdbaf) use five segments and are more difficult to deduce.

  For now, focus on the easy digits. Consider this larger example:

  be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb |
  fdgacbe cefdb cefbgd gcbe
  edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec |
  fcgedb cgb dgebacf gc
  fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef |
  cg cg fdcagb cbg
  fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega |
  efabcd cedba gadfec cb
  aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga |
  gecf egdcabf bgf bfgea
  fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf |
  gebdcfa ecba ca fadegcb
  dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf |
  cefg dcbef fcge gbcadfe
  bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd |
  ed bcgafe cdgba cbgef
  egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg |
  gbdfcae bgc cg cgb
  gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc |
  fgae cfgab fg bagce

  Because the digits 1, 4, 7, and 8 each use a unique number of segments, you should be able to tell which combinations of signals correspond to those digits. Counting only digits in the output values (the part after | on each line), in the above example, there are 26 instances of digits that use a unique number of segments (highlighted above).

  In the output values, how many times do digits 1, 4, 7, or 8 appear?

  """

  @doc """
  Day 1 - Part 1

  ## Examples

    iex> AdventOfCode.Y2021.Day8.part1()
    470

  """

  def part1() do
    setup()
    |> Enum.reduce(0, fn [_in, output], acc ->
      output
      |> Enum.reduce(acc, fn {_s, val}, sub_acc ->
        if is_nil(val) do
          sub_acc
        else
          sub_acc + 1
        end
      end)
    end)
  end

  def setup() do
    AdventOfCode.etl_file(
      "lib/y_2021/d8/input.txt",
      &decode_row/1
    )
  end

  def decode_row(row) do
    row
    |> String.split(" | ")
    |> transpose_parts()
  end

  def transpose_parts(res) do
    res
    |> Enum.map(fn str ->
      String.split(str, " ", trim: true)
      |> Enum.map(fn s ->
        s
        |> String.codepoints()
        |> decode_possible_lookup()
      end)
    end)
  end

  def decode_possible_lookup(v) when length(v) == 2 do
    {v, 1}
  end

  def decode_possible_lookup(v) when length(v) == 4 do
    {v, 4}
  end

  def decode_possible_lookup(v) when length(v) == 3 do
    {v, 7}
  end

  def decode_possible_lookup(v) when length(v) == 7 do
    {v, 8}
  end

  def decode_possible_lookup(v) do
    {v, nil}
  end

  @doc """
  --- Part Two ---

  Through a little deduction, you should now be able to determine the remaining digits. Consider again the first example above:

  acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab |
  cdfeb fcadb cdfeb cdbaf

  After some careful analysis, the mapping between signal wires and segments only make sense in the following configuration:

        p0
       dddd
      e    a p1
  p5  e p6 a
       ffff
      g    b p2
  p4  g    b
       cccc
        p3


  So, the unique signal patterns would correspond to the following digits:

      acedgfb: 8
      cdfbe: 5
      gcdfa: 2
      fbcad: 3
      dab: 7
      cefabd: 9
      cdfgeb: 6
      eafb: 4
      cagedb: 0
      ab: 1

  Then, the four digits of the output value can be decoded:

      cdfeb: 5
      fcadb: 3
      cdfeb: 5
      cdbaf: 3

  Therefore, the output value for this entry is 5353.

  Following this same process for each entry in the second, larger example above, the output value of each entry can be determined:

      fdgacbe cefdb cefbgd gcbe: 8394
      fcgedb cgb dgebacf gc: 9781
      cg cg fdcagb cbg: 1197
      efabcd cedba gadfec cb: 9361
      gecf egdcabf bgf bfgea: 4873
      gebdcfa ecba ca fadegcb: 8418
      cefg dcbef fcge gbcadfe: 4548
      ed bcgafe cdgba cbgef: 1625
      gbdfcae bgc cg cgb: 8717
      fgae cfgab fg bagce: 4315

  Adding all of the output values in this larger example produces 61229.

  For each entry, determine all of the wire/segment connections and decode the four-digit output values. What do you get if you add up all of the output values?

  ## Examples

    iex> AdventOfCode.Y2021.Day8.part2()
    989396

    iex> "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"
    ...> |> AdventOfCode.Y2021.Day8.decode_row()
    ...> |> AdventOfCode.Y2021.Day8.process_row()
    5353

    iex> "edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc"
    ...> |> AdventOfCode.Y2021.Day8.decode_row()
    ...> |> AdventOfCode.Y2021.Day8.process_row()
    9781

  """

  def part2() do
    setup()
    |> Enum.map(&process_row/1)
    |> Enum.sum()
  end

  def process_row([input, output]) do
    %{true: defined, false: missing} =
      input
      |> Enum.group_by(fn {_reg, val} -> !is_nil(val) end)

    defined
    |> Enum.sort_by(fn {_mp, num} -> num end)
    |> translate_registers(missing)
    |> compute_output(output)
  end

  def translate_registers([{one, 1}, {four, 4}, {seven, 7}, {eight, 8}], missing) do
    %{5 => fives, 6 => sixes} =
      missing
      |> Enum.group_by(fn {l, _} -> length(l) end)

    decode_positions([{one, 1}, {four, 4}, {seven, 7}, {eight, 8}], fives, sixes)
  end

  # 6s must be 0 or 9 or 6
  # 5s must be 2 or 3 or 5

  # p1 = 0  & 1  & 2  & 3  & 4  & !5 & !6 & 7  & 8  & 9
  # p2 = 0  & 1  & !2 & 3  & 4  & 5  & 6  & 7  & 8  & 9
  # p3 = 0  & !1 & 2  & 3  & !4 & 5  & 6  & !7 & 8  & 9
  # p4 = 0  & !1 & 2  & 3  & !4 & 5  & 6  & !7 & 8  & 9

  #   0:      1:      2:      3:      4:
  #  aaaa    ....    aaaa    aaaa    ....
  # b    c  .    c  .    c  .    c  b    c
  # b    c  .    c  .    c  .    c  b    c
  #  ....    ....    dddd    dddd    dddd
  # e    f  .    f  e    .  .    f  .    f
  # e    f  .    f  e    .  .    f  .    f
  #  gggg    ....    gggg    gggg    ....
  #
  #   5:      6:      7:      8:      9:
  #  aaaa    aaaa    aaaa    aaaa    aaaa
  # b    .  b    .  .    c  b    c  b    c
  # b    .  b    .  .    c  b    c  b    c
  #  dddd    dddd    ....    dddd    dddd
  # .    f  e    f  .    f  e    f  .    f
  # .    f  e    f  .    f  e    f  .    f
  #  gggg    gggg    ....    gggg    gggg

  def decode_positions(
        [{one, 1}, {four, 4}, {seven, 7}, {eight, 8}],
        fives,
        sixes
      ) do
    [{six, 6}, rem_sixes] = find_six(one, sixes)
    [{zero, 0}, {nine, 9}] = find_zero(four, rem_sixes)
    [{three, 3}, rem_fives] = find_three(one, fives)
    [{five, 5}, {two, 2}] = find_five(six, rem_fives)

    %{
      zero => 0,
      one => 1,
      two => 2,
      three => 3,
      four => 4,
      five => 5,
      six => 6,
      seven => 7,
      eight => 8,
      nine => 9
    }
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      Map.merge(acc, %{(k |> Enum.sort()) => v})
    end)
  end

  def find_six(one, sixes) do
    %{true: [{v, nil}], false: rem_sixes} =
      sixes
      |> Enum.group_by(fn {elem, nil} ->
        (one -- elem) |> Enum.any?()
      end)

    [{v, 6}, rem_sixes]
  end

  def find_zero(four, sixes) do
    %{true: [{zero, nil}], false: [{nine, nil}]} =
      sixes
      |> Enum.group_by(fn {elem, nil} ->
        (four -- elem) |> Enum.any?()
      end)

    [{zero, 0}, {nine, 9}]
  end

  def find_three(one, fives) do
    %{true: [{three, nil}], false: rem_fives} =
      fives
      |> Enum.group_by(fn {elem, nil} ->
        length(one -- elem) == 0
      end)

    [{three, 3}, rem_fives]
  end

  def find_five(six, rem_fives) do
    %{true: [{five, nil}], false: [{two, nil}]} =
      rem_fives
      |> Enum.group_by(fn {elem, nil} ->
        length(six -- elem) == 1
      end)

    [{five, 5}, {two, 2}]
  end

  def compute_output(mapping, output) do
    {n, _s} =
      output
      |> Enum.map(fn {reg, _v} ->
        "#{mapping[reg |> Enum.sort()]}"
      end)
      |> Enum.join()
      |> Integer.parse()

    n
  end
end
