require 'byebug'
require_relative 'board'
require 'singleton'

module SlidingPiece
  attr_reader :color, :moves

  def moves
    directions = []
    if move_dirs.include?(:diagonal)
      directions += diagonal_dirs
    end
    if move_dirs.include?(:horizontal_vertical)
      directions += horizontal_vertical_dirs
    end
    directions.select! { |pos| @board.in_bounds?([pos[0] + self.pos[0], pos[1] + self.pos[1]]) }
    directions.select! { |move| self.unblocked_move?(move[0], move[1]) }
    moves = directions.map { |pos| [pos[0] + self.pos[0], pos[1] + self.pos[1]] }
    moves.select { |move| @board[move].color != self.color }
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

  def unblocked_move?(dx, dy)
    if dx == 0
      check_vertical(dy)
    elsif dy == 0
      check_horizontal(dx)
    else
      check_diagonal(dx, dy)
    end
  end

  def check_diagonal(dx, dy)
    if dx > 0 && dy > 0
      (dy - 1).times do |i|
        next_pos = [self.pos.first + (i + 1), self.pos.last + (i + 1)]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    elsif dx < 0 && dy < 0
      (dy.abs - 1).times do |i|
        next_pos = [self.pos.first - (i + 1), self.pos.last - (i + 1)]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    elsif dx > 0 && dy < 0
      (dx - 1).times do |i|
        next_pos = [self.pos.first + (i + 1), self.pos.last - (i + 1)]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    elsif dx < 0 && dy > 0
      (dy - 1).times do |i|
        next_pos = [self.pos.first - (i + 1), self.pos.last + (i + 1)]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    end
    true
  end

  def check_vertical(dy)
    if dy < 0
      (dy.abs - 1).times do |i|
        next_pos = [self.pos.first, self.pos.last - (i + 1)]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    else
      (dy - 1).times do |i|
        next_pos = [self.pos.first, self.pos.last + (i + 1)]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    end
    true
  end

  def check_horizontal(dx)
    if dx < 0
      (dx.abs - 1).times do |i|
        next_pos = [self.pos.first - (i + 1), self.pos.last]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    else
      (dx - 1).times do |i|
        next_pos = [self.pos.first + (i + 1), self.pos.last]
        return false unless board[next_pos].is_a?(NullPiece)
      end
    end
    true
  end
end

module SteppingPiece
  attr_reader :color, :moves

  def moves
    if self.is_a?(Knight)
      directions = [[1, 2], [-1, 2], [-1, -2], [1, -2],
                    [2, 1], [2, -1], [-2, -1], [-2, 1]]
    elsif self.is_a?(King)
      directions = [[1, 0], [-1, 0], [-1, -1], [1, 1],
                    [-1, 1], [1, -1], [0, -1], [0, 1]]
    end
    directions.select! { |pos| @board.in_bounds?([pos[0] + self.pos[0], pos[1] + self.pos[1]]) }
    directions.select! { |move| self.unblocked_move?(move[0], move[1]) }
    directions.map { |pos| [pos[0] + self.pos[0], pos[1] + self.pos[1]] }
  end

  def unblocked_move?(dx, dy)
    return true unless @board[[self.pos[0] + dx, self.pos[1] + dy]].color == self.color
  end

end

class Piece
  attr_reader :moves, :pos, :board, :valid_moves, :symbol

  def initialize(pos, board, symbol)
    @pos = pos
    @board = board
    @symbol = symbol
  end

  def to_s
    @symbol
  end

  def dup(board)
    Piece.new(pos.dup, board, symbol)
  end

  def valid_moves
    moves = self.moves
    moves.reject { |move| move_into_check?(move) }
  end

  def move_into_check?(end_pos)
    start_pos = self.pos
    piece_at_end_pos = @board[end_pos]
    @board.move_piece!(self.pos, end_pos)
    in_check = @board.in_check?(self.color)
    @board.undo_move_piece(self, start_pos, piece_at_end_pos, end_pos)
    in_check
  end

end

class King < Piece
  include SteppingPiece

  def initialize(pos, board, color)
    @color = color
    @symbol = color == :black ? "\u265A" : "\u2654"
    super(pos, board, @symbol)
  end

end

class Knight < Piece
  include SteppingPiece

  def initialize(pos, board, color)
    @color = color
    @symbol = color == :black ? "\u265E" : "\u2658"
    super(pos, board, @symbol)
  end
end

class Pawn < Piece
  attr_reader :color, :moves, :valid_moves

  DIRECTIONS = {
    black: [[2, 0], [1, 0], [1, 1], [1, -1]],
    white: [[-2, 0], [-1, 0], [-1, 1], [-1, -1]]
  }

  def initialize(pos, board, color)
    @color = color
    @symbol = color == :black ? "\u265F" : "\u2659"
    super(pos, board, @symbol)
  end

  def moves
    @moves = DIRECTIONS[self.color].map { |move| [move[0] + self.pos[0], move[1] + self.pos[1]] }
    @moves.select! { |pos| @board.in_bounds?(pos) }
    @moves = self.color == :black ? valid_black_moves : valid_white_moves
  end

  def valid_moves
    moves = self.moves
    moves.reject { |move| move_into_check?(move) }
  end

  def valid_black_moves
    valid = []
    @moves.each do |move|
      if self.pos[0] == 1 && self.pos[1] == move[1] && (move[0] - self.pos[0]) == 2
        next unless @board[[2, self.pos[1]]].is_a?(NullPiece)
        valid << move if @board[move].is_a?(NullPiece)
      elsif self.pos[1] == move[1]
        valid << move if @board[move].is_a?(NullPiece)
      else
        valid << move if @board[move].color == :white
      end
    end
    valid
  end

  def valid_white_moves
    valid = []
    @moves.each do |move|
      if self.pos[0] == 6 && self.pos[1] == move[1] && (self.pos[0] - move[0]) == 2
        next unless @board[[5, self.pos[1]]].is_a?(NullPiece)
        valid << move if @board[move].is_a?(NullPiece)
      elsif self.pos[1] == move[1]
        valid << move if @board[move].is_a?(NullPiece)
      else
        valid << move if @board[move].color == :black
      end
    end
    valid
  end
end

class Bishop < Piece
  include SlidingPiece

  def initialize(pos, board, color)
    @color = color
    @symbol = color == :black ? "\u265D" : "\u2657"
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
    @symbol = color == :black ? "\u265C" : "\u2656"
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
    @symbol = color == :black ? "\u265B" : "\u2655"
    super(pos, board, @symbol)
  end

  def move_dirs
    [:diagonal, :horizontal_vertical]
  end
end

class NullPiece < Piece
  include Singleton
  attr_reader :color, :symbol, :moves

  def initialize
    @color = nil
    @symbol = " "
    @moves = []
  end
end
