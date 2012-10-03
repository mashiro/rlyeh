require 'rlyeh/dispatcher'

module Rlyeh
  module DeepOnes
    module CTCP
      class Parser
        include Rlyeh::Dispatcher

        def initialize(app)
          @app = app
        end

        def call(env)
          super
          @app.call env if @app
        end

        on :privmsg do |env|
          unless env.ctcp?
            message = env.message.params.last.to_s
            env.ctcp = message.scan(/\x01(.*?)(\x01|$)/).map(&:first)
          end
        end
      end
    end
  end
end
