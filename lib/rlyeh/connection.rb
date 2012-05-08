require 'socket'
require 'rlyeh/environment'
require 'rlyeh/filters'
require 'rlyeh/sendable'

module Rlyeh
  class Connection < EventMachine::Connection
    include EventMachine::Protocols::LineText2
    include Rlyeh::Sendable

    attr_reader :server, :app_class, :options
    attr_reader :app, :host, :port, :session

    def initialize(server, app_class, options)
      @server = server
      @app_class = app_class
      @options = options
      set_delimiter "\r\n"
    end

    def post_init
      @app = app_class.new nil, @options
      @port, @host = Socket.unpack_sockaddr_in get_peername
    end

    def unbind
      @server.unbind self
    end

    def receive_line(data)
      env = Rlyeh::Environment.new
      env.version = Rlyeh::VERSION
      env.logger = @server.logger
      env.data = data
      env.server = @server
      env.connection = self
      env.settings = @app_class.settings

      catch :halt do
        @app.call env
      end
    end

    def attached(session)
      @session = session
    end

    def detached(session)
      @session = nil
    end

    def attached?
      !!@session
    end

    def send_data(data)
      if attached?
        @session.send_data data
      else
        super data
      end
    end

    include Rlyeh::Filters
    define_filters :attached, :detached
  end
end
