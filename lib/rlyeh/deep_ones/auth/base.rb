module Rlyeh
  module DeepOnes
    module Auth
      class Base
        include Rlyeh::Dispatchable
        include Rlyeh::Loggable

        attr_reader :nick, :pass, :user, :real, :host

        def initialize(app, &block)
          @app = app
          @authenticated = false
          instance_eval &block if block
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

        def try(env)
          raise NotImplementedError
        end

        def succeeded(env)
          @authorized = true
          session = load_session env, to_session_id
          session.attach env.connection
          debug(env) { "Succeeded #{env.connection.host}:#{env.connection.port}" }
        end

        def failed(env)
          env.connection.send_numeric_reply :passwdmismatch, @host, ':Password incorrect'
          debug(env) { "Failed #{env.connection.host}:#{env.connection.port}" }
        end

        def welcome(env)
          name = env.settings.server_name
          version = env.settings.server_version
          user_modes = env.settings.available_user_modes
          channel_modes = env.settings.available_channel_modes

          messages = {
            :welcome  => "Welcome to the Internet Relay Network #{@nick}!#{@user}@#{@host}",
            :yourhost => "Your host is #{name}, running version #{version}",
            :created => "This server was created #{Time.now}",
            :myinfo => "#{name} #{version} #{user_modes} #{channel_modes}"
          }

          messages.each do |type, message|
            env.connection.send_numeric_reply type, @nick, ":#{message}", :prefix => {:servername => name}
          end
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

          try env
        end
      end
    end
  end
end
