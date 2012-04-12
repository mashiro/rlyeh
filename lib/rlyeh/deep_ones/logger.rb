require 'rlyeh/loggable'

module Rlyeh
  module DeepOnes
    class Logger
      include Rlyeh::Loggable

      def initialize(app, logger = nil)
        @app = app
        @logger = logger
      end

      def call(env)
        write env
        @app.call env if @app
      end

      def write(env)
        debug(@logger || env) { "Recieve: #{env.data}" }
      end
    end
  end
end
