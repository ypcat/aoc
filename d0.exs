#!/usr/bin/env elixir

input = """
"""

defmodule D0 do
  def parse(input) do
    input |> String.split("\n", trim: true)
  end
  def part1(input) do
    input
  end
  def part2(input) do
    input
  end
end

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

