require 'celluloid'
require 'set'
require 'forwardable'
require 'rlyeh/logger'
require 'rlyeh/utils'

module Rlyeh
  class Session
    include Celluloid
    include Rlyeh::Logger
    extend Forwardable

    attr_reader :id, :connections, :attributes
    def_delegators :@connections, :include?, :empty?
    def_delegators :@attributes, :[], :[]=

    def initialize(id)
      @id = id
      @connections = Set.new
      @attributes = {}
      debug "Session started: #{@id}"
    end

    def close
      debug "Session closed: #{@id}"
    end

    def attach(connection)
      connection.attach self
      @connections.add connection
      self
    end

    def detach(connection)
      @connections.delete connection
      connection.detach self
      self
    end

    def send_data(data)
      @connections.each do |connection|
        connection.send_data data, false
      end
    end

    def inspect
      Rlyeh::Utils.inspect self, :@id
    end
  end
end
