require 'rlyeh/deep_ones/auth/base'
require 'rlyeh/deep_ones/auth/null'

module Rlyeh
  module DeepOnes
    module Auth
      autoload :Basic, 'rlyeh/deep_ones/auth/basic'
      autoload :OAuth, 'rlyeh/deep_ones/auth/oauth'
    end
  end
end
