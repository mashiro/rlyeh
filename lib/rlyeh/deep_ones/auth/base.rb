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

        def session_id(env)
          env.me.nick
        end

        def succeeded(env)
          @authenticated = true
          session = env.server.load_session session_id(env)
          session.attach env.connection
          debug "Authentication succeeded #{env.connection.host}:#{env.connection.port}"
        end

        def failed(env)
          env.connection.send_numeric_reply :passwdmismatch, env.me.host, ':Password incorrect'
          debug "Authentication failed #{env.connection.host}:#{env.connection.port}"
        end

        def welcome(env)
          name = env.settings.server_name
          version = env.settings.server_version
          user_modes = env.settings.available_user_modes
          channel_modes = env.settings.available_channel_modes

          messages = {
            :welcome  => "Welcome to the Rlyeh Internet Relay Network Gateway #{env.me.to_prefix}",
            :yourhost => "Your host is #{name}, running version #{version}",
            :created => "This server was created #{Time.now}",
            :myinfo => "#{name} #{version} #{user_modes} #{channel_modes}"
          }

          messages.each do |type, message|
            env.sender.numeric_reply type, ":#{message}"
          end
        end

        on :user do |env|
          try env
        end
      end
    end
  end
end
