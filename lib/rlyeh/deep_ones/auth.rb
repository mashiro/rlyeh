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

      def authenticate!(env, auth)
        @authenticator.call self
      end

      def succeeded(env, id)
        @authorized = true
        session = load_session env, id
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
      end

      def failed(env)
      end

      def load_session(env, id)
        env.server.sessions[id] ||= Rlyeh::Session.new(id)
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

        if (id = authenticate!(env, self))
          succeeded env, id
          debug(env) { "Succeeded #{env.connection.host}:#{env.connection.port}" }
        else
          failed env
          debug(env) { "Failed #{env.connection.host}:#{env.connection.port}" }
        end
      end
    end
  end
end
