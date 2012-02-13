require 'rlyeh/utils'

module Rlyeh
  module Runner
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def servers
        @servers ||= []
      end

      def run(*args, &block)
        default_options = {:signal_trap => true}.freeze
        options = default_options.merge(Rlyeh::Utils.extract_options args)
        signal_trap = options.delete(:signal_trap)

        trap(:INT) { stop } if signal_trap

        starter = proc do
          server = Server.start *args, &block
          servers << server
        end

        if EventMachine.reactor_running?
          starter.call
        else
          EventMachine.run &starter
        end
      end

      def stop
        servers.each { |server| server.stop }
        servers.clear

        EventMachine.stop if EventMachine.reactor_running?
      end
    end
  end
end
