defmodule AdventOfCode.Y2023.Day1 do
  @moduledoc """
  --- Day 1: Trebuchet?! ---
  Something is wrong with global snow production, and you've been selected to take a look. The Elves have even given you a map; on it, they've used stars to mark the top fifty locations that are likely to be having problems.

  You've been doing this long enough to know that to restore snow operations, you need to check all fifty stars by December 25th.

  Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

  You try to ask why they can't just use a weather machine ("not powerful enough") and where they're even sending you ("the sky") and why your map looks mostly blank ("you sure ask a lot of questions") and hang on did you just say the sky ("of course, where do you think snow comes from") when you realize that the Elves are already loading you into a trebuchet ("please hold still, we need to strap you in").

  As they're making the final adjustments, they discover that their calibration document (your puzzle input) has been amended by a very young Elf who was apparently just excited to show off her art skills. Consequently, the Elves are having trouble reading the values on the document.

  The newly-improved calibration document consists of lines of text; each line originally contained a specific calibration value that the Elves now need to recover. On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.

  For example:

  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
  In this example, the calibration values of these four lines are 12, 38, 15, and 77. Adding these together produces 142.

  Consider your entire calibration document. What is the sum of all of the calibration values?

  """

  @doc """
  Day 1 - Part 1

  ## Examples



    iex> AdventOfCode.Y2023.Day1.sample()
    142

    iex> AdventOfCode.Y2023.Day1.part1()
    55621


  """

  def sample() do
    part1("test_input.txt")
  end

  def part1(filename \\ "input.txt") do
    setup(filename)
    |> Enum.map(fn str ->
      str
      |> reject_letters()
      |> take_first_and_last()
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  def reject_letters(str) do
    str
    |> String.replace(~r/[a-zA-Z]/, "")
  end

  def take_first_and_last(str) do
    [first | rest] = String.split(str, "") |> Enum.filter(&(!(&1 == "")))

    [
      first,
      List.last(rest) || first
    ]
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.join()
  end

  def decoder(line) do
    line
  end

  def setup(filename) do
    AdventOfCode.etl_file(
      "lib/y_2023/d1/#{filename}",
      &decoder/1,
      &AdventOfCode.split_newline/1,
      %{reject_blanks: true, reject_nils: true}
    )
  end

  @doc """
  Day 1 - Part 2

  --- Part Two ---
  Your calculation isn't quite right. It looks like some of the digits are actually spelled out with letters: one, two, three, four, five, six, seven, eight, and nine also count as valid "digits".

  Equipped with this new information, you now need to find the real first and last digit on each line. For example:

  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
  In this example, the calibration values are 29, 83, 13, 24, 42, 14, and 76. Adding these together produces 281.

  What is the sum of all of the calibration values?

  ## Examples


    iex> AdventOfCode.Y2023.Day1.sample2()
    292

    iex> AdventOfCode.Y2023.Day1.part2()
    53592


  """

  def sample2() do
    part2("test_input2.txt")
  end

  def part2(filename \\ "input.txt") do
    setup(filename)
    |> Enum.map(fn str ->
      str
      |> split_by_digits()
    end)
    |> Enum.sum()
  end

  @collection %{
    "zero" => "0",
    "0" => "0",
    "one" => "1",
    "1" => "1",
    "two" => "2",
    "2" => "2",
    "three" => "3",
    "3" => "3",
    "four" => "4",
    "4" => "4",
    "five" => "5",
    "5" => "5",
    "six" => "6",
    "6" => "6",
    "seven" => "7",
    "7" => "7",
    "eight" => "8",
    "8" => "8",
    "nine" => "9",
    "9" => "9"
  }

  @collection_keys @collection |> Map.keys()

  @collection_keys_regex ~r/(?=(one|two|three|four|five|six|seven|eight|nine|0|1|2|3|4|5|6|7|8|9))/

  def split_by_digits(str) do
    reg = @collection_keys_regex
    found_numbers = get_numbers(reg, str) |> List.flatten() |> Enum.reject(&(&1 == ""))

    found_numbers
    |> Enum.map(fn s ->
      v = Map.get(@collection, s)
    end)
    |> Enum.filter(&(!is_nil(&1)))
    |> extract_first_and_last()
  end

  def get_numbers(regex, str) do
    Regex.scan(regex, str)
  end

  def extract_first_and_last([first | rest]) do
    [
      first,
      List.last(rest) || first
    ]
    |> Enum.join()
    |> String.to_integer()
  end
end
