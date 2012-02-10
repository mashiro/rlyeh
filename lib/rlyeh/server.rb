require 'rlyeh/connection'
require 'rlyeh/utils'
require 'rlyeh/filter'

module Rlyeh
  class Server
    include Rlyeh::Filter

    attr_reader :options, :host, :port
    attr_reader :app_class, :signature, :connections, :sessions

    def initialize(*args)
      @options = Rlyeh::Utils.extract_options! args
      @host = @options.delete(:host) || "127.0.0.1"
      @port = @options.delete(:port) || 46667
      @app_class = args.shift
      @signature = nil
      @connections = []
      @sessions = {}
    end

    def self.start(*args)
      new(*args).start
    end

    def start
      args = [self, @app_class, options]
      @signature = EventMachine.start_server @host, @port, Rlyeh::Connection, *args do |connection|
        bind connection
      end
    end

    def stop
      EventMachine.stop_server @signature if @signature
      @signature = nil
    end

    def bind(connection)
      @connections.push connection
      puts 'bind'
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

    define_filter :start, :stop, :bind, :unbind
  end
end
