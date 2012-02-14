require 'rlyeh/dispatcher'
require 'rlyeh/middlewares/builder'
require 'rlyeh/middlewares/parser'

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
        build(Rlyeh::Middlewares::Builder.new, *args, &block).to_app
      end

      def build(builder, *args, &block)
        setup_default_middlewares builder
        setup_middlewares builder
        builder.run new!(*args, &block)
        builder
      end

      def setup_default_middlewares(builder)
        builder.use! Rlyeh::Middlewares::Parser
      end

      def setup_middlewares(builder)
        middlewares.each do |name, args, block|
          builder.use(name, *args, &block)
        end
      end
    end

    def initialize(app = nil, options = {})
      @app = app
      @options = options
      yield self if block_given?
    end

    def call(env)
      catch :halt do
        name = env.message.command.to_s.downcase
        trigger name, env
        @app.call env if @app
      end
    end

    def halt
      throw :halt
    end
  end
end
