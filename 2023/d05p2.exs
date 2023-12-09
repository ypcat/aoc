#!/usr/bin/env elixir
# map \r :w<cr>:term elixir %<cr>

input = """
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""

input = File.read! "d05p2.txt"

sections = input
|> String.split("\n\n", trim: true)

seeds = sections
|> hd()
|> String.split()
|> tl()
|> Enum.map(&String.to_integer(&1))
|> Enum.chunk_every(2)
|> Enum.map(fn [start, len] -> {start, start + len - 1} end)

maps = sections
|> tl()
|> Enum.map(fn map ->
  String.split(map, "\n", trim: true)
  |> tl()
  |> Enum.map(fn segment ->
    [dst, src, len] = segment
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    {{src, src + len - 1}, {dst, dst + len - 1}}
  end)
end)

defmodule Day5 do
  def tr(_seed={a, b}, _seg={{c, d}, {e, f}}) do
    cond do
      b < c or d < a -> {[{a, b}], []} # a b c d || c d a b
      c <= a and b <= d -> {[], [{e+a-c, e+b-c}]} # c a b d
      a < c and c <= b and b <= d -> {[{a, c-1}], [{e, e+b-c}]} # a c b d
      c <= a and a <= d and d < b -> {[{d+1, b}], [{e+a-c, f}]} # c a d b
      a < c and d < b -> {[{a, c-1}, {d+1, b}], [{e, f}]} # a c d b
    end
    #|> IO.inspect(label: inspect [seed: {a, b}, seg: {{c, d}, {e, f}}])
  end

  def tr(seeds, seg={_, _}) when is_list(seeds) do
    Enum.reduce(seeds, {[], []}, fn seed, {unmapped_seeds1, mapped_seeds1} ->
      {unmapped_seeds2, mapped_seeds2} = tr(seed, seg)
      {unmapped_seeds1 ++ unmapped_seeds2, mapped_seeds1 ++ mapped_seeds2}
    end)
    #|> IO.inspect(label: inspect [seeds: seeds, seg: seg])
  end

  def tr(seed={_, _}, map=[{_, _}| _]) do
    tr([seed], map)
    #|> IO.inspect(label: inspect [seed: seed, map: map])
  end

  def tr(seeds=[_| _], map=[{_, _}| _]) do
    {unmapped_seeds, mapped_seeds} =
    Enum.reduce(map, {seeds, []}, fn seg, {unmapped_seeds1, mapped_seeds1} ->
      {unmapped_seeds2, mapped_seeds2} = tr(unmapped_seeds1, seg)
      {unmapped_seeds2, mapped_seeds1 ++ mapped_seeds2}
    end)
    unmapped_seeds ++ mapped_seeds
    |>Enum.sort()|>Enum.uniq() |> IO.inspect(label: inspect([seeds: seeds, map: map]), limit: :infinity)
  end

#  def tr(seed={_, _}, maps=[[_| _]| _]) do
#    tr([seed], maps)
#    |> IO.inspect(label: inspect [seed: seed, maps: maps])
#  end

  def tr(seeds=[_| _], maps=[[_| _]| _]) do
    Enum.reduce(maps, seeds, fn map, acc -> tr(acc, map) end)
    #|> IO.inspect(label: inspect [seeds: seeds, maps: maps])
  end
end

Day5.tr(seeds, maps)
#Day5.tr({388496072, 463759737}, {{413575139, 551749092}, {0, 138173953}}) |> IO.inspect
|> Enum.min()
#|> elem(0)
|> IO.inspect(label: "Answer")

