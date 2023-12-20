#!/usr/bin/env elixir

defmodule D20 do
  def parse(input) do
    graph = input
    |> String.split("\n", trim: true)
    |> Enum.into(%{}, fn s ->
      [name | outputs] = String.split(s, ~r/[->, ]/, trim: true)
      type = name |> String.at(0)
      name = name |> String.replace(~r/[%&]/, "")
      {name, %{type: type, outputs: outputs, on: false, inputs: %{}}}
    end)
    Enum.reduce(graph, graph, fn {name, _node}, acc ->
      update_in(acc[name].inputs, &(for {k, v} <- graph, name in v.outputs, into: &1, do: {k, false}))
    end)
  end
  def fifo(queue) do
    queue
  end
  def push(queue, x) do
    [x | queue]
  end
  def pop(queue) do
    List.pop_at(queue, -1) # {x, queue}
  end
  def handle_module(_from, pulse, name, node) when node.type == "%" do
    case pulse do
      true -> {node, []}
      false -> {%{node | on: !node.on}, Enum.map(node.outputs, &{name, !node.on, &1})}
    end
  end
  def handle_module(from, pulse, name, node) when node.type == "&" do
    node = update_in(node.inputs[from], fn _ -> pulse end)
    pulse = node.inputs |> Map.values() |> Enum.all?() |> Kernel.!()
    {node, Enum.map(node.outputs, &{name, pulse, &1})}
    #|> tap(&if name != "qb" and !"qb" in node.outputs and !pulse, do: IO.inspect(&1))
  end
  def handle_module(_from, pulse, name, node) do
    {node, Enum.map(node.outputs, &{name, pulse, &1})}
  end
  def sim(graph, [], counts) do
    {graph, counts}
  end
  def sim(graph, queue, counts) do
    {{from, pulse, name}, queue} = pop(queue)
    node = graph[name] || %{type: "", outputs: [], on: false, inputs: %{}}
    {node, items} = handle_module(from, pulse, name, node)
    graph = Map.put(graph, name, node)
    queue = for item <- items, reduce: queue, do: (acc -> push(acc, item))
    sim(graph, queue, update_in(counts[pulse], & &1 + 1))
  end
  def part1(input) do
    for _ <- 1..1000, reduce: {input, %{false: 0, true: 0}} do
      {graph, counts} -> sim(graph, fifo([{"button", false, "broadcaster"}]), counts)
    end
    |> elem(1)
    |> IO.inspect()
    |> Map.values()
    |> Enum.product()
  end
  def sim2(graph, []) do
    graph
  end
  def sim2(graph, queue) do
    {{from, pulse, name}, queue} = pop(queue)
    case {pulse, name} do
      {false, "rx"} -> :ok
      _ ->
        node = graph[name] || %{type: "", outputs: [], on: false, inputs: %{}}
        {node, items} = handle_module(from, pulse, name, node)
        graph = Map.put(graph, name, node)
        queue = for item <- items, reduce: queue, do: (acc -> push(acc, item))
        sim2(graph, queue)
    end
  end
  def loop2(:ok, count), do: count
  def loop2(graph, 12345), do: graph.cycles
  def loop2(graph, count) do
    count = count + 1
    graph = sim2(graph, fifo([{"button", false, "broadcaster"}]))
    |> print(count)
    loop2(graph, count)
  end
  def part2(input) do
    loop2(input, 0)
    |> IO.inspect()
    |> Enum.map(fn cycle ->
      cycle
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [x, y] -> y - x end)
    end) # [[4003, ...], [4073, ...], [3739, ...], [3911, ...]]
    |> IO.inspect()
    |> Enum.map(&hd &1) # [4003, 4073, 3739, 3911] # gcd == 1
    |> Enum.product()
  end
  def print(graph, count) do
    #IO.puts(inspect(count) <> " qb: " <> inspect(graph["qb"].inputs))
    for name <- graph["broadcaster"].outputs do
      Enum.reduce_while(1..10000, [name], fn _, names ->
        node = graph[hd names]
        Enum.find(node.outputs, &graph[&1].type == "%")
        |> case do
          nil -> {:halt, names}
          name -> {:cont, [name | names]}
        end
      end)
      |> then(fn names ->
        cname = Enum.find(graph[name].outputs, &graph[&1].type == "&")
        #dname = Enum.find(graph[cname].outputs, &graph[&1].type == "&")
        v = & &1 == nil && "*" || &1 && "1" || "0"
        states = names |> Enum.map(&v.(graph[&1].on)) |> Enum.join()
        inputs = names |> Enum.map(&v.(graph[cname].inputs[&1])) |> Enum.join()
        #out = v.(graph[dname].inputs[cname])
        #{states <> " " <> cname, inputs <> "  " <> out}
        {states, inputs}
      end)
    end
    |> then(fn pairs ->
      {states, inputs} = Enum.unzip(pairs)
      #IO.puts(["on" | states] |> Enum.join(" "))
      #IO.puts(["in" | inputs] |> Enum.join(" "))
      #if ["" | inputs] |> Enum.join(" ") |> String.replace("*", "") =~ ~r/ ([01])\1{5}/ do
      if Enum.any?(states, &"000000000000" == &1) do
        IO.puts(count)
        IO.puts(states |> Enum.join(" "))
        IO.puts(inputs |> Enum.join(" "))
        cycles = graph[:cycles] || List.duplicate([], length(states))
        i = Enum.find_index(states, &"000000000000" == &1)
        cycles = cycles |> List.update_at(i, & &1 ++ [count])
        graph |> Map.put(:cycles, cycles)
      else
        graph
      end
    end)
  end
end

_sample1 = """
broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
"""

_sample2 = """
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
"""

input = """
&kv -> qb
%px -> qz, tk
%xk -> sv, zv
%rj -> lx, qz
%ks -> fc
%dx -> gt, dr
%lz -> qz, df
%dz -> fr
broadcaster -> cn, xk, rj, gf
%ct -> ks
%hq -> bz
%qv -> cx
&qz -> vk, qm, rj, kv, hq, tk
&jg -> qb
%cf -> sv, tz
&dr -> cn, jz, tq, ks, mr, ct
%mx -> bn
%bv -> sk, kf
%cn -> dr, mq
%vk -> lz
%jd -> qz
&qb -> rx
%tp -> sv, lm
%jz -> ct
%tq -> tj
%bn -> sv, cf
%br -> sk, hc
%gt -> dr, nd
%nd -> dr, nk
&rz -> qb
%lx -> qm, qz
&sk -> qv, kf, rd, qh, jg, gf
%mq -> jz, dr
%rl -> bv, sk
%tz -> sv, ng
%df -> qz, jd
%tk -> hq
&mr -> qb
%gf -> rl, sk
%qm -> nt
&sv -> xk, rz, zv, dz, mx
%hc -> sk, nf
%xp -> br, sk
%bc -> sv, tp
%fc -> dr, tq
%nf -> sk
%cx -> sk, qh
%bz -> vk, qz
%zv -> dz
%kf -> rd
%tj -> dr, dx
%fr -> mx, sv
%ng -> bc, sv
%lm -> sv
%nk -> dr
%nt -> qz, px
%qh -> xp
%rd -> qv
"""

input
|> D20.parse()
|> D20.part1()
|> IO.inspect(label: :part1, charlists: :as_lists)

_ = """
"""
input
|> D20.parse()
|> D20.part2()
|> IO.inspect(label: :part2, charlists: :as_lists)

