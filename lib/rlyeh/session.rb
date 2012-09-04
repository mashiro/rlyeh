require 'rlyeh/filters'

module Rlyeh
  class Session
    attr_reader :id, :channel, :connections

    def initialize(id)
      @id = id
      @channel = EventMachine::Channel.new
      @connections = {}
    end

    def attach(connection)
      connection.attach self

      @connections[connection] = @channel.subscribe do |msg|
        connection.send_data msg
      end
    end

    def detach(connection)
      id = @connections.delete connection
      @channel.unsubscribe id if id

      connection.detach self
    end

    def close
    end

    def send_data(data)
      @channel.push data
    end

    def empty?
      @connections.empty?
    end

    include Rlyeh::Filters
    define_filters :attach, :detach, :close, :send_data
  end
end
