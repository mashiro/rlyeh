require 'rlyeh/dispatcher'
require 'rlyeh/middleware/builder'

module Rlyeh
  class Base
    include Rlyeh::Dispatcher

    class << self
      def middlewares
        @middlewares ||= []
        if superclass.respond_to?(:middlewares)
          superclass.middlewares + @middlewares
        else
          @middlewares
        end
      end

      def use(name, *args, &block)
        @middlewares ||= []
        @middlewares << [name, args, block]
        @middlewares = @middlewares.uniq
      end

      alias new! new unless method_defined? :new!
      def new(*args, &block)
        build(Rlyeh::Middleware::Builder.new, *args, &block).to_app
      end

      private

      def build(builder, *args, &block)
        setup_default_middlewares builder
        setup_middlewares builder
        builder.run new!(*args, &block)
        builder
      end

      def setup_default_middlewares(builder)
      end

      def setup_middlewares(builder)
        middlewares.each do |name, args, block|
          builder.use(name, *args, &block)
        end
      end
    end

    def initialize(app = nil)
      @app = app
      yield self if block_given?
    end

    def call(env)
      name = env.message.command.to_s.downcase
      trigger name, env

      @app.call env if @app
    end

    def trigger(name, *args, &block)
      callbacks = self.class.callbacks name
      callbacks.each do |callback|
        callback.bind(self).call *args, &block
      end
    end
  end
end
