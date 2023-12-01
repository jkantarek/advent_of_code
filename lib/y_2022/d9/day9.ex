defmodule AdventOfCode.Y2022.Day9 do
  @moduledoc """

  """

  @doc """
  Day 9 - Part 1

  ## Examples

    iex> AdventOfCode.Y2022.Day9.part1()
    nil

    iex>{_p, visits} = AdventOfCode.Y2022.Day9.sample()
    ...> visits[:T] |> MapSet.size()
    13



  """

  alias AdventOfCode.Y2022.Day9, as: Self

  def direction_lambda(d) do
    {:ok, lam} =
      %{
        "U" => fn {x, y}, c -> {x, y + c} end,
        "D" => fn {x, y}, c -> {x, y - c} end,
        "L" => fn {x, y}, c -> {x - c, y} end,
        "R" => fn {x, y}, c -> {x + c, y} end
      }
      |> Map.fetch(d)

    lam
  end

  def sample() do
    r =
      setup("test_input.txt")
      |> walk_rope(%{T: {0, 0}, H: {0, 0}}, %{H: MapSet.new(), T: MapSet.new()})

    r
  end

  def part1() do
    setup("input.txt")
    nil
  end

  def walk_rope([], final_pos, visits), do: {final_pos, visits}

  def walk_rope([{dir, count} | rest], %{T: t_pos, H: h_pos}, visits) do
    {hn, tn, vn} = move_and_mark_visits(dir, count, h_pos, t_pos, visits)

    if dir == "U" do
      require IEx
      IEx.pry()
    end

    walk_rope(rest, %{T: tn, H: hn}, vn)
  end

  @spec move_and_mark_visits(any, non_neg_integer, any, any, any) :: {any, any, any}
  def move_and_mark_visits(dir, count, h_pos, t_pos, visits) do
    direction_lambda(dir)
    |> move(count, h_pos, t_pos, visits)
  end

  def move(lam, count, h_pos, t_pos, visits) when count > 0 do
    {hn, tn, vn} = step(lam, h_pos, t_pos, visits)
    move(lam, count - 1, hn, tn, vn)
  end

  def move(_l, 0, h_pos, t_pos, visits) do
    {h_pos, t_pos, visits}
  end

  def step(lam, h_pos, t_pos, visits) do
    h1 = lam.(h_pos, 1)
    t1 = shift_t(h1, t_pos, lam)
    v1 = add_visits(visits, h1, t1)
    {h1, t1, v1}
  end

  def add_visits(%{H: h, T: t}, h1, t1) do
    %{
      H: MapSet.put(h, h1),
      T: MapSet.put(t, t1)
    }
  end

  def shift_t({hx, hy}, {tx, ty} = t, lam) do
    hxs = (hx - 1)..(hx + 1) |> Enum.to_list()
    hys = (hy - 1)..(hy + 1) |> Enum.to_list()

    if Enum.member?(hxs, tx) && Enum.member?(hys, ty) do
      {tx, ty}
    else
      lam.(t, 1)
    end
  end

  def decoder(line) do
    [dir, count] =
      line
      |> String.split(" ")

    {n, ""} = Integer.parse(count)
    {dir, n}
  end

  def setup(filename) do
    AdventOfCode.etl_file(
      "lib/y_2022/d9/#{filename}",
      &decoder/1,
      &AdventOfCode.split_newline/1,
      %{reject_blanks: true, reject_nils: true}
    )
  end

  @doc """
  Day 9 - Part 2

  ## Examples

    iex> AdventOfCode.Y2022.Day9.part2()
    nil

  """

  def part2() do
  end
end
