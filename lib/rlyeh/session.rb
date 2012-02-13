require 'rlyeh/filter'

module Rlyeh
  class Session
    attr_reader :channel, :connections

    def initialize
      @channel = EventMachine::Channel.new
      @connections = {}
    end

    def attach(connection)
      connection.attached self

      @connections[connection] = @channel.subscribe do |msg|
        connection.send_data msg
      end
    end

    def detach(connection)
      id = @connections.delete connection
      @channel.unsubscribe id if id

      connection.detached self
    end

    def close
    end

    def send_data(data)
      @channel.push data
    end

    def empty?
      @connections.empty?
    end

    include Rlyeh::Filter
    define_filter :attach, :detach, :close, :send_data
  end
end
