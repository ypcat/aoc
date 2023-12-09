#!/usr/bin/env elixir

mapping = '23456789TJQKA' |> Enum.with_index(2) |> Enum.into(%{})

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
  kind = hand |> Enum.frequencies() |> Map.values() |> Enum.sort(:desc)
  {kind, hand, bid}
end)
|> Enum.sort()
|> Enum.with_index(1)
|> Enum.map(fn {{_, _, bid}, rank} -> bid * rank end)
|> Enum.sum()
|> IO.inspect(charlists: :as_lists)

