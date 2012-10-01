require 'ircp'
require 'rlyeh/dispatcher'
require 'rlyeh/target'

module Rlyeh
  module DeepOnes
    class Me
      include Rlyeh::Dispatcher

      attr_reader :nick, :pass, :user, :real, :host

      def initialize(app)
        @app = app
      end

      def call(env)
        super env
        env.me = self
        env.message.prefix = to_prefix
        env.sender = Rlyeh::Target.new(env, @nick)
        @app.call env if @app
      end

      def to_prefix
        Ircp::Prefix.new(:nick => @nick, :user => @user, :host => @host)
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
      end
    end
  end
end
