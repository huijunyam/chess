require_relative 'board'
require_relative 'cursor'
require_relative 'display'
require_relative 'piece'
require_relative 'player'

class Game
  attr_reader :current_player

  def initialize(player1, player2)
    @board = Board.new
    @display = Display.new(@board)
    @player1 = HumanPlayer.new(player1, :black, @display)
    @player2 = HumanPlayer.new(player2, :white, @display)
  end

  def play
    @current_player = @player1
    until checkmate?
      begin
        start_pos, end_pos = @current_player.play_turn
        @board.move_piece(start_pos, end_pos)
      rescue ArgumentError => e
        puts e.message
        sleep(1.5)
        retry
      end
      switch_players!
      puts "Check!" if @board.in_check?(@current_player.color)
    end
    puts "CHECKMATE"
  end

  def switch_players!
    if @current_player == @player1
      @current_player = @player2
    else
      @current_player = @player1
    end
    system "clear"
  end

  def checkmate?
    @board.checkmate?(:black) || @board.checkmate?(:white)
  end

end

if __FILE__ == $PROGRAM_NAME
  chess = Game.new("Hope", "Hui")
  chess.play
end
