defmodule Sudoku.Tile do
  @moduledoc """
  Represents a single square in a game of sudoku
  """

  use Agent
  require Logger

  def start_link(name) do
    Agent.start_link(fn -> %{possible: [1, 2, 3, 4], related: [], name: name, solved: false} end)
  end

  def get_possible(tile) do
    Agent.get(tile, &Map.get(&1, :possible))
  end

  def clear(tile, value) do
    Agent.update(tile, &clear_server(&1, value))
    Agent.cast(tile, &notify/1)
  end

  def set_value(tile, value) do
    Agent.update(tile, &set_value_server(&1, value))
    Agent.cast(tile, &notify/1)
  end

  def add_related(tile, rel_tile) when tile != rel_tile do
    Agent.update(tile, &add_related_server(&1, rel_tile))
  end

  def add_related(_, _) do
  end

  # Server functions

  defp set_value_server(%{name: name} = state, value) do
    IO.puts "Tile.set(#{name}) = #{value}"
    Map.update!(state, :possible, fn _ -> [value] end)
  end

  defp clear_server(%{possible: pos, name: name} = state, value) when length(pos) > 1 do
    IO.puts "Tile.clear(#{name}, #{value})"
    Map.update!(state, :possible, &(&1 -- [value]))
  end

  defp clear_server(state, _) do
    state
  end

  defp add_related_server(state, rel_tile) do
    Map.update!(state, :related, &([rel_tile | &1]))
  end

  defp notify(%{possible: [value], name: name, solved: false} = state) do
    IO.puts "#{name} is #{value}"
    Enum.each(state.related, &clear(&1, value))
    %{state | solved: true}
  end

  defp notify(state) do
    state
  end
end
