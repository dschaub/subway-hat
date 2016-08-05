class DisplayManager
  attr_reader :display
  delegate :clear, to: :display

  ROWS = 8
  COLS = 8

  RED = [0xEE, 0x35, 0x2E]
  ORANGE = [0xFF, 0x63, 0x19]
  WHITE = [0xFF, 0xFF, 0xFF]
  OFF = [0, 0, 0]
  ERROR = [0, 0, 0x66]

  def initialize(options = {})
    @test = options[:test].nil? ? false : options[:test]

    display.rotation = options.delete(:rotation) || 180
    display.brightness = options.delete(:brightness) || 10
  end

  def show_times(times, now)
    arranger = TrainArranger.new

    times.sort.each do |t|
      remaining = ((t - now) / 60).round
      next if remaining < 0
      arranger.add_arrival_in(remaining)
    end

    show_grid(arranger.to_grid)
  end

  def show_grid(grid)
    display.clear(false)

    grid.each_with_index do |row, y|
      row.each_with_index do |color, x|
        display[x, y] = _color(color)
      end
    end

    display.show
  end

  def show_error
    display.clear(false)
    display[0, 0] = _color(ERROR)
    display[0, ROWS - 1] = _color(ERROR)
    display[COLS - 1, 0] = _color(ERROR)
    display[COLS - 1, ROWS - 1] = _color(ERROR)
    display.show
  end

  private

  def display
    if @test
      require './terminal_display'
      @display ||= TerminalDisplay.new
    else
      require 'ws2812'
      @display ||= Ws2812::UnicornHAT.new
    end
  end

  def _color(rgb)
    if @test
      TerminalDisplay::Color.new(*rgb)
    else
      Ws2812::Color.new(*rgb)
    end
  end

  class TrainArranger
    def initialize
      @x = 0
      @y = 0
      @showing_minutes = 0
      @num_trains = 0
      @train_pixels = []
    end

    def add_arrival_in(minutes)
      relative_arrival = minutes - @showing_minutes
      relative_arrival.times { @train_pixels << @num_trains % 2 == 0 ? RED : ORANGE } if relative_arrival > 0
      @train_pixels << WHITE
      @showing_minutes += relative_arrival
      @num_trains += 1
    end

    def to_grid
      0.upto(ROWS * COLS - 1).reduce([]) do |memo, i|
        color = @train_pixels[i]
        col = i % COLS
        row = i / COLS
        col = COLS - 1 - col if row % 2 == 1

        memo[row] = [] unless memo[row]
        memo[row][col] = color || OFF

        memo
      end
    end
  end
end

