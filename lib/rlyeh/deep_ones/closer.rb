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
        env.connection.close_connection_after_writing
        throw :halt
      end
    end
  end
end
