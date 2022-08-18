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
      |> build_mappings(&pass/2)

    mapping
    |> find_mins()
    |> sum_of_risk()
  end

  def pass(_k, _v), do: true

  def build_mappings(rows, filter) do
    rows
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, col_idx}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {v, row_idx}, row_acc ->
        k = {row_idx, col_idx}

        if filter.(k, v) do
          row_acc |> Map.merge(%{k => v})
        else
          row_acc
        end
      end)
    end)
  end

  def find_mins(mapping) do
    mapping
    |> Enum.filter(fn {{row_idx, col_idx}, v} ->
      get_adjacent(row_idx, col_idx, mapping)
      |> Enum.all?(fn neighbor_v ->
        is_nil(neighbor_v) or v < neighbor_v
      end)
    end)
  end

  def get_adjacent(row_idx, col_idx, mapping) do
    [
      mapping[{row_idx + 1, col_idx}],
      mapping[{row_idx - 1, col_idx}],
      mapping[{row_idx, col_idx + 1}],
      mapping[{row_idx, col_idx - 1}]
    ]
    |> Enum.reject(fn v -> is_nil(v) end)
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
    mapping =
      setup()
      |> build_mappings(&reject_nines/2)

    mins = find_mins(mapping)

    [one, two, three | _rest] =
      mapping
      |> find_mins()
      |> build_pools(mapping, %{})
      |> sort_pools_by_size()

    require IEx
    IEx.pry()
    # [one, two, three | _rest] = sort_by_size_with_value(mins, mapping)
    # group_valleys(mins, mapping)
    # one * two * three
  end

  def build_pools([{{x,y}, val} | rest], mapping, acc) do
    { pool, remaining_mapping } = get_pool(x, y, mapping)
  end

  def get_pool(x, y, mapping) do
    keys = build_keys(x,y)
    {matches, rest} = mapping
    |> Enum.split(keys)
    require IEx
    IEx.pry()
  end

  def build_keys(x, y) do
    [
      {x,y},
      {x+1, y},
      {x-1, y},
      {x, y+1},
      {x, y-1},
      {x+1, y+1},
      {x-1, y-1}
    ]
  end

  def build_pools([], _mapping, acc), do: acc

  def sort_pools_by_size(pools) do
  end

  def group_valleys(mapping) do
    mapping
    |> Map.keys()
    |> Enum.reduce([], fn {x, y}, acc ->
      find_and_inject(acc, x, y)
    end)
  end

  def find_and_inject([], x, y), do: [[{x, y}]]

  def find_and_inject(acc, x, y) do
    {present, rem} =
      acc
      |> Enum.split_with(fn grouping ->
        require IEx

        if grouping == [{66, 43}] || grouping == [[{66, 43}]] do
          IEx.pry()
        end

        grouping
        |> Enum.any?(fn {prev_x, prev_y} ->
          [
            {prev_x + 1, prev_y + 1} == {x, y},
            {prev_x + 0, prev_y + 1} == {x, y},
            {prev_x + 1, prev_y + 0} == {x, y},
            {prev_x - 1, prev_y - 1} == {x, y},
            {prev_x - 1, prev_y + 0} == {x, y},
            {prev_x + 0, prev_y - 1} == {x, y}
          ]
          |> Enum.any?(fn x -> x end)
        end)
      end)

    [present ++ [{x, y}] | rem]
  end

  def sort_by_size_with_value(mins, mapping) do
    mins
    |> Enum.map(fn {{r, c}, _v} ->
      v = get_adjacent(r, c, mapping)
      require IEx
      IEx.pry()
    end)
  end

  def reject_nines(_key, val) do
    val != 9
  end

  def to_map(arr) do
    arr
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.merge(acc, %{k => v}) end)
  end

  def group_valleys(mins, mapping) do
    {{k, val}, rest_mins} = take_one_from_map(mins)
    [valley, filtered_mins, rest_mapping] = fetch_and_filter_valley(k, val, rest_mins, mapping)
    require IEx
    IEx.pry()
  end

  def take_one_from_map(map) do
    key = map |> Map.keys() |> List.first()
    {{key, map[key]}, Map.delete(map, key)}
  end

  def fetch_and_filter_valley({row, col}, point_val, mins, mapping) do
    {adjs, new_mapping} = get_adjacent_with_idx(row, col, mapping)
    require IEx
    IEx.pry()
  end

  def get_recursive_adjacent(acc, row_idx, col_idx, mapping) do
  end

  def get_adjacent_with_idx(row_idx, col_idx, mapping) do
    adjs =
      [
        {{row_idx + 1, col_idx}, mapping[{row_idx + 1, col_idx}]},
        {{row_idx - 1, col_idx}, mapping[{row_idx - 1, col_idx}]},
        {{row_idx, col_idx + 1}, mapping[{row_idx, col_idx + 1}]},
        {{row_idx, col_idx - 1}, mapping[{row_idx, col_idx - 1}]}
      ]
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    filtered_mapping =
      adjs
      |> Enum.reduce(Map.delete(mapping, {row_idx, col_idx}), fn {pos, _v}, acc ->
        Map.delete(acc, pos)
      end)

    {adjs, filtered_mapping}
  end
end
