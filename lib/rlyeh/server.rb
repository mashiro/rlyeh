require 'rlyeh/connection'
require 'rlyeh/utils'
require 'rlyeh/filters'
require 'rlyeh/loggable'
require 'logger'

module Rlyeh
  class Server
    include Rlyeh::Loggable
    attr_reader :options, :host, :port, :logger
    attr_reader :app_class, :signature, :sessions

    def initialize(*args)
      @options = Rlyeh::Utils.extract_options! args
      @host = @options.delete(:host) || "127.0.0.1"
      @port = @options.delete(:port) || 46667
      @logger = @options.delete(:logger) || ::Logger.new($stdout).tap do |logger|
        logger.formatter = method(:log_formatter)
      end
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

      info(@logger) { "Rlyeh has emerged on #{@host}:#{@port}" }
      self
    end

    def stop
      EventMachine.stop_server @signature if @signature
      @signature = nil

      info(@logger) { "Rlyeh has sunk..." }
    end

    def bind(connection)
      debug(@logger) { "Bind connection #{connection.host}:#{connection.port}" }
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

      debug(@logger) { "Unbind connection #{connection.host}:#{connection.port}" }
    end

    def log_formatter(severity, datetime, progname, message)
      s = "#{severity[0].upcase} [#{datetime}]"
      s << " <#{progname}>" if progname
      s << " #{message}"
      s << "\n"
      s
    end

    include Rlyeh::Filters
    define_filters :start, :stop, :bind, :unbind
  end
end
