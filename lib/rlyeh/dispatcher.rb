require 'rlyeh/utils'

module Rlyeh
  module Dispatcher
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def callbacks(name)
        @dispatchers ||= {}

        callbacks = @dispatchers.select do |key, value|
          if key.is_a?(Regexp)
            key =~ name
          else
            key == name
          end
        end.values.flatten

        if superclass.respond_to?(:callbacks)
          superclass.callbacks(name) + callbacks
        else
          callbacks
        end
      end

      def on(name, &block)
        @dispatchers ||= {}
        name = name.to_s if name.is_a?(Symbol)
        callbacks = (@dispatchers[name] ||= [])
        callbacks << Rlyeh::Utils.generate_method(self, "__on_#{name}", block)
        callbacks.uniq!
      end
    end

    def call(env)
      dispatch env
      @app.call env if @app
    end

    def dispatch(env)
      name = env.message.command.to_s.downcase
      trigger name, env
    end

    def trigger(name, *args, &block)
      callbacks = self.class.callbacks name
      callbacks.each do |callback|
        break if callback.bind(self).call(*args, &block) == false
      end
    end
  end
end
