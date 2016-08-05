require './arrival_time_finder'
require './layout/single_stop_snake'

class DisplayManager
  attr_reader :driver
  delegate :rows, :cols, to: :driver

  ERROR = [0, 0, 0x66]

  def initialize(options)
    @options = options
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

  def driver
    unless @driver
      @driver = @options[:driver].new
      @driver.rotation = @options[:rotation]
      @driver.brightness = @options[:brightness]
    end

    @driver
  end

  def layout
    @layout ||= Layout::SingleStopSnake.new(@options.merge(rows: rows, cols: cols))
  end

  def _color(rgb)
    driver.get_color(*rgb)
  end
end

