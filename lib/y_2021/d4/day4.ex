defmodule AdventOfCode.Y2021.Day4 do
  @moduledoc """
  --- Day 4: Giant Squid ---

  You're already almost 1.5km (almost a mile) below the surface of the ocean, already so deep that you can't see any sunlight. What you can see, however, is a giant squid that has attached itself to the outside of your submarine.

  Maybe it wants to play bingo?

  Bingo is played on a set of boards each consisting of a 5x5 grid of numbers. Numbers are chosen at random, and the chosen number is marked on all boards on which it appears. (Numbers may not appear on all boards.) If all numbers in any row or any column of a board are marked, that board wins. (Diagonals don't count.)

  The submarine has a bingo subsystem to help passengers (currently, you and the giant squid) pass the time. It automatically generates a random order in which to draw numbers and a random set of boards (your puzzle input). For example:

  7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

  22 13 17 11  0
   8  2 23  4 24
  21  9 14 16  7
   6 10  3 18  5
   1 12 20 15 19

   3 15  0  2 22
   9 18 13 17  5
  19  8  7 25 23
  20 11 10 24  4
  14 21 16 12  6

  14 21 17 24  4
  10 16 15  9 19
  18  8 23 26 20
  22 11 13  6  5
   2  0 12  3  7

  After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no winners, but the boards are marked as follows (shown here adjacent to each other to save space):

  22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
   8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
  21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
   6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
   1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

  After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are still no winners:

  22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
   8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
  21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
   6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
   1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

  Finally, 24 is drawn:

  22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
   8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
  21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
   6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
   1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

  At this point, the third board wins because it has at least one complete row or column of marked numbers (in this case, the entire top row is marked: 14 21 17 24 4).

  The score of the winning board can now be calculated. Start by finding the sum of all unmarked numbers on that board; in this case, the sum is 188. Then, multiply that sum by the number that was just called when the board won, 24, to get the final score, 188 * 24 = 4512.

  To guarantee victory against the giant squid, figure out which board will win first. What will your final score be if you choose that board?

  """

  @doc """
  Day 1 - Part 1

  ## Examples

    # iex> AdventOfCode.Y2021.Day4.part1()
    # 2496

  """

  def part1() do
    {numbers, boards} = setup()

    find_winner(numbers, boards, false, &no_op/1)
    |> get_score()
  end

  def no_op(v), do: v

  defp setup() do
    [numbers_str | rest] =
      AdventOfCode.etl_file(
        "lib/y_2021/d4/input.txt",
        fn x -> x end,
        %{reject_blanks: false, reject_nils: true}
      )

    numbers =
      numbers_str
      |> String.split(",")
      |> Enum.map(fn n ->
        {num, ""} = Integer.parse(n)
        num
      end)

    boards =
      build_boards(rest, [])
      |> Enum.with_index()
      |> Enum.map(fn {board, idx} -> BingoBoard.build(board, idx) end)

    {numbers, boards}
  end

  defp build_boards([], boards), do: boards

  defp build_boards([""], boards), do: boards

  defp build_boards(["" | rest], boards) do
    {board, remaining} = rest |> Enum.split_while(fn elem -> elem != "" end)
    build_boards(remaining, boards ++ [generate_unmarked_board(board)])
  end

  defp generate_unmarked_board(board) do
    board
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, r_idx}, acc ->
      row
      |> String.split(~r{\s+})
      |> Enum.reject(fn elem -> elem == "" || is_nil(elem) end)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {str, c_idx}, sub_acc ->
        {num, ""} = Integer.parse(str)
        Map.merge(sub_acc, %{{r_idx, c_idx} => num})
      end)
    end)
  end

  defp find_winner([next_number | rest], boards, false, next_board_limiter) do
    next_boards =
      boards
      |> Enum.map(fn board -> BingoBoard.mark_position(board, next_number) end)
      |> next_board_limiter.()

    find_winner(
      rest,
      next_boards,
      Enum.any?(next_boards, fn board -> board.won == true end),
      next_board_limiter
    )
  end

  defp find_winner(_, boards, true, _) do
    boards
    |> Enum.find(fn board -> board.won == true end)
  end

  defp get_score(%{marked_positions: positions} = board) do
    sum =
      positions
      |> Enum.reduce(0, fn {k, v}, acc ->
        if v == false do
          acc + board.board[k]
        else
          acc
        end
      end)

    sum * board.last_mark
  end

  @doc """
  Day 4 - Part 2

  ## Examples

    iex> AdventOfCode.Y2021.Day4.part2()
    25925

  """

  def part2() do
    {numbers, boards} = setup()

    find_winner(numbers, boards, false, &reject_all_but_last_winner/1)
    |> get_score()
  end

  def reject_all_but_last_winner([board]), do: [board]

  def reject_all_but_last_winner(boards) do
    res = boards |> Enum.reject(fn %{won: won} -> won == true end)

    if res == [] do
      boards
    else
      res
    end
  end
end

defmodule BingoBoard do
  defstruct id: 0, board: %{}, values: [], marked_positions: %{}, won: false, last_mark: 0

  @type t(id, board, values, marked_positions, won) :: %BingoBoard{
          id: id,
          board: board,
          values: values,
          marked_positions: marked_positions,
          won: won,
          last_mark: 0
        }
  def build(input_board, id) do
    %BingoBoard{
      id: id,
      board: input_board,
      values: input_board |> Map.values(),
      marked_positions:
        input_board
        |> Enum.reduce(%{}, fn {key, _val}, acc -> Map.merge(acc, %{key => false}) end),
      won: false,
      last_mark: 0
    }
  end

  def mark_position(%BingoBoard{values: values} = board, mark) do
    values
    |> Enum.member?(mark)
    |> evaluate_mark(board, mark)
  end

  defp evaluate_mark(false, board, _mark), do: board

  defp evaluate_mark(true, board, mark) do
    {key, _v} =
      board.board
      |> Enum.find(fn {_k, v} ->
        v == mark
      end)

    new_marks = Map.merge(board.marked_positions, %{key => true})

    rows =
      new_marks
      |> Enum.group_by(fn {{r_idx, _c_idx}, _val} ->
        r_idx
      end)

    cols =
      new_marks
      |> Enum.group_by(fn {{_r_idx, c_idx}, _val} ->
        c_idx
      end)

    rows_winner =
      rows
      |> Enum.any?(fn {_k, row} ->
        row |> Enum.all?(fn {_k, v} -> v end)
      end)

    cols_winner =
      cols
      |> Enum.any?(fn {_k, col} ->
        col |> Enum.all?(fn {_k, v} -> v end)
      end)

    %BingoBoard{
      id: board.id,
      board: board.board,
      values: board.values,
      marked_positions: new_marks,
      won: rows_winner || cols_winner,
      last_mark: mark
    }
  end
end
