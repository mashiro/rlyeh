require 'logger'

module Rlyeh
  module DeepOnes
    class Logger
      def initialize(app, logger = nil)
        @app = app
        @logger = logger
      end

      def call(env)
        write env
        @app.call env if @app
      end

      def write(env)
        (@logger || env.logger).debug('Data') { env.data }
      end
    end
  end
end
