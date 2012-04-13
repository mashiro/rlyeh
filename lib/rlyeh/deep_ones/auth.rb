require 'rlyeh/dispatcher'
require 'rlyeh/loggable'

module Rlyeh
  module DeepOnes
    class Auth
      include Rlyeh::Dispatcher
      include Rlyeh::Loggable

      attr_reader :nick, :pass, :user, :real, :host

      def initialize(app, &block)
        @app = app
        @authenticator = block
        @authenticated = false
      end

      def call(env)
        dispatch env

        if authenticated?
          env.auth = self
          @app.call env if @app
        end
      end

      def authenticated?
        @authenticated
      end

      def authenticate!(env)
        if @authenticator && @authenticator.call(self)
          succeeded env
        else
          failed env
        end
      end

      def succeeded(env)
        @authorized = true
        session = load_session env, to_session_id
        session.attach env.connection

        name = env.settings.server_name
        version = env.settings.server_version
        messages = {
          :welcome  => "Welcome to the Internet Relay Network #{@nick}!#{@user}@#{@host}",
          :yourhost => "Your host is #{name}, running version #{version}",
          :created => "This server was created #{Time.now}",
          :myinfo => "#{name} #{version} #{""} #{""}"
        }

        messages.each do |type, message|
          env.connection.send_numeric_reply type, @host, message
        end

        debug(env) { "Succeeded #{env.connection.host}:#{env.connection.port}" }
      end

      def failed(env)
        debug(env) { "Failed #{env.connection.host}:#{env.connection.port}" }
      end

      def to_session_id
        @nick
      end

      def load_session(env, session_id)
        env.server.sessions[session_id] ||= Rlyeh::Session.new(session_id)
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
        @host = env.connection.host
        authenticate! env
      end
    end
  end
end
