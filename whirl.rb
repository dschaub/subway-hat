require 'protobuf'
require 'net/http'
require './nyct_subway'

class FeedFetcher
  include Singleton

  attr_accessor :cache_enabled
  alias_method :cache_enabled?, :cache_enabled

  CACHE_REFRESH_SECONDS = 30

  def initialize(cache_enabled = true)
    @cache_enabled = cache_enabled
    @cache = Cache.new
  end

  def fetch
    if cache_enabled?
      _fetch_with_cache
    else
      _fetch
    end
  end

  private

  def _fetch_with_cache
    if @cache.valid?
      @cache.response
    else
      @cache.store(_fetch, Time.now + CACHE_REFRESH_SECONDS)
    end
  end

  def _fetch
    Transit_realtime::FeedMessage.decode(Net::HTTP.get(api_uri))
  end

  def api_uri
    @api_uri ||= URI("http://datamine.mta.info/mta_esi.php?key=#{ENV['MTA_API_KEY']}&feed_id=1")
  end

  class Cache
    attr_accessor :response, :expires_at

    def store(response, expires_at)
      @response = response
      @expires_at = expires_at
      response
    end

    def valid?
      response && !expired?
    end

    def expired?
      !expires_at || Time.now > expires_at
    end
  end
end

class ArrivalTimeFinder
  def initialize(stop_id)
    @stop_id = stop_id
  end

  def next_arrival_time(n = 1)
    upcoming_stop_time_updates.first(n).map { |u| Time.at(u.arrival.time) }
  end

  private

  def upcoming_stop_time_updates
    stop_time_updates
      .select  { |u| u.stop_id == @stop_id }
      .sort_by { |u| u.arrival.time }
  end

  def feed
    FeedFetcher.instance.fetch
  end

  def trip_updates
    feed.entity.map { |e| e.trip_update }.compact
  end

  def stop_time_updates
    trip_updates.map(&:stop_time_update).flatten
  end
end

STOP_ID = ARGV[0]
finder = ArrivalTimeFinder.new(STOP_ID)

begin
  loop do
    now = Time.now

    puts "Upcoming trains at #{STOP_ID} (#{now}):"

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

