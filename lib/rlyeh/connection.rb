require 'celluloid'
require 'forwardable'
require 'rlyeh/logger'
require 'rlyeh/sender'
require 'rlyeh/worker'
require 'rlyeh/environment'

module Rlyeh
  class Connection
    include Rlyeh::Logger
    include Rlyeh::Sender
    include Rlyeh::Worker
    extend Forwardable

    attr_reader :server, :socket
    attr_reader :app, :host, :port, :session

    def_delegators :@socket, :close, :closed?

    BUFFER_SIZE = 4096

    def initialize(server, socket)
      @server = server
      @socket = socket
      _, @port, @host = @socket.peeraddr
      @app = @server.app_class.new nil

      debug "Connection started: #{@host}:#{@port}"
    end

    def close
      @socket.close unless @socket.closed?

      if attached?
        @session.detach self

        if @session.empty?
          @session.close
          @server.sessions.delete @session.id
        end
      end

      debug "Connection closed: #{@host}:#{@port}"
    end

    def run
      catch :quit do
        read_each do |data|
          invoke do
            process data
          end
        end
      end
    end

    def read_each(&block)
      loop do
        @buffer ||= ''
        @buffer << @socket.readpartial(BUFFER_SIZE)

        while data = @buffer.slice!(/(.+)\n/, 1)
          block.call data.chomp if block
        end
      end
    rescue EOFError => e
      # client disconnected
    rescue Celluloid::Task::TerminatedError
      # kill a running task
    end

    def process(data)
      env = Rlyeh::Environment.new
      env.version = Rlyeh::VERSION
      env.data = data
      env.server = @server
      env.connection = self
      env.settings = @server.app_class.settings

      catch :halt do
        begin
          @app.call env
        rescue Exception => e
          crash e
        end
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

