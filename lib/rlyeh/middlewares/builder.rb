module Rlyeh
  module Middlewares
    class Builder
      def initialize(app = nil, &block)
        @stack = []
        @runner = app
        instance_eval(&block) if block_given?
      end

      def self.app(app = nil, &block)
        self.new(app, &block).to_app
      end

      def use(middleware, *args, &block)
        @stack << proc { |app| middleware.new(app, *args, &block) }
      end

      def use!(middleware, *args, &block)
        @stack.unshift lambda { |app| middleware.new(app, *args, &block) }
      end

      def run(app)
        @runner = app
      end

      def to_app
        @stack.reverse.inject(@runner) do |inner, outer|
          outer.call inner
        end
      end

      def call(env)
        to_app.call(env)
      end
    end
  end
end
