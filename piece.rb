require_relative 'board'
require 'singleton'

module SlidingPiece

  def moves
    directions = []
    if move_dirs.include?(:diagonal)
      directions += diagonal_dirs
    end
    if move_dirs.include?(:horizontal_vertical)
      directions += horizontal_vertical_dirs
    end
    directions
  end

  def horizontal_vertical_dirs
    directions = []
    (1..7).each do |num|
      directions << [-num, 0]
      directions << [num, 0]
      directions << [0, num]
      directions << [0, -num]
    end
    directions
  end

  def diagonal_dirs
    directions = []
    (1..7).each do |num|
      directions << [-num, -num]
      directions << [num, num]
      directions << [num, -num]
      directions << [-num, num]
    end
    directions
  end

  def unblocked_moves(dx, dy)
    if dx == 0
      check_vertical(dy)
    elsif dy == 0
      check_horizontal(dx)
    else

    end
  end

  def check_diagonal(dx, dy)
    
  end

  def check_vertical(dy)
    if dy < 0
      dy.abs.times do |i|
        next_pos = [self.pos.first, self.pos.last - (i + 1)]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    else
      dy.times do |i|
        next_pos = [self.pos.first, self.pos.last + (i + 1)]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    end
    true
  end

  def check_horizontal(dx)
    if dx < 0
      dx.abs.times do |i|
        next_pos = [self.pos.first - (i + 1), self.pos.last]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    else
      dx.times do |i|
        next_pos = [self.pos.first + (i + 1), self.pos.last]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    end
    true
  end
end

module SteppingPiece
  def moves
    if self.is_a?(Knight)
      [[1, 2], [-1, 2], [-1, -2], [1, -2],
       [2, 1], [2, -1], [-2, -1], [-2, 1]]
    elsif self.is_a?(King)
      [[1, 0], [-1, 0], [-1, -1], [1, 1],
       [-1, 1], [1, -1], [0, -1], [0, 1]]
    end
  end
end

class Piece
  attr_reader :moves, :pos, :board

  def initialize(pos, board, symbol)
    @pos = pos
    @board = board
    @symbol = symbol
  end

  def moves
    @moves
  end

  def to_s
    @symbol
  end

  def valid_moves

  end

end

class King < Piece
  include SteppingPiece

  def initialize(pos, board, color)
    @color = color
    color == :black ? @symbol = "\u265A" : "\u2654"
    super(pos, board, @symbol)
  end

end

class Knight < Piece
  include SteppingPiece

  def initialize(pos, board, color)
    @color = color
    color == :black ? @symbol = "\u265E" : "\u2658"
    super(pos, board, @symbol)
  end
end

class Pawn < Piece
end

class Bishop < Piece
  include SlidingPiece

  def initialize(pos, board, color)
    @color = color
    color == :black ? @symbol = "\u265D" : "\u2657"
    super(pos, board, @symbol)
  end

  def move_dirs
    [:diagonal]
  end
end

class Rook < Piece
  include SlidingPiece

  def initialize(pos, board, color)
    @color = color
    color == :black ? @symbol = "\u265C" : "\u2656"
    super(pos, board, @symbol)
  end

  def move_dirs
    [:horizontal_vertical]
  end
end

class Queen < Piece
  include SlidingPiece

  def initialize(pos, board, color)
    @color = color
    color == :black ? @symbol = "\u265B" : "\u2655"
    super(pos, board, @symbol)
  end

  def move_dirs
    [:diagonal, :horizontal_vertical]
  end
end

class NullPiece < Piece
  include Singleton

  def initialize
    @color = nil
    @symbol = " "
  end
end
