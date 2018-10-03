defmodule Sudoku.BoardTest do
  use ExUnit.Case

  alias Sudoku.Board

  setup do
    board = start_supervised!(Sudoku.Board)
    %{board: board}
  end

  test "initial state", %{board: board} do
    {:ok, tile} = Board.get_tile(board, {1, 1})
    possible = Sudoku.Tile.get_possible(tile)
    assert possible == [1, 2, 3, 4]
  end
end
