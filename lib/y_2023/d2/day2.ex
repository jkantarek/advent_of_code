defmodule AdventOfCode.Y2023.Day2 do
  @moduledoc """

  """

  @doc """
  Day 2 - Part 1

  --- Day 2: Cube Conundrum ---
  You're launched high into the atmosphere! The apex of your trajectory just barely reaches the surface of a large island floating in the sky. You gently land in a fluffy pile of leaves. It's quite cold, but you don't see much snow. An Elf runs over to greet you.

  The Elf explains that you've arrived at Snow Island and apologizes for the lack of snow. He'll be happy to explain the situation, but it's a bit of a walk, so you have some time. They don't get many visitors up here; would you like to play a game in the meantime?

  As you walk, the Elf shows you a small bag and some cubes which are either red, green, or blue. Each time you play this game, he will hide a secret number of cubes of each color in the bag, and your goal is to figure out information about the number of cubes.

  To get information, once a bag has been loaded with cubes, the Elf will reach into the bag, grab a handful of random cubes, show them to you, and then put them back in the bag. He'll do this a few times per game.

  You play several games and record the information from each game (your puzzle input). Each game is listed with its ID number (like the 11 in Game 11: ...) followed by a semicolon-separated list of subsets of cubes that were revealed from the bag (like 3 red, 5 green, 4 blue).

  For example, the record of a few games might look like this:

  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
  In game 1, three sets of cubes are revealed from the bag (and then put back again). The first set is 3 blue cubes and 4 red cubes; the second set is 1 red cube, 2 green cubes, and 6 blue cubes; the third set is only 2 green cubes.

  The Elf would first like to know which games would have been possible if the bag contained only 12 red cubes, 13 green cubes, and 14 blue cubes?

  In the example above, games 1, 2, and 5 would have been possible if the bag had been loaded with that configuration. However, game 3 would have been impossible because at one point the Elf showed you 20 red cubes at once; similarly, game 4 would also have been impossible because the Elf showed you 15 blue cubes at once. If you add up the IDs of the games that would have been possible, you get 8.

  Determine which games would have been possible if the bag had been loaded with only 12 red cubes, 13 green cubes, and 14 blue cubes. What is the sum of the IDs of those games?

  ## Examples

    iex> AdventOfCode.Y2023.Day2.part1()
    %{len: 44, sum_of_idx: 1867}

    iex> AdventOfCode.Y2023.Day2.sample()
    %{len: 3, sum_of_idx: 8}



  """

  def sample() do
    part1("test_input.txt")
  end

  def part1(filename \\ "input.txt") do
    res =
      setup(filename)
      |> parse_invalid_games()
      |> Enum.filter(fn x -> Enum.all?(x.games, & &1["pass"]) end)

    %{len: length(res), sum_of_idx: Enum.sum(res |> Enum.map(& &1.index))}
  end

  def parse_invalid_games(games) do
    Enum.map(games, fn game ->
      res =
        Enum.map(game.games, fn set ->
          %{
            "red" => set["red"] || 0,
            "green" => set["green"] || 0,
            "blue" => set["blue"] || 0,
            "pass" =>
              (set["red"] || 0) <= 12 && (set["green"] || 0) <= 13 && (set["blue"] || 0) <= 14
          }
        end)

      Map.merge(game, %{games: res})
    end)
  end

  def decoder(line) do
    [game_idx, game] = line |> String.split(": ")
    idx = String.replace(game_idx, "Game ", "") |> String.to_integer()

    games =
      game
      |> String.split("; ")
      |> Enum.map(&parse_game/1)

    %{index: idx, games: games}
  end

  def parse_game(game) do
    game
    |> String.split(", ")
    |> Enum.reduce(%{}, fn x, acc ->
      [count, color] = String.split(x, " ")
      Map.merge(acc, %{color => String.to_integer(count)})
    end)
  end

  def setup(filename) do
    AdventOfCode.etl_file(
      "lib/y_2023/d2/#{filename}",
      &decoder/1,
      &AdventOfCode.split_newline/1,
      %{reject_blanks: true, reject_nils: true}
    )
  end

  @doc """
  Day 2 - Part 2

  --- Part Two ---
  The Elf says they've stopped producing snow because they aren't getting any water! He isn't sure why the water stopped; however, he can show you how to get to the water source to check it out for yourself. It's just up ahead!

  As you continue your walk, the Elf poses a second question: in each game you played, what is the fewest number of cubes of each color that could have been in the bag to make the game possible?

  Again consider the example games from earlier:

  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
  In game 1, the game could have been played with as few as 4 red, 2 green, and 6 blue cubes. If any color had even one fewer cube, the game would have been impossible.
  Game 2 could have been played with a minimum of 1 red, 3 green, and 4 blue cubes.
  Game 3 must have been played with at least 20 red, 13 green, and 6 blue cubes.
  Game 4 required at least 14 red, 3 green, and 15 blue cubes.
  Game 5 needed no fewer than 6 red, 3 green, and 2 blue cubes in the bag.
  The power of a set of cubes is equal to the numbers of red, green, and blue cubes multiplied together. The power of the minimum set of cubes in game 1 is 48. In games 2-5 it was 12, 1560, 630, and 36, respectively. Adding up these five powers produces the sum 2286.

  For each game, find the minimum set of cubes that must have been present. What is the sum of the power of these sets?

  ## Examples

    iex> AdventOfCode.Y2023.Day2.part2()
    84538

    iex> AdventOfCode.Y2023.Day2.sample2()
    2286

  """

  def sample2() do
    part2("test_input.txt")
  end

  def part2(filename \\ "input.txt") do
    setup(filename)
    |> find_min_cubes()
    |> sum_power_set()
  end

  def sum_power_set(games) do
    games
    |> Enum.map(fn x -> x.power_set end)
    |> Enum.sum()
  end

  def find_min_cubes(games) do
    games
    |> Enum.map(fn game ->
      res =
        Enum.reduce(game.games, %{"red" => 0, "green" => 0, "blue" => 0}, fn set, acc ->
          Map.merge(acc, set, fn _key, v1, v2 ->
            max(v1, v2)
          end)
        end)

      Map.merge(game, %{min_cubes: res, power_set: res["red"] * res["green"] * res["blue"]})
    end)
  end
end
