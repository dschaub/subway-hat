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
    raise 'No API key found' unless ENV['MTA_API_KEY']
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
