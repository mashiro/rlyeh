require 'rlyeh/dispatcher'

module Rlyeh
  module DeepOnes
    class Auth
      include Rlyeh::Dispatcher

      attr_reader :nick, :pass, :user, :real

      def initialize(app, &authenticator)
        @app = app
        @authenticator = authenticator
        @authorized = false
      end

      def call(env)
        dispatch env
        @app.call env if authorized?
      end

      def load_session(env, id)
        env.server.sessions[id] ||= Rlyeh::Session.new(id)
      end

      def authorized?
        @authorized
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

        session_id = @authenticator.call(self) if @authenticator
        if session_id.nil?
          p "Auth error"
        else
          @authorized = true
          session = load_session env, session_id
          session.attach env.connection
          p 'Session attached.'
        end
      end
    end
  end
end
