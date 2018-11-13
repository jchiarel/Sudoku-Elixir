defmodule Sudoku.Board do
  @moduledoc """
  A genserver for playing a game of sudoku.
  """
  use GenServer
  alias Sudoku.Tile

  @typedoc """
  The row and column location of a tile
  """
  @type location :: {integer, integer}


  def start_link(size) do
    GenServer.start_link(__MODULE__, [size: size])
  end

  def init([size: 4]) do
    grid = init_grid(4)
    init_groups(grid, 4)

    {:ok, Map.put(grid, :size, 4)}
  end

  def init(_) do
    {:error, "Invalid board config"}
  end

  @spec init_grid(integer()) :: map()
  def init_grid(size) do
    for i <- 1..size, j <- 1..size, into: %{} do
      {:ok, tile} = Tile.start_link("Tile#{i}#{j}")
      {{i, j}, tile}
    end
  end

  @spec init_groups(map(), integer()) :: [any()]
  def init_groups(grid, size) do
    for i <- 1..size, j <- 1..size do
      init_groups(grid, {i, j}, size)
    end
  end

  @spec init_groups(map(), location, integer()) :: :ok
  def init_groups(grid, loc, size) do
    {:ok, tile} = Map.fetch(grid, loc)
    init_rows(loc, size) ++ init_boxes(loc, size)
    |> Enum.uniq
    |> Enum.map(fn key -> Map.get(grid, key) end)
    |> Enum.each(fn rel_tile -> Tile.add_related(tile, rel_tile) end)
  end

  @spec init_boxes(location, integer()) :: list(location)
  def init_boxes({i, j}, 4) do
    i_start = div(i - 1, 2) * 2 + 1
    j_start = div(j - 1, 2) * 2 + 1
    for x <- i_start..i_start + 1, y <- j_start..j_start + 1 do
      {x, y}
    end
  end

  @spec init_rows(location, integer()) :: list(location)
  def init_rows({i, j}, size) do
    for k <- 1..size do
      [{i, k}, {k, j}]
    end
    |> List.flatten
    |> Enum.uniq
  end

  @spec get_tile(pid(), location) :: pid()
  def get_tile(server, loc) when is_tuple(loc) do
    GenServer.call(server, {:get_tile, loc})
  end

  @spec set_value(pid, location, integer) :: any()
  def set_value(server, loc, value) do
    GenServer.call(server, {:set_value, loc, value})
  end

  # Server functions

  def handle_call({:get_tile, {x, y} = loc}, _from, %{size: size} = state)
      when x <= size and y <= size and x > 0 and y > 0 do
    {:reply, Map.fetch(state, loc), state}
  end

  def handle_call({:get_tile, _}, _, state) do
    {:reply, {:error, "Invalid tile"}, state}
  end

  def handle_call({:set_value, {x, y} = loc, value}, _, %{size: size} = state)
      when x <= size and y <= size and x > 0 and y > 0 do
    tile = Map.get(state, loc)
    Tile.set_value(tile, value)
    {:reply, {:ok}, state}
  end
end
