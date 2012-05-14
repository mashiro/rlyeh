require 'eventmachine'

module Rlyeh
  autoload :VERSION,      'rlyeh/version'

  autoload :Sendable,     'rlyeh/sendable'
  autoload :Dispatchable, 'rlyeh/dispatchable'
  autoload :Loggable,     'rlyeh/loggable'

  autoload :Filter,       'rlyeh/filter'
  autoload :Settings,     'rlyeh/settings'

  autoload :Server,       'rlyeh/server'
  autoload :Connection,   'rlyeh/connection'
  autoload :Session,      'rlyeh/session'
  autoload :Environment,  'rlyeh/environment'
  autoload :NumericReply, 'rlyeh/numeric_reply'
  autoload :Target,       'rlyeh/target'
  autoload :Base,         'rlyeh/base'

  require 'rlyeh/deep_ones'
  require 'rlyeh/runner'
  include Rlyeh::Runner
end
