require 'eventmachine'

module Rlyeh
  autoload :VERSION,      'rlyeh/version'

  autoload :Server,       'rlyeh/server'
  autoload :Connection,   'rlyeh/connection'
  autoload :Session,      'rlyeh/session'
  autoload :Environment,  'rlyeh/environment'
  autoload :Base,         'rlyeh/base'

  autoload :Dispatcher,   'rlyeh/dispatcher'
  autoload :Filter,       'rlyeh/filter'

  require 'rlyeh/deep_ones'

  require 'rlyeh/runner'
  include Rlyeh::Runner
end
