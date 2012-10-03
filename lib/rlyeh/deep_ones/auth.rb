module Rlyeh
  module DeepOnes
    module Auth
      autoload :Base,  'rlyeh/deep_ones/auth/base'
      autoload :Null,  'rlyeh/deep_ones/auth/null'
      autoload :Basic, 'rlyeh/deep_ones/auth/basic'
      autoload :OAuth, 'rlyeh/deep_ones/auth/oauth'
    end
  end
end
