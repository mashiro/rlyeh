require 'celluloid'
require 'forwardable'
require 'rlyeh/logger'
require 'rlyeh/sender'
require 'rlyeh/worker'
require 'rlyeh/callbacks'
require 'rlyeh/environment'

module Rlyeh
  class QuitConnection < RuntimeError; end

  class Connection
    include Rlyeh::Logger
    include Rlyeh::Sender
    include Rlyeh::Worker
    include Rlyeh::Callbacks
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
      run_callbacks :close do
        @socket.close unless @socket.closed?

        if attached?
          detached_session = @session.detach self
          @server.close_session detached_session.id if detached_session.empty?
        end

        debug "Connection closed: #{@host}:#{@port}"
      end
    end

    def run
      run_callbacks :run do
        read_each do |data|
          break unless invoke do
            process data
          end
        end
      end
    end

    def read_each(&block)
      loop do
        @buffer ||= ''.force_encoding('ASCII-8BIT')
        @buffer << @socket.readpartial(BUFFER_SIZE).force_encoding('ASCII-8BIT')

        while data = @buffer.slice!(/(.+)\n/, 1)
          block.call data.chomp if block
        end
      end
    rescue EOFError
      # client disconnected
    rescue Celluloid::Task::TerminatedError
      # kill a running task
    end

    def process(data)
      run_callbacks :process, data do
        env = Rlyeh::Environment.new
        env.version = Rlyeh::VERSION
        env.data = data
        env.settings = @server.app_class.settings
        env.server = @server
        env.connection = self
        env.session = @session

        catch :halt do
          begin
            @app.call env
            true
          rescue Rlyeh::QuitConnection
            false
          rescue Exception => e
            crash e
            true
          end
        end
      end
    end

    def send_data(data, multicast = true)
      run_callbacks :send_data, data, multicast do
        data = data.to_s
        if multicast && attached?
          @session.send_data data
        else
          @socket.write data
        end
      end
    end

    def attach(session)
      run_callbacks :attach, session do
        @session = session
      end
    end

    def detach(session)
      run_callbacks :detach, session do
        @session = nil
      end
    end

    def attached?
      !!@session
    end
  end
end

