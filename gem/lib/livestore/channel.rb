module ApplicationCable
  class Store
    attr_accessor :transmitter

    def initialize subject, channel, store_id = nil
      @channel = channel
      @subject = subject
      @store_id = store_id
    end

    def transmit data
      if @subject
        @channel.broadcast_to @subject, ({store_id: @store_id}).compact.merge(data)
      else
        @channel.transmit ({store_id: @store_id}).compact.merge(data)
      end
    end

    def set value
      transmit action: "set", value: value
    end

    def update changes
      transmit action: "update", changes: changes
    end

    def update_by_id_in key, id, changes
      transmit action: "update_by_id_in", key: key, id: id, changes: changes
    end

    def append_to key, value
      transmit action: "append_to", value: value, key: key
    end

    def append value
      transmit action: "append", value: value
    end
  end

  class ScopedChannel
    def initialize channel, subject
      @channel = channel
      @subject = subject
    end

    def store(store_id)
      Store.new(@subject, @channel, store_id)
    end

  end
  class Channel < ActionCable::Channel::Base
    public :transmit

    def self.[](subject)
      ScopedChannel.new(self, subject)
    end

    def store(store_id)
      Store.new(nil, self, store_id)
    end
  end
end
