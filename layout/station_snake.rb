require './layout/base'

module Layout
  class StationSnake < Base
    RED = [0xEE, 0x35, 0x2E]
    YELLOW = [0xFC, 0xCC, 0x0A]
    BLUE = [0x28, 0x50, 0xAD]
    GREEN = [0x00, 0x93, 0x3C]
    WHITE = [0xFF, 0xFF, 0xFF]
    OFF = [0, 0, 0]

    def initialize(options)
      super
      raise 'Station layout requires a station_id' unless options[:station_id]
    end

    def to_grid
      reset!
      uptown_grid + downtown_grid
    end

    private

    def reset!
      @now = nil
      @train_pixels = {}
      @arrival_times = {}
    end

    def uptown_grid
      build_grid(uptown_stop_id, [RED, YELLOW])
    end

    def downtown_grid
      rotate180(build_grid(downtown_stop_id, [BLUE, GREEN]))
    end

    def build_grid(stop_id, colors)
      0.upto(max_pixels - 1).reduce([]) do |memo, i|
        color = train_pixels(stop_id, colors)[i]
        col = i % @cols
        row = i / @cols
        col = @cols - 1 - col if row % 2 == 1

        memo[row] = [] unless memo[row]
        memo[row][col] = color || OFF

        memo
      end
    end

    def train_pixels(stop_id, colors)
      unless @train_pixels[stop_id]
        @train_pixels[stop_id] = arrival_times(stop_id).each_with_index.reduce([]) do |pixels, (time, i)|
          minutes = ((time - now) / 60).round
          if pixels.length >= max_pixels || minutes < 0
            pixels
          else
            relative_arrival = minutes - (pixels.length - i)
            relative_arrival.times { pixels << colors[i % 2] } if relative_arrival > 0
            pixels << WHITE
          end
        end
      end

      @train_pixels[stop_id]
    end

    def arrival_times(stop_id)
      unless @arrival_times[stop_id]
        @arrival_times[stop_id] = ArrivalTimeFinder.new(stop_id).arrivals_within(max_pixels, now).sort
      end
    end

    def rotate180(grid)
      grid.reverse.map(&:reverse)
    end

    def uptown_stop_id
      "#{@options[:station_id]}N"
    end

    def downtown_stop_id
      "#{@options[:station_id]}S"
    end

    def now
      @now ||= Time.now
    end

    def max_pixels
      @rows * @cols / 2
    end
  end
end
