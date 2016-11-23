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
    color = pos[0] == 0 ? :black : :white
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
    if self[start_pos].is_a?(NullPiece)
      raise ArgumentError.new("No piece at start position")
    end
    unless self[start_pos].valid_moves.include?(end_pos)
      raise ArgumentError.new("Piece cannot move there")
    end
    self[end_pos] = self[start_pos]
    self[start_pos] = NullPiece.instance
  end

  def move_piece!(start_pos, end_pos)
    self[end_pos] = self[start_pos]
    self[start_pos] = NullPiece.instance
  end

  def undo_move_piece(start_piece, start_pos, end_piece, end_pos)
    self[start_pos] = start_piece
    self[end_pos] = end_piece
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

  def in_check?(color)
    pos = find_king(color)
    @grid.each do |row|
      if row.any? { |piece| piece.color != color && piece.moves.include?(pos) }
        return true
      end
    end
    false
  end

  def find_king(color)
    @grid.each_with_index do |row, i|
      row.each_with_index do |el, j|
        # byebug
        if el.is_a?(King) && el.color == color
          return [i, j]
        end
      end
    end
    nil
  end

  def checkmate?(color)
    in_check?(color) &&
    @grid.flatten.select { |piece| piece.color == color }.all? do |piece|
      piece.valid_moves.empty?
    end
  end

  def dup
    dupped = []
    @grid.each do |row|
      dup_row = []
      row.each do |el|
        dup_row << el
      end
      dupped << dup_row
    end
    dupped.each do |row|
      row.map! {|piece| piece.dup(dupped)}
    end
    dupped
  end
end
