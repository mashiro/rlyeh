require 'celluloid'
require 'set'
require 'forwardable'
require 'rlyeh/logger'

module Rlyeh
  class Session
    include Celluloid
    include Rlyeh::Logger
    extend Forwardable

    attr_reader :id, :connections
    def_delegators :@connections, :include?, :empty?

    def initialize(id)
      @id = id
      @connections = Set.new
      debug "Session started: #{@id}"
    end

    def close
      debug "Session closed: #{@id}"
    end

    def attach(connection)
      connection.attach self
      @connections.add connection
    end

    def detach(connection)
      @connections.delete connection
      connection.detach self
    end

    def send_data(data)
      @connections.each do |connection|
        connection.send_data data, false
      end
    end
  end
end
