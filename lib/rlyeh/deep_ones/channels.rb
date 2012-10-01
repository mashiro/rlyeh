require 'forwardable'
require 'rlyeh/dispatcher'
require 'rlyeh/callbacks'
require 'rlyeh/channel'
require 'rlyeh/utils'

module Rlyeh
  module DeepOnes
    class Channels
      include Rlyeh::Dispatcher
      include Rlyeh::Callbacks

      class Manager
        include Rlyeh::Callbacks
        extend Forwardable

        def_delegators :@channels, :[], :empty?, :include?

        def initialize
          @channels = {}
        end

        def join(env, *args)
          run_callbacks :join, env, *args do
            options = Rlyeh::Utils.extract_options!(args)
            nick = options[:nick] || env.me.nick
            key = options[:key]
            name = args.shift

            env.connection.send_message :JOIN, name, :prefix => {:nick => nick}
            channel = @channels[name] ||= Rlyeh::Channel.new(name, :key => key)
            unless channel.users.include? nick
              channel.users << nick
              env.sender.numeric_reply :namreply, '=', name, ":#{(channel.users).join(' ')}"
              env.sender.numeric_reply :endofnames, name, ':End of /NAMES list.'
            end
            channel
          end
        end

        def part(env, *args)
          run_callbacks :part, env, *args do
            options = Rlyeh::Utils.extract_options!(args)
            nick = options[:nick] || env.me.nick
            name = args.shift
            message = args.shift

            env.connection.send_message :PART, name, message, :prefix => {:nick => nick}
            @channels.delete(name)
          end
        end
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        env.session.channels ||= Manager.new if env.session?
        super env
        @app.call env if @app
      end

      on :join do |env|
        env.extract :session, :channels do |channels|
          names = (env.message.params[0] || '').split(',')
          keys = (env.message.params[1] || '').split(',')

          names.zip(keys).each do |name, key|
            channels.join env, name, :key => key
          end
        end
      end

      on :part do |env|
        env.extract :session, :channels do |channels|
          names = (env.message.params[0] || '').split(',')
          message = env.message.params[1]

          names.each do |name|
            channels.part env, name, message
          end
        end
      end
    end
  end
end
