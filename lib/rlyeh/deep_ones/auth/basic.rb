require 'rlyeh/deep_ones/auth/base'

module Rlyeh
  module DeepOnes
    module Auth
      class Basic < Rlyeh::DeepOnes::Auth::Base
        def initialize(app, nick, pass)
          @basic = [nick, pass].freeze
          super app
        end

        def try(env)
          if @basic == [env.me.nick, env.me.pass]
            succeeded env
            welcome env
          else
            failed env
          end
        end
      end
    end
  end
end
