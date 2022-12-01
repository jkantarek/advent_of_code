defmodule Mix.Tasks.NewDay do
  @moduledoc "The new day mix task: `mix help new_day`"
  use Mix.Task

  @shortdoc "Generate a new set of files for the next day."
  def run([year]) do
    [root, y, last_day] =
      Path.wildcard("lib/y_#{year}/*")
      |> extract_next_day(year)

    last_day
    |> next_day()
    |> generate_new_day(year)
    |> save_file(root, y)
    |> update_doctests(y, year)
  end

  defp extract_next_day([], year) do
    ["lib", "y_#{year}", "d0"]
  end

  defp extract_next_day(data, _year) do
    data
    |> Enum.max_by(fn p ->
      p
      |> String.split("/")
      |> List.last()
    end)
    |> String.split("/")
  end

  defp next_day("d" <> last_day_s) do
    {day, ""} = Integer.parse(last_day_s)
    day + 1
  end

  defp generate_new_day(day, year) do
    {:ok, str} = File.read("lib/mix/tasks/day.eex")
    res = EEx.eval_string(str, day: day, year: year)
    {res, day}
  end

  defp save_file({payload, day}, root, year_path) do
    [root, year_path, "d#{day}"]
    |> Enum.join("/")
    |> File.mkdir!()

    [root, year_path, "d#{day}", "day#{day}.ex"]
    |> Enum.join("/")
    |> File.write!(payload)

    day
  end

  defp update_doctests(day, year_path, year) do
    doctest_filename = ["test", year_path, "season_test.exs"] |> Enum.join("/")

    res =
      doctest_filename
      |> File.read!()

    split_file =
      res
      |> String.split("\n")

    {_docstring, max_idx} =
      split_file
      |> Enum.with_index()
      |> Enum.max_by(fn {elem, idx} ->
        extract_possible_index(elem, idx)
      end)

    {top, rest} = split_file |> Enum.split(max_idx + 1)

    changed_doctest =
      (top ++ ["  doctest AdventOfCode.Y#{year}.Day#{day}"] ++ rest)
      |> Enum.join("\n")

    File.write!(doctest_filename, changed_doctest, [])
  end

  defp extract_possible_index("  doctest AdventOfCode" <> _rest, idx), do: idx
  defp extract_possible_index(_any, _idx), do: 0
end
