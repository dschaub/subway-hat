# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'


##
# Imports
#
require './gtfs_realtime'

module Transit_realtime

  ##
  # Message Classes
  #
  class TripReplacementPeriod < ::Protobuf::Message; end
  class NyctFeedHeader < ::Protobuf::Message; end
  class NyctTripDescriptor < ::Protobuf::Message
    class Direction < ::Protobuf::Enum
      define :NORTH, 1
      define :EAST, 2
      define :SOUTH, 3
      define :WEST, 4
    end

  end

  class NyctStopTimeUpdate < ::Protobuf::Message; end


  ##
  # Message Fields
  #
  class TripReplacementPeriod
    optional :string, :route_id, 1
    optional ::Transit_realtime::TimeRange, :replacement_period, 2
  end

  class NyctFeedHeader
    required :string, :nyct_subway_version, 1
    repeated ::Transit_realtime::TripReplacementPeriod, :trip_replacement_period, 2
  end

  class NyctTripDescriptor
    optional :string, :train_id, 1
    optional :bool, :is_assigned, 2
    optional ::Transit_realtime::NyctTripDescriptor::Direction, :direction, 3
  end

  class NyctStopTimeUpdate
    optional :string, :scheduled_track, 1
    optional :string, :actual_track, 2
  end


  ##
  # Extended Message Fields
  #
  class ::Transit_realtime::FeedHeader < ::Protobuf::Message
    optional ::Transit_realtime::NyctFeedHeader, :nyct_feed_header, 1001, :extension => true
  end

  class ::Transit_realtime::TripDescriptor < ::Protobuf::Message
    optional ::Transit_realtime::NyctTripDescriptor, :nyct_trip_descriptor, 1001, :extension => true
  end

  class ::Transit_realtime::TripUpdate::StopTimeUpdate < ::Protobuf::Message
    optional ::Transit_realtime::NyctStopTimeUpdate, :nyct_stop_time_update, 1001, :extension => true
  end

end

