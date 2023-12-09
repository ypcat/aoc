#!/usr/bin/env elixir

_input = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""

input = File.read!("d09.txt")

input
|> String.split("\n", trim: true)
|> Enum.map(fn s ->
  a = String.split(s) |> Enum.map(&String.to_integer/1)
  Enum.reduce_while(a, {a, []}, fn _, {[h|t]=b, c} ->
    d = Enum.zip(b, t) |> Enum.map(fn {x, y} -> y - x end)
    case Enum.all?(d, & &1 == 0) do
      true -> {:halt, Enum.reduce([h | c], 0, & &1 - &2)}
      false -> {:cont, {d, [h | c]}}
    end
  end)
end)
|> Enum.sum()
|> IO.inspect(charlists: :as_lists)

