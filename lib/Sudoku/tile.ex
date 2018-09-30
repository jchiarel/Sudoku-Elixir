defmodule Sudoku.Tile do
  use Agent
  require Logger

  def start_link(_) do
    Agent.start_link(fn -> %{possible: [1, 2, 3, 4], related: []} end)
  end

  def get_possible(tile) do
    Agent.get(tile, &Map.get(&1, :possible))
  end

  def clear(tile, value) do
    Agent.update(tile, &clear_server(&1, value))
  end

  def set_value(tile, value) do
    Agent.update(tile, &set_value_server(&1, value))
  end

  def add_related(tile, rel_tile) do
    Agent.update(tile, &add_related_server(&1, rel_tile))
  end

  # Server functions

  defp set_value_server(state, value) do
    Enum.each(state.related, &clear(&1, value))
    Map.update!(state, :possible, fn _ -> [value] end)
  end

  defp clear_server(state, value) do
    Map.update!(state, :possible, &(&1 -- [value]))
  end

  defp add_related_server(state, rel_tile) do
    Map.update!(state, :related, &([rel_tile | &1]))
  end
end
