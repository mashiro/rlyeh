require 'rlyeh/version'

require 'rlyeh/logger'
require 'rlyeh/dispatcher'
require 'rlyeh/sender'

require 'rlyeh/settings'
require 'rlyeh/server'
require 'rlyeh/connection'
require 'rlyeh/session'
require 'rlyeh/environment'
require 'rlyeh/numeric_reply'
require 'rlyeh/target'
require 'rlyeh/base'

require 'rlyeh/deep_ones'

module Rlyeh
  class << self
    attr_accessor :logger

    def run(app_class, options = {})
      supervisor = Rlyeh::Server.supervise_as :server, app_class, options

      trap(:INT) do
        supervisor.terminate
        exit
      end

      sleep
    end
    alias_method :emerge, :run
  end
end

require 'logger'
Celluloid.logger = nil
Rlyeh.logger = ::Logger.new $stderr

