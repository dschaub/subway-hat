require 'optparse'
require './driver/unicorn_hat'
require './driver/terminal'
require './layout/single_stop_snake'
require './layout/station_snake'

class Options
  def initialize(opts)
    @opts = opts
  end

  def parse!
    options = {}
    options[:driver] = Driver::UnicornHat
    options[:layout] = Layout::StationSnake
    options[:rotation] = 180
    options[:brightness] = 10

    parser = OptionParser.new do |config|
      config.banner = "Usage: clock.rb -s STOP_ID [-t]"

      config.on('-s', '--stop [STOP]', 'Stop ID') do |stop|
        options[:stop_id] = stop
      end

      config.on('-n', '--station [STATION]', 'Station ID, for showing both directions') do |station|
        options[:station_id] = station
      end

      config.on('-l', '--layout [LAYOUT]', [:stop_snake, :station_snake], 'Layout to use, may require either stop or station') do |layout|
        case layout
        when :stop_snake
          options[:layout] = Layout::SingleStopSnake
        when :station_snake
          options[:layout] = Layout::StationSnake
        else
        end
      end

      config.on('-t', '--test', 'Test mode') do |test|
        options[:driver] = Driver::Terminal
      end

      config.on('-r', '--rotation ROTATION', Integer, 'Grid rotation') do |rotation|
        options[:rotation] = rotation
      end

      config.on('-b', '--brightness BRIGHTNESS', Integer, 'Grid brightness') do |brightness|
        options[:brightness] = brightness
      end
    end

    parser.parse!(@opts)
    options
  end
end
