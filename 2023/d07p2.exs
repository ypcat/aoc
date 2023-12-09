#!/usr/bin/env elixir

mapping = 'J23456789TQKA' |> Enum.with_index(1) |> Enum.into(%{})

_ =
"""
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
"""
#File.read!("d07p1.txt")
|> String.split("\n", trim: true)
|> Enum.map(fn s ->
  [cards, bid] = String.split(s)
  bid = String.to_integer(bid)
  hand = Enum.map(cards |> String.to_charlist(), &mapping[&1])
  {jokers, others} = Enum.split_with(hand, & &1 == 1)
  kind = others |> Enum.frequencies() |> Map.values() |> Enum.sort(:desc)
  kind = case kind do
    [] -> [length(jokers)]
    [h | t] -> [h + length(jokers) | t]
  end
  {kind, hand, cards, bid}
end)
|> Enum.sort()
|> Enum.with_index(1)
|> IO.inspect(charlists: :as_lists)
|> Enum.map(fn {{_, _, _, bid}, rank} -> bid * rank end)
|> Enum.sum()
|> IO.inspect(charlists: :as_lists)

