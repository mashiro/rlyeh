module Rlyeh
  module Runner
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def run(*args, &block)
        starter = proc do
          Server.start *args, &block
        end

        if EventMachine.reactor_running?
          starter.call
        else
          EventMachine.run &starter
        end
      end

      def stop
        EventMachine.stop if EventMachine.reactor_running?
      end
    end
  end
end
