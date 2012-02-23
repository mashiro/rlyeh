require 'ircp'
require 'rlyeh/environment'
require 'rlyeh/filters'

module Rlyeh
  class Connection < EventMachine::Connection
    include EventMachine::Protocols::LineText2

    attr_reader :server, :klass, :options
    attr_reader :app, :session

    def initialize(server, klass, options)
      @server = server
      @klass = klass
      @options = options
      set_delimiter "\r\n"
    end

    def post_init
      @app = klass.new nil, @options
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
