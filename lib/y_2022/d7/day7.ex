defmodule AdventOfCode.Y2022.Day7 do
  @moduledoc """

  """

  @doc """
  Day 7 - Part 1

  --- Day 7: No Space Left On Device ---

  You can hear birds chirping and raindrops hitting leaves as the expedition proceeds. Occasionally, you can even hear much louder sounds in the distance; how big do the animals get out here, anyway?

  The device the Elves gave you has problems with more than just its communication system. You try to run a system update:

  $ system-update --please --pretty-please-with-sugar-on-top
  Error: No space left on device

  Perhaps you can delete some files to make space for the update?

  You browse around the filesystem to assess the situation and save the resulting terminal output (your puzzle input). For example:

  $ cd /
  $ ls
  dir a
  14848514 b.txt
  8504156 c.dat
  dir d
  $ cd a
  $ ls
  dir e
  29116 f
  2557 g
  62596 h.lst
  $ cd e
  $ ls
  584 i
  $ cd ..
  $ cd ..
  $ cd d
  $ ls
  4060174 j
  8033020 d.log
  5626152 d.ext
  7214296 k

  The filesystem consists of a tree of files (plain data) and directories (which can contain other directories or files). The outermost directory is called /. You can navigate around the filesystem, moving into or out of directories and listing the contents of the directory you're currently in.

  Within the terminal output, lines that begin with $ are commands you executed, very much like some modern computers:

    cd means change directory. This changes which directory is the current directory, but the specific result depends on the argument:
        cd x moves in one level: it looks in the current directory for the directory named x and makes it the current directory.
        cd .. moves out one level: it finds the directory that contains the current directory, then makes that directory the current directory.
        cd / switches the current directory to the outermost directory, /.
    ls means list. It prints out all of the files and directories immediately contained by the current directory:
        123 abc means that the current directory contains a file named abc with size 123.
        dir xyz means that the current directory contains a directory named xyz.

  Given the commands and output in the example above, you can determine that the filesystem looks visually like this:

  - / (dir)
  - a (dir)
    - e (dir)
      - i (file, size=584)
    - f (file, size=29116)
    - g (file, size=2557)
    - h.lst (file, size=62596)
  - b.txt (file, size=14848514)
  - c.dat (file, size=8504156)
  - d (dir)
    - j (file, size=4060174)
    - d.log (file, size=8033020)
    - d.ext (file, size=5626152)
    - k (file, size=7214296)

  Here, there are four directories: / (the outermost directory), a and d (which are in /), and e (which is in a). These directories also contain files of various sizes.

  Since the disk is full, your first step should probably be to find directories that are good candidates for deletion. To do this, you need to determine the total size of each directory. The total size of a directory is the sum of the sizes of the files it contains, directly or indirectly. (Directories themselves do not count as having any intrinsic size.)

  The total sizes of the directories above can be found as follows:

    The total size of directory e is 584 because it contains a single file i of size 584 and no other directories.
    The directory a has total size 94853 because it contains files f (size 29116), g (size 2557), and h.lst (size 62596), plus file i indirectly (a contains e which contains i).
    Directory d has total size 24933642.
    As the outermost directory, / contains every file. Its total size is 48381165, the sum of the size of every file.

  To begin, find all of the directories with a total size of at most 100000, then calculate the sum of their total sizes. In the example above, these directories are a and e; the sum of their total sizes is 95437 (94853 + 584). (As in this example, this process can count files more than once!)

  Find all of the directories with a total size of at most 100000. What is the sum of the total sizes of those directories?


  ## Examples

    iex> AdventOfCode.Y2022.Day7.part1()
    1778099

    iex> res = AdventOfCode.Y2022.Day7.sample()
    ...> res["/d/"].size
    24933642

    iex> res = AdventOfCode.Y2022.Day7.sample()
    ...> res["/a/"].size
    94853

    iex> res = AdventOfCode.Y2022.Day7.sample()
    ...> res["/"].size
    48381165

  """

  def sample() do
    setup("test_input.txt")
    |> reduce_data(%{cursor_arr: [], cursor_path: "", files: %{}})
  end

  def part1() do
    setup("input.txt")
    |> reduce_data(%{cursor_arr: [], cursor_path: "", files: %{}})
    |> Enum.reduce(0, fn {_k, %{size: size, type: type}}, acc ->
      acc + sum_size(size, type)
    end)
  end

  def sum_size(size, :dir) when size <= 100_000, do: size
  def sum_size(_s, _t), do: 0

  def reduce_data([%{type: :cd, val: _r} = _c | rest], %{
        cursor_arr: [],
        cursor_path: "",
        files: %{}
      }) do
    reduce_data(rest, %{cursor_arr: ["/"], cursor_path: "/", files: %{}})
  end

  def reduce_data([%{type: :list} = _c | rest], data) do
    reduce_data(rest, data)
  end

  def reduce_data([%{type: :dir, val: _d} = _c | rest], %{
        cursor_arr: arr,
        cursor_path: p,
        files: f
      }) do
    reduce_data(rest, %{cursor_arr: arr, cursor_path: p, files: f})
  end

  def reduce_data(
        [%{type: :cd, val: :up} = _c | commands],
        %{
          cursor_arr: arr,
          files: f
        } = _m
      ) do
    {_v, [r | rest] = up_arr} = List.pop_at(arr, -1)
    path = "#{r}#{Enum.join(rest, "/")}"
    reduce_data(commands, %{cursor_arr: up_arr, cursor_path: path, files: f})
  end

  def reduce_data([%{type: :cd, val: dir} = _c | rest], %{
        cursor_arr: arr,
        cursor_path: p,
        files: f
      }) do
    reduce_data(rest, %{cursor_arr: arr ++ [dir], cursor_path: "#{p}#{dir}/", files: f})
  end

  def reduce_data([], %{files: f} = _acc), do: f

  def reduce_data([%{type: :file_size, val: _filename} = c | rest], %{
        cursor_arr: arr,
        cursor_path: p,
        files: f
      }) do
    paths = build_paths(arr)
    {files, commands} = build_files_until_command(paths, [c] ++ rest, f)
    reduce_data(commands, %{cursor_arr: arr, cursor_path: p, files: files})
  end

  def build_paths(arr) do
    length(arr)..1
    |> Enum.to_list()
    |> Enum.map(fn idx ->
      [root | rest] =
        arr
        |> Enum.take(idx)

      build_path(root, rest)
    end)
  end

  @spec build_path(any, any) :: nonempty_binary
  def build_path("/", []), do: "/"

  def build_path(root, rest) do
    "#{root}#{Enum.join(rest, "/")}/"
  end

  def build_files_until_command(
        [path | paths] = all_paths,
        [%{type: :file_size, val: filename, size: size} | rest],
        f
      ) do
    directory = f[path] || %{size: 0, type: :dir}

    payload =
      Map.merge(
        sum_parent_dirs(paths, size, f),
        %{
          "#{path}#{filename}" => %{size: size, type: :file},
          path => %{size: directory.size + size, type: :dir}
        }
      )

    files = Map.merge(f, payload)

    build_files_until_command(all_paths, rest, files)
  end

  def build_files_until_command(_paths, commands, files) do
    {files, commands}
  end

  def sum_parent_dirs([], _s, files), do: files

  def sum_parent_dirs([folder | rest], size, f) do
    dir = f[folder] || %{size: 0, type: :dir}

    files = Map.merge(f, %{folder => %{size: dir.size + size, type: :dir}})
    sum_parent_dirs(rest, size, files)
  end

  def decoder("$ " <> command) do
    decoder(command)
  end

  def decoder("dir " <> dir) do
    %{type: :dir, val: dir, size: 0}
  end

  def decoder("cd ..") do
    %{type: :cd, val: :up, size: nil}
  end

  def decoder("cd " <> dir) do
    %{type: :cd, val: dir, size: 0}
  end

  def decoder("ls"), do: %{type: :list, val: "ls", size: nil}

  def decoder(line) do
    {int, " " <> filename} = Integer.parse(line)
    %{type: :file_size, val: filename, size: int}
  end

  def setup(filename) do
    AdventOfCode.etl_file(
      "lib/y_2022/d7/#{filename}",
      &decoder/1,
      &AdventOfCode.split_newline/1,
      %{reject_blanks: true, reject_nils: true}
    )
  end

  @doc """
  Day 7 - Part 2

  --- Part Two ---
  Now, you're ready to choose a directory to delete.

  The total disk space available to the filesystem is 70000000. To run the update, you need unused space of at least 30000000. You need to find a directory you can delete that will free up enough space to run the update.

  In the example above, the total size of the outermost directory (and thus the total amount of used space) is 48381165; this means that the size of the unused space must currently be 21618835, which isn't quite the 30000000 required by the update. Therefore, the update still requires a directory with total size of at least 8381165 to be deleted before it can run.

  To achieve this, you have the following options:

  Delete directory e, which would increase unused space by 584.
  Delete directory a, which would increase unused space by 94853.
  Delete directory d, which would increase unused space by 24933642.
  Delete directory /, which would increase unused space by 48381165.
  Directories e and a are both too small; deleting them would not free up enough space. However, directories d and / are both big enough! Between these, choose the smallest: d, increasing unused space by 24933642.

  Find the smallest directory that, if deleted, would free up enough space on the filesystem to run the update. What is the total size of that directory?

  ## Examples

    iex> AdventOfCode.Y2022.Day7.part2()
    1623571

  """

  def part2() do
    files =
      setup("input.txt")
      |> reduce_data(%{cursor_arr: [], cursor_path: "", files: %{}})

    remaining_on_disk = 70_000_000 - files["/"].size
    target_size = 30_000_000 - remaining_on_disk

    [min | _r] =
      files
      |> Enum.reduce([], fn {path, %{size: size, type: type}}, arr ->
        arr ++ select_element(path, size, type, target_size)
      end)
      |> Enum.sort_by(fn %{difference: d} = _s -> d end)

    min.size
  end

  def select_element(path, size, :dir, target) when size >= target do
    [
      %{path: path, size: size, difference: size - target}
    ]
  end

  def select_element(_p, _s, type, _t) when type in [:file, :dir], do: []
end
