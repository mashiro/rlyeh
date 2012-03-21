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
        env.connection.tap do |conn|
          conn.send_numeric_reply :welcome, @nick, "Welcome to the Internet Relay Network #{@nick}!#{@user}@#{@host}"
          conn.send_numeric_reply :yourhost, @nick, "Your host is #{"Rlyeh"}, running version #{Rlyeh::VERSION}"
          conn.send_numeric_reply :created,  @nick, "This server was created #{Time.now}"
          conn.send_numeric_reply :myinfo, @nick, "#{"Rlyeh"} #{Rlyeh::VERSION} #{""} #{""}"
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