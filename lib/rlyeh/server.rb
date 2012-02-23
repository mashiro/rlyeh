require 'rlyeh/connection'
require 'rlyeh/utils'
require 'rlyeh/filters'

module Rlyeh
  class Server
    attr_reader :options, :host, :port
    attr_reader :klass, :signature, :connections

    def initialize(*args)
      @options = Rlyeh::Utils.extract_options! args
      @host = @options.delete(:host) || "127.0.0.1"
      @port = @options.delete(:port) || 46667
      @klass = args.shift
      @signature = nil
      @connections = []
    end

    def self.start(*args)
      new(*args).start
    end

    def start
      args = [self, @klass, options]
      @signature = EventMachine.start_server @host, @port, Rlyeh::Connection, *args do |connection|
        bind connection
      end
      self
    end

    def stop
      EventMachine.stop_server @signature if @signature
      @signature = nil
    end

    def bind(connection)
      puts 'bind'
      @connections.push connection
    end

    def unbind(connection)
      if connection.attached?
        session = connection.session
        session.detach connection

        if session.empty?
          session.close
          @sessions.delete session
        end
      end

      @connections.delete connection
      puts 'unbind'
    end

    include Rlyeh::Filters
    define_filters :start, :stop, :bind, :unbind
  end
end
