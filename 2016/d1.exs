#!/usr/bin/env elixir

input = """
L4, R2, R4, L5, L3, L1, R4, R5, R1, R3, L3, L2, L2, R5, R1, L1, L2, R2, R2, L5, R5, R5, L2, R1, R2, L2, L4, L1, R5, R2, R1, R1, L2, L3, R2, L5, L186, L5, L3, R3, L5, R4, R2, L5, R1, R4, L1, L3, R3, R1, L1, R4, R2, L1, L4, R5, L1, R50, L4, R3, R78, R4, R2, L4, R3, L4, R4, L1, R5, L4, R1, L2, R3, L2, R5, R5, L4, L1, L2, R185, L5, R2, R1, L3, R4, L5, R2, R4, L3, R4, L2, L5, R1, R2, L2, L1, L2, R2, L2, R1, L5, L3, L4, L3, L4, L2, L5, L5, R2, L3, L4, R4, R4, R5, L4, L2, R4, L5, R3, R1, L1, R3, L2, R2, R1, R5, L4, R5, L3, R2, R3, R1, R4, L4, R1, R3, L5, L1, L3, R2, R1, R4, L4, R3, L3, R3, R2, L3, L3, R4, L2, R4, L3, L4, R5, R1, L1, R5, R3, R1, R3, R4, L1, R4, R3, R1, L5, L5, L4, R4, R3, L2, R1, R5, L3, R4, R5, L4, L5, R2
"""

input
|> String.split("\n", trim: true)
|> Enum.map(fn q ->
  String.split(q, ", ")
  |> Enum.reduce({{0, 0}, [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]}, fn s, {{x, y}, dirs} ->
    {c, d} = String.split_at(s, 1)
    {a, b} = Enum.split(dirs, c == "R" && 1 || 3)
    [{u, v} | _]=new_dirs = b ++ a
    n = String.to_integer(d)
    {{x + u * n, y + v * n}, new_dirs}
  end)
  |> then(fn {{x, y}, _} -> abs(x) + abs(y) end)
end)
|> IO.inspect(label: :part1, charlists: :as_lists)

input
|> String.split(", ", trim: true)
|> Enum.reduce_while({{0, 0}, [{0, 1}, {1, 0}, {0, -1}, {-1, 0}], MapSet.new()}, fn s, {{x, y}, dirs, visited} ->
  [{u, v} | _]=new_dirs = Enum.slide(dirs, 0..(s =~ "R" && 0 || 2), 3)
  n = String.slice(s, 1..-1) |> String.to_integer()
  Enum.reduce_while(1..n, visited, fn i, acc ->
    p = {x + u * i, y + v * i}
    p in acc && {:halt, p} || {:cont, MapSet.put(acc, p)}
  end)
  |> case do
    {xi, yi} -> {:halt, abs(xi) + abs(yi)}
    new_visited -> {:cont, {{x + u * n, y + v * n}, new_dirs, new_visited}}
  end
end)
|> IO.inspect(label: :part2, charlists: :as_lists)

