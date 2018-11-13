defmodule Sudoku.BoardTest do
  use ExUnit.Case

  alias Sudoku.Board
  alias Sudoku.Tile

  setup do
    board = start_supervised!({Board, 4})
    %{board: board}
  end

  test "initial state", %{board: board} do
    {:ok, tile} = Board.get_tile(board, {2, 3})
    assert Tile.get_possible(tile) == [1, 2, 3, 4]

    {:error, _} = Board.get_tile(board, {5, 4})
    {:error, _} = Board.get_tile(board, {4, 5})
    {:error, _} = Board.get_tile(board, {0, 4})
    {:error, _} = Board.get_tile(board, {-4, 3})
  end

  test "init rows" do
    rows = Board.init_rows({1, 1}, 4)
    assert rows == [{1, 1}, {1, 2}, {2, 1}, {1, 3}, {3, 1}, {1, 4}, {4, 1}]
  end

  test "init boxes" do
    boxes = Sudoku.Board.init_boxes({2, 4}, 4)
    assert boxes == [{1, 3}, {1, 4}, {2, 3}, {2, 4}]
  end

  # _ 3 | _ _
  # _ 4 | 2 _
  # - - - - -
  #
  #
  test "simple game", %{board: board} do
    {:ok, tile1_1} = Board.get_tile(board, {1, 1})
    {:ok, tile1_2} = Board.get_tile(board, {1, 2})
    {:ok, tile2_1} = Board.get_tile(board, {2, 1})
    {:ok, tile2_2} = Board.get_tile(board, {2, 2})
    {:ok, tile2_3} = Board.get_tile(board, {2, 3})

    Board.set_value(board, {1, 2}, 3)
    wait(tile1_2) #wait for async stuff
    assert Tile.get_possible(tile1_1) == [1, 2, 4]
    assert Tile.get_possible(tile2_1) == [1, 2, 4]

    Board.set_value(board, {2, 2}, 4)
    wait(tile2_2) #wait for async stuff
    assert Tile.get_possible(tile1_1) == [1, 2]
    assert Tile.get_possible(tile2_1) == [1, 2]

    Board.set_value(board, {2, 3}, 2)
    wait(tile2_3) #wait for async stuff
    assert Tile.get_possible(tile2_1) == [1]
    assert Tile.get_possible(tile1_1) == [2]
  end

  def wait(tile) do
    :sys.get_state(tile)
  end
end
