require 'ircp'
require 'rlyeh/environment'

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
      @app = klass.new
      #@app = @app_class.new self, options
    end

    def unbind
      @server.unbind self
    end

    def receive_line(data)
      env = Rlyeh::Environment.new
      env.connection = self
      env.raw = data

      begin
        env.message = Ircp.parse data
      rescue Ircp::ParseError => e
        p e
      else
        @app.call env
      end
    end

    def attached(session)
      @session = session
      #@app.attached session
    end

    def deatched(session)
      #@app.detached session
      @session = nil
    end

    def attached?
      !!@session
    end
  end
end
