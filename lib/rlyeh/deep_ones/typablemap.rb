module Rlyeh
  module DeepOnes
    class TypableMap
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call env if @app
      end
    end
  end
end
