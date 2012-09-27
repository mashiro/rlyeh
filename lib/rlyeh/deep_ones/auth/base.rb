require 'rlyeh/dispatcher'
require 'rlyeh/target'
require 'rlyeh/logger'

module Rlyeh
  module DeepOnes
    module Auth
      class Base
        include Rlyeh::Dispatcher
        include Rlyeh::Logger

        def initialize(app, &block)
          @app = app
          @authenticated = false
          instance_eval &block if block
        end

        def call(env)
          super env
          @app.call env if @app && authenticated?
        end

        def authenticated?
          @authenticated
        end

        def try(env)
          raise NotImplementedError
        end

        def session_id(env)
          env.user.nick
        end

        def succeeded(env)
          @authenticated = true
          session = env.server.load_session session_id(env)
          session.attach env.connection
          debug "Authentication succeeded #{env.connection.host}:#{env.connection.port}"
        end

        def failed(env)
          env.connection.send_numeric_reply :passwdmismatch, env.user.host, ':Password incorrect'
          debug "Authentication failed #{env.connection.host}:#{env.connection.port}"
        end

        def welcome(env)
          name = env.settings.server_name
          version = env.settings.server_version
          user_modes = env.settings.available_user_modes
          channel_modes = env.settings.available_channel_modes

          messages = {
            :welcome  => "Welcome to the Internet Relay Network #{env.user.nick}!#{env.user.user}@#{env.user.host}",
            :yourhost => "Your host is #{name}, running version #{version}",
            :created => "This server was created #{Time.now}",
            :myinfo => "#{name} #{version} #{user_modes} #{channel_modes}"
          }

          messages.each do |type, message|
            env.connection.send_numeric_reply type, env.user.nick, ":#{message}", :prefix => {:servername => name}
          end
        end

        on :user do |env|
          try env
        end
      end
    end
  end
end
