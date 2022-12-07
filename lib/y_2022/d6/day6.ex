defmodule AdventOfCode.Y2022.Day6 do
  @moduledoc """

  """

  @doc """
  Day 6 - Part 1

  --- Day 6: Tuning Trouble ---

  The preparations are finally complete; you and the Elves leave camp on foot and begin to make your way toward the star fruit grove.

  As you move through the dense undergrowth, one of the Elves gives you a handheld device. He says that it has many fancy features, but the most important one to set up right now is the communication system.

  However, because he's heard you have significant experience dealing with signal-based systems, he convinced the other Elves that it would be okay to give you their one malfunctioning device - surely you'll have no problem fixing it.

  As if inspired by comedic timing, the device emits a few colorful sparks.

  To be able to communicate with the Elves, the device needs to lock on to their signal. The signal is a series of seemingly-random characters that the device receives one at a time.

  To fix the communication system, you need to add a subroutine to the device that detects a start-of-packet marker in the datastream. In the protocol being used by the Elves, the start of a packet is indicated by a sequence of four characters that are all different.

  The device will send your subroutine a datastream buffer (your puzzle input); your subroutine needs to identify the first position where the four most recently received characters were all different. Specifically, it needs to report the number of characters from the beginning of the buffer to the end of the first such four-character marker.

  For example, suppose you receive the following datastream buffer:

  mjqjpqmgbljsphdztnvjfqwrcgsmlb

  After the first three characters (mjq) have been received, there haven't been enough characters received yet to find the marker. The first time a marker could occur is after the fourth character is received, making the most recent four characters mjqj. Because j is repeated, this isn't a marker.

  The first time a marker appears is after the seventh character arrives. Once it does, the last four characters received are jpqm, which are all different. In this case, your subroutine should report the value 7, because the first start-of-packet marker is complete after 7 characters have been processed.

  Here are a few more examples:

      bvwbjplbgvbhsrlpgdmjqwftvncz: first marker after character 5
      nppdvjthqldpwncqszvftbrmjlhg: first marker after character 6
      nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg: first marker after character 10
      zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw: first marker after character 11

  How many characters need to be processed before the first start-of-packet marker is detected?


  ## Examples

    iex> AdventOfCode.Y2022.Day6.part1()
    1987

  """

  def part1() do
    res =
      setup()
      |> Enum.at(0)
      |> detect_and_partition_start(4)

    res.start_index
  end

  @doc """

  ## Examples

    iex> res = AdventOfCode.Y2022.Day6.detect_and_partition_start("bvwbjplbgvbhsrlpgdmjqwftvncz", 4)
    ...> res.start_index
    5

    iex> res = AdventOfCode.Y2022.Day6.detect_and_partition_start("nppdvjthqldpwncqszvftbrmjlhg", 4)
    ...> res.start_index
    6

    iex> res = AdventOfCode.Y2022.Day6.detect_and_partition_start("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 4)
    ...> res.start_index
    10

    iex> res = AdventOfCode.Y2022.Day6.detect_and_partition_start("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 4)
    ...> res.start_index
    11

    iex> res = AdventOfCode.Y2022.Day6.detect_and_partition_start("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 14)
    ...> res.start_index
    19

    iex> res = AdventOfCode.Y2022.Day6.detect_and_partition_start("bvwbjplbgvbhsrlpgdmjqwftvncz", 14)
    ...> res.start_index
    23

    iex> res = AdventOfCode.Y2022.Day6.detect_and_partition_start("nppdvjthqldpwncqszvftbrmjlhg", 14)
    ...> res.start_index
    23

    iex> res = AdventOfCode.Y2022.Day6.detect_and_partition_start("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 14)
    ...> res.start_index
    29

    iex> res = AdventOfCode.Y2022.Day6.detect_and_partition_start("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 14)
    ...> res.start_index
    26

  """

  def detect_and_partition_start(buffer, size) do
    b = buffer |> String.codepoints() |> Enum.with_index()
    find_start(b, [], nil, size)
  end

  defp find_start(rest, head, idx, _type) when is_integer(idx) do
    %{
      head: head,
      marker: [],
      message: rest,
      start_index: idx + 1
    }
  end

  defp find_start([p0, p1, p2, p3 | rest], [], nil, 4) do
    target_idx = find_member([p0, p1, p2, p3], 4)
    find_start(rest, [p3, p2, p1, p0], target_idx, 4)
  end

  defp find_start([p3 | rest], [p2, p1, p0 | r], nil, 4) do
    target_idx = find_member([p0, p1, p2, p3], 4)
    find_start(rest, [p3, p2, p1, p0] ++ r, target_idx, 4)
  end

  defp find_start(buffer, [], nil, 14) do
    {elems, rest} = Utils.partition_at([], buffer, 14)
    target_idx = find_member(elems, 14)
    find_start(rest, elems, target_idx, 14)
  end

  defp find_start([p3 | rest], r, nil, 14) do
    {elems, _rem} = Utils.partition_at([], r, 13)
    target_idx = find_member([p3] ++ elems, 14)
    find_start(rest, [p3] ++ r, target_idx, 14)
  end

  defp find_member(elems, 14) do
    l = Enum.map(elems, fn {cn, _idx} -> cn end)
    {_v, idx} = Enum.at(elems, -1)

    (MapSet.size(MapSet.new(l)) == length(l))
    |> get_idx(idx + 1)
  end

  defp find_member([{c0, _idx0}, {c1, _idx1}, {c2, _idx2}, {c3, idx3}], 4) do
    l = [c0, c1, c2, c3]

    (MapSet.size(MapSet.new(l)) == length(l))
    |> get_idx(idx3)
  end

  def get_idx(true, idx), do: idx
  def get_idx(false, _idx), do: nil

  def decoder(line) do
    line
  end

  def setup() do
    AdventOfCode.etl_file(
      "lib/y_2022/d6/input.txt",
      &decoder/1,
      &AdventOfCode.split_newline/1,
      %{reject_blanks: true, reject_nils: true}
    )
  end

  @doc """
  Day 6 - Part 2

  --- Part Two ---

  Your device's communication system is correctly detecting packets, but still isn't working. It looks like it also needs to look for messages.

  A start-of-message marker is just like a start-of-packet marker, except it consists of 14 distinct characters rather than 4.

  Here are the first positions of start-of-message markers for all of the above examples:

      mjqjpqmgbljsphdztnvjfqwrcgsmlb: first marker after character 19
      bvwbjplbgvbhsrlpgdmjqwftvncz: first marker after character 23
      nppdvjthqldpwncqszvftbrmjlhg: first marker after character 23
      nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg: first marker after character 29
      zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw: first marker after character 26


  ## Examples

    iex> AdventOfCode.Y2022.Day6.part2()
    3059

  """

  def part2() do
    res =
      setup()
      |> Enum.at(0)
      |> detect_and_partition_start(14)

    res.start_index
  end
end
