class Piece
  def to_s
    return "p"
  end
end

class King < Piece
end

class Knight < Piece
end

class Pawn < Piece
end

class Bishop < Piece
end

class Rook < Piece
end

class Queen < Piece
end

class NullPiece < Piece
  # include Singleton
end
