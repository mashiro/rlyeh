require 'rlyeh/logger'

module Rlyeh
  module DeepOnes
    class Logger
      include Rlyeh::Logger

      def initialize(app, logger = nil, level = :debug)
        @app = app
        @logger = logger || self
        @level = level
      end

      def call(env)
        write env
        @app.call env if @app
      end

      def write(env)
        @logger.__send__ @level, "Message received: #{env.data}"
      end
    end
  end
end
