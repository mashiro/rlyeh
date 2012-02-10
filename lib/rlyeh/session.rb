require 'rlyeh/filter'

module Rlyeh
  class Session
    include Rlyeh::Filter

    attr_accessor :channel, :connections

    def initialize
      @channel = EventMachine::Channel.new
      @subscribers = {}
    end

    def attach(conn)
      conn.attached self

      @subscribers[conn] = @channel.subscribe do |msg|
        conn.send_data msg
      end
    end

    def detach(conn)
      id = @subscribers.delete conn
      @channel.unsubscribe id if id

      conn.detached self
    end

    def close
    end

    def send_data(data)
      @channel.push data
    end

    def empty?
      @subscribes.empty?
    end

    define_filter :attach, :detach, :close, :send_data
  end
end
