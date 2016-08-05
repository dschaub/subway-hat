module Layout
  class SingleStopSnake
    RED = [0xEE, 0x35, 0x2E]
    YELLOW = [0xFC, 0xCC, 0x0A]
    WHITE = [0xFF, 0xFF, 0xFF]
    OFF = [0, 0, 0]

    def initialize(options)
      @rows = options.delete(:rows)
      @cols = options.delete(:cols)
      @options = options
    end

    def to_grid
      reset!

      0.upto(@rows * @cols - 1).reduce([]) do |memo, i|
        color = train_pixels[i]
        col = i % @cols
        row = i / @cols
        col = @cols - 1 - col if row % 2 == 1

        memo[row] = [] unless memo[row]
        memo[row][col] = color || OFF

        memo
      end
    end

    private

    def reset!
      @now = nil
      @train_pixels = nil
      @arrival_times = nil
    end

    def train_pixels
      @train_pixels ||= arrival_times.each_with_index.reduce([]) do |pixels, (time, i)|
        minutes = ((time - now) / 60).round
        if minutes < 0
          pixels
        else
          relative_arrival = minutes - (pixels.length - i)
          relative_arrival.times { pixels << (i % 2 == 0 ? RED : YELLOW) } if relative_arrival > 0
          pixels << WHITE
        end
      end
    end

    def arrival_times
      @arrival_times ||= ArrivalTimeFinder.new(@options[:stop_id]).arrivals_within(30, now).sort
    end

    def now
      @now ||= Time.now
    end
  end
end
