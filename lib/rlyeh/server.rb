require 'celluloid/io'
require 'rlyeh/connection'
require 'rlyeh/sync_delegator'
require 'rlyeh/logger'

module Rlyeh
  class Server
    include Celluloid::IO
    include Rlyeh::Logger

    attr_reader :options, :host, :port
    attr_reader :app_class, :sessions, :server

    def initialize(app_class, options = {})
      @app_class = app_class
      @options = options.dup
      @host = @options.delete(:host) { '127.0.0.1' }
      @port = @options.delete(:port) { 46667 }
      @sessions = Rlyeh::SyncDelegator.new({})
      @server = Celluloid::IO::TCPServer.new @host, @port

      run!
    end

    def run
      info "Rlyeh has emerged on #{@host}:#{@port}"
      loop { handle_connection! @server.accept }
    end

    def finalize
      if @server
        @server.close
        @server = nil
        info 'Rlyeh has sunk...'
      end
    end

    private

    def handle_connection(socket)
      connection = Rlyeh::Connection.new self, socket
      connection.bind
    rescue EOFError
      close_connection connection
    end

    def close_connection(connection)
      connection.unbind

      if connection.attached?
        session = connection.session
        session.detach connection

        if session.empty?
          session.close
          @sessions.delete session.id
        end
      end
    end
  end
end
