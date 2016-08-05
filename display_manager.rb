require './arrival_time_finder'
require './layout/snake'

class DisplayManager
  attr_reader :driver
  delegate :rows, :cols, to: :driver

  ERROR = [0, 0, 0x66]

  def initialize(options = {})
    @driver = options[:driver].new
    @stop_id = options[:stop_id]

    @driver.rotation = options[:rotation] || 180
    @driver.brightness = options[:brightness] || 10
  end

  def run!
    loop do
      begin
        show_grid(layout.to_grid)
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

  def layout
    Layout::Snake.new(ArrivalTimeFinder.new(@stop_id), rows, cols)
  end

  def _color(rgb)
    driver.get_color(*rgb)
  end
end

