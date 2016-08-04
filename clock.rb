require './arrival_time_finder'

stop_id = ARGV[0]
finder = ArrivalTimeFinder.new(stop_id)

begin
  loop do
    now = Time.now

    puts "Upcoming trains at #{stop_id} (#{now}):"

    begin
      finder.next_arrival_time(3).each do |t|
        seconds = t - now
        minutes = (seconds / 60).round
        puts "#{minutes} minutes"
      end
    rescue
      puts "Failed to fetch feed"
    end

    sleep 30
  end
rescue Interrupt
  puts 'Exiting!'
end

