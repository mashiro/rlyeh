require 'eventmachine'

module Rlyeh
  autoload :VERSION,      'rlyeh/version'

  autoload :Server,       'rlyeh/server'
  autoload :Connection,   'rlyeh/connection'
  autoload :Session,      'rlyeh/session'
  autoload :Environment,  'rlyeh/environment'
  autoload :NumericReply, 'rlyeh/numeric_reply'
  autoload :Base,         'rlyeh/base'

  autoload :Filter,       'rlyeh/filter'
  autoload :Settings,     'rlyeh/settings'

  autoload :Dispatchable, 'rlyeh/dispatchable'
  autoload :Loggable,     'rlyeh/loggable'

  require 'rlyeh/deep_ones'

  require 'rlyeh/runner'
  include Rlyeh::Runner
end
