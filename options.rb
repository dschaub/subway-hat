require 'optparse'

class Options
  def initialize(opts)
    @opts = opts
  end

  def parse!
    options = {}

    parser = OptionParser.new do |config|
      config.banner = "Usage: clock.rb -s STOP_ID [-t]"

      # TODO: add station ID and show north/south
      config.on('-s', '--stop STOP', 'Stop ID') do |stop|
        options[:stop_id] = stop
      end

      config.on('-t', '--test', 'Test mode') do |test|
        options[:test] = test
      end
    end

    parser.parse!(@opts)
    options
  end
end
