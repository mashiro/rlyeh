require 'rlyeh/logger'
require 'rlyeh/sender'
require 'rlyeh/environment'

module Rlyeh
  class Connection
    include Rlyeh::Logger
    include Rlyeh::Sender

    attr_reader :server, :socket
    attr_reader :app, :host, :port, :session

    def initialize(server, socket)
      @server = server
      @socket = socket
      _, @port, @host = @socket.peeraddr
      @app = @server.app_class.new nil
    end

    def bind
      debug "Bind connection #{@host}:#{@port}"

      loop do
        tokenize @socket.readpartial(4096) do |data|
          invoke data
        end
      end
    end

    def unbind
      debug "Unbind connection #{@host}:#{@port}"
    end

    def tokenize(data)
      @buffer ||= ''
      @buffer << data
      while data = @buffer.slice!(/(.+)\n/, 1)
        yield data.chomp if block_given?
      end
    end

    def invoke(data)
      env = Rlyeh::Environment.new
      env.version = Rlyeh::VERSION
      env.data = data
      env.server = @server
      env.connection = self
      env.settings = @server.app_class.settings

      begin
        catch :halt do
          @app.call env
        end
      rescue Exception => e
        crash e
      end
    end

    def send_data(data, multicast = true)
      data = data.to_s
      if multicast && attached?
        @session.send_data data
      else
        @socket.write data
      end
    end

    def attach(session)
      @session = session
    end

    def detach(session)
      @session = nil
    end

    def attached?
      !!@session
    end
  end
end
