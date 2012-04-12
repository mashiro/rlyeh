require 'ircp'
require 'rlyeh/loggable'

module Rlyeh
  module DeepOnes
    class Parser
      include Rlyeh::Loggable

      def initialize(app)
        @app = app
      end

      def call(env)
        begin
          message = Ircp.parse env.data
          env.message = message
          env.event = message.command.to_s.downcase
          @app.call env if @app
        rescue Ircp::ParseError => e
          debug(env) { "#{e.class} - #{e.to_s}" }
        end
      end
    end
  end
end
