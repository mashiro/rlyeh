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
          @app.call env
        rescue Ircp::ParseError => e
          p e
        end
      end
    end
  end
end
