require 'socket'
require 'rlyeh/dispatcher'

module Rlyeh
  module DeepOnes
    class Auth
      include Rlyeh::Dispatcher

      attr_reader :nick, :pass, :user, :real, :host

      def initialize(app, &authenticator)
        @app = app
        @authenticator = authenticator
        @authorized = false
      end

      def call(env)
        dispatch env

        if authorized?
          env.auth = self
          @app.call env
        end
      end

      def load_session(env, id)
        env.server.sessions[id] ||= Rlyeh::Session.new(id)
      end

      def authorized?
        @authorized
      end

      def authorized(env)
        settings = env.connection.app_class.settings
        env.connection.tap do |conn|
          conn.send_numeric_reply :welcome, @host, "Welcome to the Internet Relay Network #{@nick}!#{@user}@#{@host}"
          conn.send_numeric_reply :yourhost, @host, "Your host is #{settings.server_name}, running version #{settings.server_version}"
          conn.send_numeric_reply :created,  @host, "This server was created #{Time.now}"
          conn.send_numeric_reply :myinfo, @host, "#{settings.server_name} #{settings.server_version} #{""} #{""}"
        end
      end

      on :pass do |env|
        @pass = env.message.params[0]
      end

      on :nick do |env|
        @nick = env.message.params[0]
      end

      on :user do |env|
        @user = env.message.params[0]
        @real = env.message.params[3]
        port, @host = Socket.unpack_sockaddr_in(env.connection.get_peername)

        session_id = @authenticator.call(self)
        if session_id.nil?
          p "Auth error"
        else
          @authorized = true
          session = load_session env, session_id
          session.attach env.connection
          authorized env
          p 'Session attached.'
        end
      end
    end
  end
end
