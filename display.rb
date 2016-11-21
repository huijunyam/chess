require 'colorize'
require_relative 'cursor'
require_relative 'board'

class Display

  attr_reader :board, :cursor

  def initialize(board)
    @board = board
    @cursor = Cursor.new([0, 0], board)
  end

  def render
    puts "\n---------------------------------"
    @board.grid.each_with_index do |row, i|
      i.even? ? render_even_row(row, i) : render_odd_row(row, i)
      puts "\n---------------------------------"
    end
    nil
  end

  def render_even_row(row, idx)
    print "| "
    row.each_with_index do |el, i|
      if @cursor.cursor_pos == [idx, i]
        print el.to_s.colorize(:color => :white, :background => :blue)
      else
        if i.even?
          print el.to_s.colorize(:color => :black, :background => :white)
        else
          print el.to_s.colorize(:color => :white, :background => :black)
        end
      end
      print " | "
    end
  end

  def render_odd_row(row, idx)
    print "| "
    row.each_with_index do |el, i|
      if @cursor.cursor_pos == [idx, i]
        print el.to_s.colorize(:color => :white, :background => :blue)
      else
        if i.odd?
          print el.to_s.colorize(:color => :black, :background => :white)
        else
          print el.to_s.colorize(:color => :white, :background => :black)
        end
      end
      print " | "
    end
  end

  def display
    while true
      render
      @cursor.get_input
      system "clear"
    end
  end
end
