#!/usr/bin/env elixir

_input = """
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
"""

_input = """
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
"""

_input = """
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"""

input = File.read!("d08.txt")

[h | t] = String.split(input, "\n", trim: true)
#IO.inspect(String.length h)
maps = Enum.into(t, %{}, fn line ->
  [node, left, right | _] = String.split(line, ~r/\W+/)
  {node, %{?L => left, ?R => right}}
end)
start_nodes = Map.keys(maps)
|> Enum.filter(&String.ends_with?(&1, "A"))
String.to_charlist(h)
|> Stream.cycle()
|> Enum.reduce_while({0, Map.from_keys(start_nodes, [])}, fn dir, {step, nodes} ->
  nodes = Enum.map(nodes, fn {node, laps} ->
    node = maps[node][dir]
    laps = if String.ends_with?(node, "Z"), do: laps ++ [step + 1], else: laps
    {node, laps}
  end)
  case Enum.all?(nodes, fn {_node, laps} -> length(laps) > 3 end) do
    true -> {:halt, nodes}
    false -> {:cont, {step + 1, nodes}}
  end
end)
|> IO.inspect()
#iex(11)> c = a |> Enum.map(fn {_, b} -> {hd(b), Enum.map(Enum.zip(b, tl b), fn {x, y} -> y - x end)} end) |> Enum.map(fn {k, _} -> k end)
#[15517, 20777, 19199, 13939, 12361, 17621]
#iex(6)> Enum.chunk_every(c, 2, 1, :discard)
#[[15517, 20777], [20777, 19199], [19199, 13939], [13939, 12361], [12361, 17621]]
#iex(7)> Enum.chunk_every(c, 2, 1, :discard) |> Enum.map(fn [x, y] -> Integer.gcd(x, y) end)
#[263, 263, 263, 263, 263]
#iex(9)> Enum.map(c, & &1 / 263) |> Enum.product() |> then(& &1 * 263)
#14935034899483.0
