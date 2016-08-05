require './arrival_time_finder'

class DisplayManager
  attr_reader :driver
  delegate :rows, :cols, to: :driver

  RED = [0xEE, 0x35, 0x2E]
  YELLOW = [0xFC, 0xCC, 0x0A]
  WHITE = [0xFF, 0xFF, 0xFF]
  OFF = [0, 0, 0]
  ERROR = [0, 0, 0x66]

  def initialize(options = {})
    @driver = options[:driver].new
    @stop_id = options[:stop_id]

    @driver.rotation = options[:rotation] || 180
    @driver.brightness = options[:brightness] || 10
  end

  def run!
    loop do
      now = Time.now

      begin
        show_times(finder.arrivals_within(30, now), now)
      rescue FetchException
        show_error
      end

      sleep 30
    end
  rescue Interrupt
    puts 'Exiting!'
  ensure
    driver.clear
  end

  def show_times(times, now)
    arranger = TrainArranger.new(rows, cols)

    times.sort.each do |t|
      remaining = ((t - now) / 60).round
      next if remaining < 0
      arranger.add_arrival_in(remaining)
    end

    show_grid(arranger.to_grid)
  end

  def show_grid(grid)
    driver.clear(false)

    grid.each_with_index do |row, y|
      row.each_with_index do |color, x|
        driver[x, y] = _color(color)
      end
    end

    driver.show
  end

  def show_error
    driver.clear(false)
    driver[0, 0] = _color(ERROR)
    driver[0, rows - 1] = _color(ERROR)
    driver[cols - 1, 0] = _color(ERROR)
    driver[cols - 1, rows - 1] = _color(ERROR)
    driver.show
  end

  private

  def _color(rgb)
    driver.get_color(*rgb)
  end

  def finder
    @finder ||= ArrivalTimeFinder.new(@stop_id)
  end

  class TrainArranger
    def initialize(rows, cols)
      @rows = rows
      @cols = cols

      @x = 0
      @y = 0

      @showing_minutes = 0
      @num_trains = 0
      @train_pixels = []
    end

    def add_arrival_in(minutes)
      relative_arrival = minutes - @showing_minutes
      relative_arrival.times { @train_pixels << (@num_trains % 2 == 0 ? RED : YELLOW) } if relative_arrival > 0
      @train_pixels << WHITE
      @showing_minutes += relative_arrival
      @num_trains += 1
    end

    def to_grid
      0.upto(@rows * @cols - 1).reduce([]) do |memo, i|
        color = @train_pixels[i]
        col = i % @cols
        row = i / @cols
        col = @cols - 1 - col if row % 2 == 1

        memo[row] = [] unless memo[row]
        memo[row][col] = color || OFF

        memo
      end
    end
  end
end

