require './feed_fetcher'

class ArrivalTimeFinder
  def initialize(stop_id)
    @stop_id = stop_id
  end

  def next_arrival_time(n = 1)
    upcoming_stop_time_updates.first(n).map { |u| Time.at(u.arrival.time) }
  end

  def arrivals_within(minutes, now = nil)
    now ||= Time.now
    window_end = now + (minutes * 60)

    upcoming_stop_time_updates
      .map    { |u| Time.at(u.arrival.time) }
      .select { |t| t <= window_end }
  end

  private

  def upcoming_stop_time_updates
    stop_time_updates
      .select  { |u| u.stop_id == @stop_id }
      .sort_by { |u| u.arrival.time }
  end

  def stop_time_updates
    trip_updates.map(&:stop_time_update).flatten
  end

  def trip_updates
    feed.entity.map { |e| e.trip_update }.compact
  end

  def feed
    FeedFetcher.instance.fetch
  end
end
