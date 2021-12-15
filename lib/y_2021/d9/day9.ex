defmodule AdventOfCode.Y2021.Day9 do
  @moduledoc """

  """

  @doc """
    --- Day 9: Smoke Basin ---

  These caves seem to be lava tubes. Parts are even still volcanically active; small hydrothermal vents release smoke into the caves that slowly settles like rain.

  If you can model how the smoke flows through the caves, you might be able to avoid it and be that much safer. The submarine generates a heightmap of the floor of the nearby caves for you (your puzzle input).

  Smoke flows to the lowest point of the area it's in. For example, consider the following heightmap:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  Each number corresponds to the height of a particular location, where 9 is the highest and 0 is the lowest a location can be.

  Your first goal is to find the low points - the locations that are lower than any of its adjacent locations. Most locations have four adjacent locations (up, down, left, and right); locations on the edge or corner of the map have three or two adjacent locations, respectively. (Diagonal locations do not count as adjacent.)

  In the above example, there are four low points, all highlighted: two are in the first row (a 1 and a 0), one is in the third row (a 5), and one is in the bottom row (also a 5). All other locations on the heightmap have some lower adjacent location, and so are not low points.

  The risk level of a low point is 1 plus its height. In the above example, the risk levels of the low points are 2, 1, 6, and 6. The sum of the risk levels of all low points in the heightmap is therefore 15.

  Find all of the low points on your heightmap. What is the sum of the risk levels of all low points on your heightmap?


  ## Examples

    iex> AdventOfCode.Y2021.Day9.part1()
    518

  """

  def part1() do
    mapping =
      setup()
      |> build_mappings()

    mapping
    |> find_mins()
    |> sum_of_risk()
  end

  def build_mappings(rows) do
    rows
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, col_idx}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {v, row_idx}, row_acc ->
        row_acc |> Map.merge(%{{row_idx, col_idx} => v})
      end)
    end)
  end

  def find_mins(mapping) do
    mapping
    |> Enum.filter(fn {{row_idx, col_idx}, v} ->
      [
        mapping[{row_idx + 1, col_idx}],
        mapping[{row_idx - 1, col_idx}],
        mapping[{row_idx, col_idx + 1}],
        mapping[{row_idx, col_idx - 1}]
      ]
      |> Enum.all?(fn neighbor_v ->
        is_nil(neighbor_v) or v < neighbor_v
      end)
    end)
  end

  def sum_of_risk(mins) do
    mins
    |> Enum.reduce(0, fn {_xy, v}, acc -> acc + v + 1 end)
  end

  def setup() do
    AdventOfCode.etl_file(
      "lib/y_2021/d9/input.txt",
      &decode_row/1
    )
  end

  def decode_row(row) do
    row
    |> String.split("", trim: true)
    |> Enum.map(fn s ->
      {n, ""} = Integer.parse(s)
      n
    end)
  end

  @doc """
  --- Part Two ---

  Next, you need to find the largest basins so you know what areas are most important to avoid.

  A basin is all locations that eventually flow downward to a single low point. Therefore, every low point has a basin, although some basins are very small. Locations of height 9 do not count as being in any basin, and all other locations will always be part of exactly one basin.

  The size of a basin is the number of locations within the basin, including the low point. The example above has four basins.

  The top-left basin, size 3:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  The top-right basin, size 9:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  The middle basin, size 14:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  The bottom-right basin, size 9:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  Find the three largest basins and multiply their sizes together. In the above example, this is 9 * 14 * 9 = 1134.

  What do you get if you multiply together the sizes of the three largest basins?


  ## Examples

    iex> AdventOfCode.Y2021.Day9.part2()
    nil

  """

  def part2() do
  end
end
