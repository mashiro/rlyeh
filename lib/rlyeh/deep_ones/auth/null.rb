require 'rlyeh/deep_ones/auth/base'

module Rlyeh
  module DeepOnes
    module Auth
      class Null < Rlyeh::DeepOnes::Auth::Base
        def try(env)
          succeeded env
          welcome env
        end
      end
    end
  end
end
