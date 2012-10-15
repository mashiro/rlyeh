require 'rlyeh/stores'

module Rlyeh
  module DeepOnes
    class Store
      def initialize(app)
        @app = app
      end

      def call(env)
        env.session.store = store(env) if env.me? && env.session?
        @app.call env if @app
      end

      private

      def store(env)
        unless @store
          type, options = env.settings.store
          @store = Rlyeh::Stores.guess(type).new(env.me, options || {})
        end
        @store
      end
    end
  end
end
