module Rlyeh
  module Middleware
    class Builder
      def initialize(&block)
        @ins = []
        instance_eval(&block) if block_given?
      end

      def self.app(&block)
        self.new(&block).to_app
      end

      def use(middleware, *args, &block)
        @ins << lambda { |app| middleware.new(app, *args, &block) }
      end

      def run(app)
        @ins << app #lambda { |nothing| app }
      end

      def to_app
        inner_app = @ins.last
        @ins[0...-1].reverse.inject(inner_app) { |a, e| e.call(a) }
      end

      def call(env)
        to_app.call(env)
      end
    end
  end
end
