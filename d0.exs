#!/usr/bin/env elixir

input = """
"""

input
|> String.split("\n", trim: true)
|> IO.inspect(label: :part1, charlists: :as_lists)

input
|> String.split("\n", trim: true)
|> IO.inspect(label: :part2, charlists: :as_lists)

