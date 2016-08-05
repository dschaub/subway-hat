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

    parser = OptionParser.new do |config|
      config.banner = "Usage: clock.rb -s STOP_ID [-t]"

      # TODO: add station ID and show north/south
      config.on('-s', '--stop STOP', 'Stop ID') do |stop|
        options[:stop_id] = stop
      end

      config.on('-t', '--test', 'Test mode') do |test|
        options[:driver] = Driver::Terminal
      end
    end

    parser.parse!(@opts)
    options
  end
end
