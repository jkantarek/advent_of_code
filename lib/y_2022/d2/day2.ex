defmodule AdventOfCode.Y2022.Day2 do
  @moduledoc """

  """

  @doc """
  Day 1 - Part 1

  --- Day 2: Rock Paper Scissors ---
  The Elves begin to set up camp on the beach. To decide whose tent gets to be closest to the snack storage, a giant Rock Paper Scissors tournament is already in progress.

  Rock Paper Scissors is a game between two players. Each game contains many rounds; in each round, the players each simultaneously choose one of Rock, Paper, or Scissors using a hand shape. Then, a winner for that round is selected: Rock defeats Scissors, Scissors defeats Paper, and Paper defeats Rock. If both players choose the same shape, the round instead ends in a draw.

  Appreciative of your help yesterday, one Elf gives you an encrypted strategy guide (your puzzle input) that they say will be sure to help you win. "The first column is what your opponent is going to play: A for Rock, B for Paper, and C for Scissors. The second column--" Suddenly, the Elf is called away to help with someone's tent.

  The second column, you reason, must be what you should play in response: X for Rock, Y for Paper, and Z for Scissors. Winning every time would be suspicious, so the responses must have been carefully chosen.

  The winner of the whole tournament is the player with the highest score. Your total score is the sum of your scores for each round. The score for a single round is the score for the shape you selected (1 for Rock, 2 for Paper, and 3 for Scissors) plus the score for the outcome of the round (0 if you lost, 3 if the round was a draw, and 6 if you won).

  Since you can't be sure if the Elf is trying to help you or trick you, you should calculate the score you would get if you were to follow the strategy guide.

  For example, suppose you were given the following strategy guide:

  A Y
  B X
  C Z
  This strategy guide predicts and recommends the following:

  In the first round, your opponent will choose Rock (A), and you should choose Paper (Y). This ends in a win for you with a score of 8 (2 because you chose Paper + 6 because you won).
  In the second round, your opponent will choose Paper (B), and you should choose Rock (X). This ends in a loss for you with a score of 1 (1 + 0).
  The third round is a draw with both players choosing Scissors, giving you a score of 3 + 3 = 6.
  In this example, if you were to follow the strategy guide, you would get a total score of 15 (8 + 1 + 6).

  What would your total score be if everything goes exactly according to your strategy guide?

  ## Examples

    iex> AdventOfCode.Y2022.Day2.part1()
    11449

  """

  def part1() do
    {_set, score} =
      setup()
      |> decode_and_score()

    score
  end

  defp setup() do
    AdventOfCode.etl_file(
      "lib/y_2022/d2/input.txt",
      fn x -> x end,
      &AdventOfCode.split_newline/1,
      %{reject_blanks: true, reject_nils: true}
    )
  end

  defp decode_and_score(string_pairs) do
    string_pairs
    |> Enum.map_reduce(0, fn str, acc ->
      [o, st] = String.split(str, " ")
      [opp, str, outcome, score] = decode_and_score(o, st)

      {
        %{
          opponent: opp,
          strategy: str,
          outcome: outcome,
          score: score
        },
        score + acc
      }
    end)
  end

  defp decode_and_score(opp, st) when is_bitstring(opp) and is_bitstring(st) do
    decode_and_score(normalize(opp), normalize(st))
  end

  defp decode_and_score(opp, st) when opp == st, do: [opp, st, :tie, 3 + score_strategy(st)]
  defp decode_and_score(:rock, :paper), do: [:rock, :paper, :win, 6 + score_strategy(:paper)]

  defp decode_and_score(:rock, :scissors),
    do: [:rock, :scissors, :lose, 0 + score_strategy(:scissors)]

  defp decode_and_score(:paper, :rock), do: [:paper, :rock, :lose, 0 + score_strategy(:rock)]

  defp decode_and_score(:paper, :scissors),
    do: [:paper, :scissors, :win, 6 + score_strategy(:scissors)]

  defp decode_and_score(:scissors, :rock), do: [:scissors, :rock, :win, 6 + score_strategy(:rock)]

  defp decode_and_score(:scissors, :paper),
    do: [:scissors, :paper, :lose, 0 + score_strategy(:paper)]

  defp normalize(st) when st in ["A", "X"], do: :rock
  defp normalize(st) when st in ["B", "Y"], do: :paper
  defp normalize(st) when st in ["C", "Z"], do: :scissors

  defp score_strategy(:rock), do: 1
  defp score_strategy(:paper), do: 2
  defp score_strategy(:scissors), do: 3

  @doc """
  Day 2 - Part 2

  --- Part Two ---
  The Elf finishes helping with the tent and sneaks back over to you. "Anyway, the second column says how the round needs to end: X means you need to lose, Y means you need to end the round in a draw, and Z means you need to win. Good luck!"

  The total score is still calculated in the same way, but now you need to figure out what shape to choose so the round ends as indicated. The example above now goes like this:

  In the first round, your opponent will choose Rock (A), and you need the round to end in a draw (Y), so you also choose Rock. This gives you a score of 1 + 3 = 4.
  In the second round, your opponent will choose Paper (B), and you choose Rock so you lose (X) with a score of 1 + 0 = 1.
  In the third round, you will defeat your opponent's Scissors with Rock for a score of 1 + 6 = 7.
  Now that you're correctly decrypting the ultra top secret strategy guide, you would get a total score of 12.

  Following the Elf's instructions for the second column, what would your total score be if everything goes exactly according to your strategy guide?

  ## Examples

    iex> AdventOfCode.Y2022.Day2.part2()
    13187

  """

  def part2() do
    {_set, score} =
      setup()
      |> find_responses_and_score()

    score
  end

  defp find_responses_and_score(string_pairs) do
    string_pairs
    |> Enum.map_reduce(0, fn str, acc ->
      [o, st] = String.split(str, " ")
      [opp, str, outcome, score] = find_response(o, st)

      {
        %{
          opponent: opp,
          strategy: str,
          outcome: outcome,
          score: score
        },
        score + acc
      }
    end)
  end

  defp find_response(st, "X") do
    normalize(st)
    |> find_response(:lose)
  end

  defp find_response(st, "Y") do
    normalize(st)
    |> find_response(:tie)
  end

  defp find_response(st, "Z") do
    normalize(st)
    |> find_response(:win)
  end

  defp find_response(st, :tie), do: [st, st, :tie, 3 + score_strategy(st)]
  defp find_response(:rock, :lose), do: [:rock, :scissors, :lose, 0 + score_strategy(:scissors)]
  defp find_response(:rock, :win), do: [:rock, :paper, :lose, 6 + score_strategy(:paper)]
  defp find_response(:paper, :lose), do: [:paper, :rock, :lose, 0 + score_strategy(:rock)]
  defp find_response(:paper, :win), do: [:paper, :scissors, :win, 6 + score_strategy(:scissors)]
  defp find_response(:scissors, :lose), do: [:scissors, :paper, :lose, 0 + score_strategy(:paper)]
  defp find_response(:scissors, :win), do: [:scissors, :rock, :win, 6 + score_strategy(:rock)]
end
