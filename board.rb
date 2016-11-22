require_relative 'piece'
require 'byebug'

STARTING_POS = {
  [0, 0] => :rook,
  [0, 1] => :knight,
  [0, 2] => :bishop,
  [0, 3] => :king,
  [0, 4] => :queen,
  [0, 5] => :bishop,
  [0, 6] => :knight,
  [0, 7] => :rook,
  [7, 0] => :rook,
  [7, 1] => :knight,
  [7, 2] => :bishop,
  [7, 3] => :king,
  [7, 4] => :queen,
  [7, 5] => :bishop,
  [7, 6] => :knight,
  [7, 7] => :rook
}
class Board

  attr_reader :grid

  def initialize(grid = Array.new(8) { Array.new(8) } )
    @grid = grid
    place_default_piece
  end

  def place_default_piece
    @grid.each_with_index do |row, i|
      row.each_with_index do |_, j|
        case i
        when 0
          @grid[i][j] = place_royal_piece([i, j])
        when 7
          @grid[i][j] = place_royal_piece([i, j])
        when 1
          @grid[i][j] = Pawn.new([i, j], self, :black)
        when 6
          @grid[i][j] = Pawn.new([i, j], self, :white)
        else
          @grid[i][j] = NullPiece.instance
        end
      end
    end
  end

  def place_royal_piece(pos)
    pos[0] == color = 0 ? :black : :white
    case STARTING_POS[pos]
    when :rook
      return Rook.new(pos, self, color)
    when :knight
      return Knight.new(pos, self, color)
    when :bishop
      return Bishop.new(pos, self, color)
    when :king
      return King.new(pos, self, color)
    when :queen
      return Queen.new(pos, self, color)
    end
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
