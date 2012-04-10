module Rlyeh
  module DeepOnes
    class Logger
      def initialize(app, level = :info)
        @app = app
        @level = level
      end

      def call(env)
        write env
        @app.call env if @app
      end

      def write(env)
        env.logger.send @level, env.data
      end
    end
  end
end
