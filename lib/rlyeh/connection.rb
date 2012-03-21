require 'ircp'
require 'rlyeh/environment'
require 'rlyeh/filters'
require 'rlyeh/sendable'

module Rlyeh
  class Connection < EventMachine::Connection
    include EventMachine::Protocols::LineText2
    include Rlyeh::Sendable

    attr_reader :server, :app_class, :options
    attr_reader :app, :session

    def initialize(server, app_class, options)
      @server = server
      @app_class = app_class
      @options = options
      set_delimiter "\r\n"
    end

    def post_init
      @app = app_class.new nil, @options
    end

    def unbind
      @server.unbind self
    end

    def receive_line(data)
      env = Rlyeh::Environment.new
      env.data = data
      env.server = @server
      env.connection = self

      @app.call env
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

    include Rlyeh::Filters
    define_filters :attached, :detached
  end
end
