#!/usr/bin/env elixir

defmodule D0 do
  defmacro bind(value, var), do: quote(do: unquote(var) = unquote(value))
  def parse(input) do
    input
    |> String.split("\n", trim: true)
  end
  def part1(input) do
    input
  end
  def part2(input) do
    input
  end
end

input = """
"""

_ = """
"""

input
|> D0.parse()
|> D0.part1()
|> IO.inspect(label: :part1, charlists: :as_lists)

_ = """
"""

input
|> D0.parse()
|> D0.part2()
|> IO.inspect(label: :part2, charlists: :as_lists)

