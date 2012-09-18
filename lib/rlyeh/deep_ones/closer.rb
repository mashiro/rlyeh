require 'rlyeh/dispatcher'

module Rlyeh
  module DeepOnes
    class Closer
      include Rlyeh::Dispatcher

      def initialize(app)
        @app = app
      end

      def call(env)
        dispatch env
        @app.call env if @app
      end

      on :quit do |env|
        throw :quit
      end
    end
  end
end
