defmodule Sudoku.Board do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{{1,1} => Sudoku.Tile.start_link([])}}
  end

  def get_tile(server, loc) when is_tuple(loc) do
    GenServer.call(server, {:get_tile, loc})
  end

  def handle_call({:get_tile, loc}, _from, state) do
    {:reply, Map.get(state, loc), state}
  end
end
