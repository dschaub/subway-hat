require './arrival_time_finder'
require 'ws2812'

class DisplayManager
  attr_reader :display
  delegate :clear, to: :display

  def initialize(options = {})
    @display = Ws2812::UnicornHAT.new
    @display.rotation = options.delete(:rotation) || 180
    @display.brightness = options.delete(:brightness) || 10
  end

  def show_times(times, now)
    planner = TrainDisplayPlanner.new

    times.sort.each do |t|
      remaining = t - now
      next if remaining < 0
      planner.add_arrival_in((remaining / 60).round)
    end

    show_grid(planner.to_grid)
  end

  def show_grid(grid)
    display.clear(false)

    grid.each_with_index do |row, i|
      row.each_with_index do |color, j|
        display[i, j] = color
      end
    end

    display.show
  end

  class TrainDisplayPlanner
    ROWS = 8
    COLS = 8

    RED = Ws2812::Color.new(0xEE, 0x35, 0x2E)
    WHITE = Ws2812::Color.new(0xFF, 0xFF, 0xFF)
    OFF = Ws2812::Color.new(0, 0, 0)

    def initialize
      @x = 0
      @y = 0
      @train_pixels = []
    end

    def add_arrival_in(minutes)
      @train_pixels << WHITE
      minutes.times { @train_pixels << RED }
    end

    def to_grid
      0.upto(ROWS * COLS - 1).reduce([]) do |memo, i|
        color = @train_pixels[i]
        row = i % COLS
        col = i / COLS

        memo[row] = [] unless memo[row]
        memo[row][col] = color || OFF

        memo
      end
    end
  end
end

if __FILE__ == $0
  # TODO: make this a station ID so we can show uptown/downtown
  stop_id = ARGV[0]
  finder = ArrivalTimeFinder.new(stop_id)

  manager = DisplayManager.new

  begin
    loop do
      now = Time.now

      begin
        manager.show_times(finder.next_arrival_time(3), now)
      rescue Exception => e
        puts "Failed to fetch feed at #{now}"
        # TODO: show bad state on display
        manager.clear

        raise e
      end

      sleep 30
    end
  rescue Interrupt
    puts 'Exiting!'
  ensure
    manager.clear
  end
end

