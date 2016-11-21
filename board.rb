require_relative 'piece'
require 'byebug'

class Board
  attr_reader :grid

  def initialize(grid = Board.default_board)
    @grid = grid
  end

  def self.default_board
    board = Array.new(8) { Array.new(8) }
    board[0..1].each_with_index do |row, i|
      row.each_with_index do |_, j|
        board[i][j] = Piece.new
      end
    end
    board[6..7].each_with_index do |row, i|
      row.each_with_index do |_, j|
        board[i + 6][j] = Piece.new
      end
    end
    board
    # Board.new(board)
  end

  def move_piece(start_pos, end_pos)
    # raise ArgumentError.new("No piece at start position") if self[start_pos].is_a?(NullPiece)
    # raise ArgumentError.new("Piece cannot move there") unless self[start_pos].valid_move?(end_pos)
    self[end_pos] = self[start_pos]
    self[start_pos] = NullPiece.new
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @grid[row][col] = value
  end

  def in_bounds?(pos)
    pos.all? { |el| el.between?(0, 7) }
  end

end
