require_relative 'cursor'
require_relative 'display'

class HumanPlayer
  attr_reader :color, :name

  def initialize(name, color, display)
    @name = name
    @display = display
    @color = color
  end

  def play_turn
    start_pos = get_start_pos
    system "clear"
    @display.render
    puts "Please place your piece"

    end_pos = @display.cursor.get_input
    while end_pos.nil?
      system "clear"
      @display.render
      end_pos = @display.cursor.get_input
    end
    [start_pos, end_pos]
  end

  def get_start_pos
    system "clear"
    @display.render
    puts "#{@name}, please pick a piece to move"
    start_pos = @display.cursor.get_input
    while start_pos.nil?
      system "clear"
      @display.render
      start_pos = @display.cursor.get_input
    end
    check_color(start_pos)
  rescue ArgumentError => e
    puts e.message
    sleep(1.5)
    retry
  else
    start_pos
  end

  def check_color(pos)
    unless @display.board[pos].color == self.color
      raise ArgumentError.new("Please move your own piece!")
    end
  end
end
