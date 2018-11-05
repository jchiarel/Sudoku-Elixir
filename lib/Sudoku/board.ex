defmodule Sudoku.Board do
  @moduledoc """
  A genserver for playing a game of sudoku.
  """
  use GenServer
  alias Sudoku.Tile

  def start_link(size) do
    GenServer.start_link(__MODULE__, [size: size])
  end

  def init([size: 4]) do
    {:ok, %{:size => 4,
        {1, 1} => Tile.start_link([])}}
  end

  def init(_) do
    {:error, "Invalid board config"}
  end

  def get_tile(server, loc) when is_tuple(loc) do
    GenServer.call(server, {:get_tile, loc})
  end

  def handle_call({:get_tile, {x, y} = loc}, _from, %{size: size} = state)
      when x <= size and y <= size and x > 0 and y > 0 do
    {:reply, Map.get(state, loc), state}
  end

  def handle_call({:get_tile, _}, _, state) do
    {:reply, {:error, "Invalid tile"}, state}
  end
end
