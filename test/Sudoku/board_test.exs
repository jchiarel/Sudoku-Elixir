defmodule Sudoku.BoardTest do
  use ExUnit.Case

  alias Sudoku.Board

  setup do
    board = start_supervised!({Board, 4})
    %{board: board}
  end

  test "initial state", %{board: board} do
    {:ok, tile} = Board.get_tile(board, {1, 1})
    possible = Sudoku.Tile.get_possible(tile)
    assert possible == [1, 2, 3, 4]

    {:error, _} = Board.get_tile(board, {5, 4})
    {:error, _} = Board.get_tile(board, {4, 5})
    {:error, _} = Board.get_tile(board, {0, 4})
    {:error, _} = Board.get_tile(board, {-4, 3})
  end
end
