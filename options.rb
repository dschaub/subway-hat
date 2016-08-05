require 'optparse'
require './driver/unicorn_hat'
require './driver/terminal'

class Options
  def initialize(opts)
    @opts = opts
  end

  def parse!
    options = {}
    options[:driver] = Driver::UnicornHat
    options[:rotation] = 180
    options[:brightness] = 10

    parser = OptionParser.new do |config|
      config.banner = "Usage: clock.rb -s STOP_ID [-t]"

      # TODO: add station ID and show north/south
      config.on('-s', '--stop STOP', 'Stop ID') do |stop|
        options[:stop_id] = stop
      end

      config.on('-t', '--test', 'Test mode') do |test|
        options[:driver] = Driver::Terminal
      end

      config.on('-r', '--rotation ROTATION', 'Grid rotation') do |rot|
        options[:rotation] = rot.to_i
      end

      config.on('-b', '--brightness BRIGHTNESS', 'Grid brightness') do |bri|
        options[:brightness] = bri.to_i
      end
    end

    parser.parse!(@opts)
    options
  end
end
