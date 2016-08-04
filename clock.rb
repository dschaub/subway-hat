require './arrival_time_finder'
require './display_manager'
require './options'

if __FILE__ == $0
  options = Options.new(ARGV).parse!

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

