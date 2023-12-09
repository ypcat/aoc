#!/usr/bin/env elixir
# map \r :w<cr>:term elixir %<cr>

_input = """
Time:      7  15   30
Distance:  9  40  200
"""

input = """
Time:        34     90     89     86
Distance:   204   1713   1210   1780
"""

# (7 - v) * v >= 9 and 0 < v < 7
# 7v - v^2 >= 9
# v^2 - 7v + 9 <= 0

input
|> String.split("\n", trim: true)
|> Enum.map(fn s -> s |> String.split() |> tl() |> Enum.join("") |> then(&[String.to_integer(&1)]) end)
|> IO.inspect()
|> Enum.zip()
|> Enum.map(fn {t, d} -> # x^2 - t*x + d = 0
  q = :math.sqrt(t * t - 4 * d)
  floor((t + q) / 2 - 0.000001) - ceil((t - q) / 2 + 0.000001) + 1
end)
|> IO.inspect()
|> Enum.product()
|> IO.inspect()

