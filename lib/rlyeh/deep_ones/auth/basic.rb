module Rlyeh
  module DeepOnes
    module Auth
      class Basic < Rlyeh::DeepOnes::Auth::Base
        def initialize(app, nick, pass)
          basic = [nick, pass].freeze
          super app do |auth|
            basic == [auth.nick, auth.pass]
          end
        end
      end
    end
  end
end
