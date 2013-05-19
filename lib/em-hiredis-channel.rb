require 'securerandom'
require 'eventmachine'
require 'em-hiredis'
module EventMachine
  class HiRedisChannel < Channel
    attr_reader :name, :redis, :pubsub
    def initialize(name=SecureRandom.uuid, redis=$redis)
      @name = name
      super
      @redis = redis
      @pubsub = redis.pubsub
    end

    def push(*items)
      items.each do |item|
        redis.publish(name, Marshal.dump(item))
      end
    end

    def subscribe(*a, &b)
      name = b.hash
      @subs[name] = Proc.new do |msg|
        begin
          obj = Marshal.load(msg) 
        rescue
          obj = msg
        end
        b.call(msg)
      end
      pubsub.subscribe @name, @subs[name]
      name
    end

    def unsubscrible(name)
      pubsub.unsubscribe_proc @subs.delete(name)
    end
  end
end 