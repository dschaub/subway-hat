require './arrival_time_finder'
require './display_manager'

require 'optparse'

options = {}
OptionParser.new do |config|
  config.banner = "Usage: clock.rb -s STOP_ID [-t]"

  # TODO: add station ID and show north/south
  config.on('-s', '--stop STOP', 'Stop ID') do |stop|
    options[:stop_id] = stop
  end

  config.on('-t', '--test', 'Test mode') do |test|
    options[:test] = test
  end
end.parse!

if __FILE__ == $0
  finder = ArrivalTimeFinder.new(options[:stop_id])
  manager = DisplayManager.new(test: options[:test])

  begin
    loop do
      now = Time.now

      begin
        manager.show_times(finder.arrivals_within(30, now), now)
      rescue FetchException
        manager.show_error
      end

      sleep 30
    end
  rescue Interrupt
    puts 'Exiting!'
  ensure
    manager.clear
  end
end

