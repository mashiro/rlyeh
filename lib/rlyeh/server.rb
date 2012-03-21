require 'rlyeh/connection'
require 'rlyeh/utils'
require 'rlyeh/filters'

module Rlyeh
  class Server
    attr_reader :options, :host, :port
    attr_reader :app_class, :signature, :sessions

    def initialize(*args)
      @options = Rlyeh::Utils.extract_options! args
      @host = @options.delete(:host) || "127.0.0.1"
      @port = @options.delete(:port) || 46667
      @app_class = args.shift
      @signature = nil
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
      self
    end

    def stop
      EventMachine.stop_server @signature if @signature
      @signature = nil
    end

    def bind(connection)
      puts 'bind'
    end

    def unbind(connection)
      if connection.attached?
        session = connection.session
        session.detach connection

        if session.empty?
          session.close
          @sessions.delete session.id
        end
      end

      puts 'unbind'
    end

    include Rlyeh::Filters
    define_filters :start, :stop, :bind, :unbind
  end
end
