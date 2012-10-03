require 'rlyeh/dispatcher'
require 'rlyeh/settings'
require 'rlyeh/deep_ones'

module Rlyeh
  class Base
    include Rlyeh::Dispatcher
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

      def use(middleware, *args, &block)
        @middlewares ||= []
        @middlewares << [middleware, args, block]
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
        builder.use! Rlyeh::DeepOnes::Me
        builder.use! Rlyeh::DeepOnes::Quit
        builder.use! Rlyeh::DeepOnes::Parser
      end

      def setup_middlewares(builder)
        middlewares.each do |middleware, args, block|
          builder.use(middleware, *args, &block)
        end

        unless middlewares.any? { |middleware, args, block| middleware.ancestors.include?(Rlyeh::DeepOnes::Auth::Base) }
          builder.use Rlyeh::DeepOnes::Auth::Null
        end
      end
    end

    def initialize(app = nil, options = {})
      @app = app
      @options = options
      yield self if block_given?
    end

    def call(env)
      super env
      @app.call env if @app
    end

    def halt
      throw :halt
    end
  end
end
