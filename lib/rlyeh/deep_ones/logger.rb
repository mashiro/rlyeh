require 'logger'

module Rlyeh
  module DeepOnes
    class Logger
      def initialize(app, options = {})
        @app = app
        @logger = options[:logger] || ::Logger.new(STDOUT)
        @logger.level = options[:level] || ::Logger::INFO
      end

      def call(env)
        write env
        @app.call env
      end

      def write(env)
        @logger.debug env.data
      end
    end
  end
end
