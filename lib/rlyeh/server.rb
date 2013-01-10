require 'celluloid/io'
require 'rlyeh/connection'
require 'rlyeh/logger'
require 'rlyeh/callbacks'
require 'rlyeh/stores'

module Rlyeh
  class Server
    include Celluloid::IO
    task_class Celluloid::TaskThread unless RUBY_VERSION >= '2.0.0'

    include Rlyeh::Logger
    include Rlyeh::Callbacks

    attr_reader :options, :host, :port
    attr_reader :app_class, :sessions, :server

    def initialize(app_class, options = {})
      @app_class = app_class
      @options = options.dup
      @host = @options.delete(:host) { '127.0.0.1' }
      @port = @options.delete(:port) { 46667 }
      @sessions = {}
      @server = Celluloid::IO::TCPServer.new @host, @port

      info "Rlyeh has emerged on #{@host}:#{@port}"
      async.run
    end

    def finalize
      @server.close
      info 'Rlyeh has sunk...'
    end

    def run
      run_callbacks :run do
        loop do
          socket = @server.accept
          async.handle_connection socket
        end
      end
    end

    def handle_connection(socket)
      connection = Connection.new(self, socket)
      connection.run
    rescue Exception => e
      crash e
    ensure
      connection.close rescue nil
    end

    def load_session(session_id)
      @sessions[session_id] ||= Rlyeh::Session.new(session_id)
    end

    def close_session(session_id)
      session = @sessions.delete(session_id)
      session.close if session
    end

    def settings
      @app_class.settings
    end
  end
end

