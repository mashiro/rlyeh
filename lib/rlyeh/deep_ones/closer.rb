require 'rlyeh/dispatcher'
require 'rlyeh/connection'

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
        raise Rlyeh::QuitConnection
      end
    end
  end
end
