require 'rlyeh/connection'
require 'rlyeh/utils'
require 'rlyeh/filters'
require 'logger'

module Rlyeh
  class Server
    attr_reader :options, :host, :port, :logger
    attr_reader :app_class, :signature, :sessions

    def initialize(*args)
      @options = Rlyeh::Utils.extract_options! args
      @host = @options.delete(:host) || "127.0.0.1"
      @port = @options.delete(:port) || 46667
      @logger = @options.delete(:logger) || ::Logger.new($stdout).tap do |logger|
        logger.formatter = proc { |severity, datetime, progname, msg| "[#{datetime}] #{severity.ljust(5)} #{msg}\n" }
      end
      @app_class = args.shift
      @signature = nil
      @sessions = {}

      @logger.info "Rlyeh #{Rlyeh::VERSION}"
      @logger.info "ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
    end

    def self.start(*args)
      new(*args).start
    end

    def start
      args = [self, @app_class, options]
      @signature = EventMachine.start_server @host, @port, Rlyeh::Connection, *args do |connection|
        bind connection
      end

      @logger.info "#{self.class.name} emerge on #{@host}:#{@port}"
      self
    end

    def stop
      EventMachine.stop_server @signature if @signature
      @signature = nil
    end

    def bind(connection)
      @logger.debug "Bind #{connection.host}:#{connection.port}"
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

      @logger.debug "Unbind #{connection.host}:#{connection.port}"
    end

    include Rlyeh::Filters
    define_filters :start, :stop, :bind, :unbind
  end
end
