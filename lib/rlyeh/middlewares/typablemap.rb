module Rlyeh
  module Middlewares
    class TypableMap
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call env
      end
    end
  end
end
