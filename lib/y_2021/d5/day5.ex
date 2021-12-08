defmodule Vector do
  defstruct x1: 0,
            y1: 0,
            x2: 0,
            y2: 0,
            orientation: :point,
            slope: 0.0,
            covered_points: [],
            b: 0.0

  @type t(x1, y1, x2, y2, orientation, slope, covered_points, slope) :: %Vector{
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          orientation: orientation,
          slope: slope,
          covered_points: covered_points,
          slope: slope
        }

  def build(x1, y1, x2, y2) when x1 >= 0 and y1 >= 0 and x2 >= 0 and y2 >= 0 and x2 != x1 do
    orientation = compute_orientation(x1, y1, x2, y2)
    slope = (y2 - y1) / (x2 - x1)

    %Vector{
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      orientation: orientation,
      slope: slope,
      b: y1 - slope * x1,
      covered_points: covered_points(orientation, x1, y1, x2, y2, slope)
    }
  end

  def build(x1, y1, x2, y2) do
    orientation = compute_orientation(x1, y1, x2, y2)

    %Vector{
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      orientation: orientation,
      slope: 0,
      covered_points: covered_points(orientation, x1, y1, x2, y2, 0)
    }
  end

  def on_vector(v, x1, y1) do
    v.slope * x1 + v.b == y1
  end

  def intersect(v1, v2) when v1 == v2, do: true

  def intersect(%Vector{covered_points: c1}, %Vector{covered_points: c2})
      when length(c1) > 0 and length(c2) > 0 do
    true
  end

  def intersections(%Vector{covered_points: c1}, %Vector{covered_points: c2})
      when length(c1) > 0 and length(c2) > 0 do
    (c1 -- (c2 ++ (c2 -- c1))) |> length()
  end

  def intersections(_v1, _v2), do: 0

  defp covered_points(:horizontal, x1, y1, x2, y2, _m) do
    [x] = get_list(x1, x2)

    get_list(y1, y2)
    |> Enum.map(fn y -> {x, y} end)
  end

  defp covered_points(:vertical, x1, y1, x2, y2, _m) do
    [y] = get_list(y1, y2)

    get_list(x1, x2)
    |> Enum.map(fn x -> {x, y} end)
  end

  defp covered_points(:angle, x1, y1, x2, _y2, slope) do
    b = y1 - slope * x1

    Enum.to_list(x1..x2)
    |> Enum.map(fn x ->
      {x, normalize_f(slope * x + b)}
    end)
  end

  defp normalize_f(v) do
    if v == round(v) do
      round(v)
    else
      v
    end
  end

  defp get_list(p1, p2), do: Enum.to_list(p1..p2)

  defp compute_orientation(x1, y1, x2, y2) when x1 != x2 and y1 != y2, do: :angle
  defp compute_orientation(x1, y1, x2, y2) when x1 == x2 and y1 == y2, do: :point
  defp compute_orientation(x1, y1, x2, y2) when x1 == x2 and y1 != y2, do: :horizontal
  defp compute_orientation(x1, y1, x2, y2) when x1 != x2 and y1 == y2, do: :vertical
end

defmodule AdventOfCode.Y2021.Day5 do
  @moduledoc """
  --- Day 5: Hydrothermal Venture ---

  You come across a field of hydrothermal vents on the ocean floor! These vents constantly produce large, opaque clouds, so it would be best to avoid them if possible.

  They tend to form in lines; the submarine helpfully produces a list of nearby lines of vents (your puzzle input) for you to review. For example:

  0,9 -> 5,9
  8,0 -> 0,8
  9,4 -> 3,4
  2,2 -> 2,1
  7,0 -> 7,4
  6,4 -> 2,0
  0,9 -> 2,9
  3,4 -> 1,4
  0,0 -> 8,8
  5,5 -> 8,2

  Each line of vents is given as a line segment in the format x1,y1 -> x2,y2 where x1,y1 are the coordinates of one end the line segment and x2,y2 are the coordinates of the other end. These line segments include the points at both ends. In other words:

      An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
      An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.

  For now, only consider horizontal and vertical lines: lines where either x1 = x2 or y1 = y2.

  So, the horizontal and vertical lines from the above list would produce the following diagram:

  .......1..
  ..1....1..
  ..1....1..
  .......1..
  .112111211
  ..........
  ..........
  ..........
  ..........
  222111....

  In this diagram, the top left corner is 0,0 and the bottom right corner is 9,9. Each position is shown as the number of lines which cover that point or . if no line covers that point. The top-left pair of 1s, for example, comes from 2,2 -> 2,1; the very bottom row is formed by the overlapping lines 0,9 -> 5,9 and 0,9 -> 2,9.

  To avoid the most dangerous areas, you need to determine the number of points where at least two lines overlap. In the above example, this is anywhere in the diagram with a 2 or larger - a total of 5 points.

  Consider only horizontal and vertical lines. At how many points do at least two lines overlap?

  """

  @doc """
  Day 1 - Part 1

  ## Examples

    iex> AdventOfCode.Y2021.Day5.part1()
    5442

  """

  def part1() do
    setup()
    |> Enum.reject(fn v -> v.orientation == :angle end)
    |> Enum.flat_map(fn v -> v.covered_points end)
    |> Enum.frequencies()
    |> Enum.filter(fn {_k, v} -> v >= 2 end)
    |> length()
  end

  def setup() do
    AdventOfCode.etl_file(
      "lib/y_2021/d5/input.txt",
      &compute_lines/1
    )
  end

  defp compute_lines(row) do
    [start_pos, end_pos] = row |> String.split(" -> ")
    build_coord(start_pos, end_pos)
  end

  defp build_coord(start_pos, end_pos) do
    [x1, y1] = to_xy(start_pos)
    [x2, y2] = to_xy(end_pos)
    Vector.build(x1, y1, x2, y2)
  end

  defp to_xy(xy) do
    xy
    |> String.split(",")
    |> Enum.map(fn st ->
      {n, ""} = Integer.parse(st)
      n
    end)
  end

  @doc """
  Day 5 - Part 2

  ## Examples

    iex> AdventOfCode.Y2021.Day5.part2()
    19571

  """

  def part2() do
    lines = setup()

    lines
    |> Enum.flat_map(fn v -> v.covered_points end)
    |> Enum.frequencies()
    |> Enum.filter(fn {_k, v} -> v >= 2 end)
    |> length()
  end
end
