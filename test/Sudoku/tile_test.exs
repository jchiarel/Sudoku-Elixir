defmodule Sudoku.TileTest do
  use ExUnit.Case

  alias Sudoku.Tile

  setup do
    {:ok, tile} = Tile.start_link([])
    {:ok, related} = Tile.start_link([])
    %{tile: tile, related: related}
  end

  test "initial state", %{tile: tile} do
    assert Tile.get_possible(tile) == [1, 2, 3, 4]
  end

  test "clear", %{tile: tile} do
    assert Tile.get_possible(tile) == [1, 2, 3, 4]

    Tile.clear(tile, 2)
    assert Tile.get_possible(tile) == [1, 3, 4]

    Tile.clear(tile, 4)
    assert Tile.get_possible(tile) == [1, 3]
  end

  test "set_value", %{tile: tile} do
    assert Tile.get_possible(tile) == [1, 2, 3, 4]

    Tile.set_value(tile, 3)
    assert Tile.get_possible(tile) == [3]
  end

  test "related", %{tile: tile, related: related} do
    assert Tile.get_possible(related) == [1, 2, 3, 4]

    Tile.add_related(tile, related)
    Tile.set_value(tile, 2)

    wait(tile)
    assert Tile.get_possible(related) == [1, 3, 4]
  end

  def wait(tile) do
    :sys.get_state(tile)
  end
end

