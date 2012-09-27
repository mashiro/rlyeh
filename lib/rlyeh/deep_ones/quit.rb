require 'rlyeh/dispatcher'
require 'rlyeh/connection'

module Rlyeh
  module DeepOnes
    class Quit
      include Rlyeh::Dispatcher

      def initialize(app)
        @app = app
      end

      def call(env)
        super env
        @app.call env if @app
      end

      on :quit do |env|
        raise Rlyeh::QuitConnection
      end
    end
  end
end
