module Rlyeh
  module DeepOnes
    class Session
      attr_reader :channel, :subscribers

      def initialize(app)
        @app = app
        @channel = EventMachine::Channel.new
        @subscribers = {}
      end

      def attach(connection)
        @subscribers[connection] = @channel.subscribe do |data|
          connection.send_data data
        end
      end

      def detach(connection)
        id = @subscribers.delete connection
        @channel.unsubscribe id if id
      end

      def send_data(data)
        @channel.push data
      end

      def empty?
        @subscribers.empty?
    end
  end
end
