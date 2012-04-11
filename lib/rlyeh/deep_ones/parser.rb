require 'ircp'

module Rlyeh
  module DeepOnes
    class Parser
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
          env.logger.debug "#{e.class} - #{e.to_s}"
        end
      end
    end
  end
end
