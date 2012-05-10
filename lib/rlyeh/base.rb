require 'rlyeh/settings'
require 'rlyeh/deep_ones/builder'
require 'rlyeh/deep_ones/parser'

module Rlyeh
  class Base
    include Rlyeh::Dispatchable
    include Rlyeh::Settings

    set :server_name, 'Rlyeh'
    set :server_version, Rlyeh::VERSION
    set :available_user_modes, ''
    set :available_channel_modes, ''

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
        build(Rlyeh::DeepOnes::Builder.new, *args, &block).to_app
      end

      def build(builder, *args, &block)
        setup_default_middlewares builder
        setup_middlewares builder
        builder.run new!(*args, &block)
        builder
      end

      def setup_default_middlewares(builder)
        builder.use! Rlyeh::DeepOnes::Closer
        builder.use! Rlyeh::DeepOnes::Parser
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
      dispatch env
      @app.call env if @app
    end

    def halt
      throw :halt
    end
  end
end
