module Rlyeh
  module Dispatcher
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def callbacks(name)
        @dispatchers ||= {}
        callbacks = @dispatchers[name] || []
        if superclass.respond_to?(:callbacks)
          superclass.callbacks(name) + callbacks
        else
          callbacks
        end
      end

      def on(name, &block)
        @dispatchers ||= {}
        name = name.to_s
        callbacks = (@dispatchers[name] ||= [])
        callbacks << generate_method(name, &block)
        callbacks.uniq!
      end

      def generate_method(method_name, &block)
        define_method method_name, &block
        method = instance_method method_name
        remove_method method_name
        method
      end
    end

    def dispatch(env)
      name = env.message.command.to_s.downcase
      trigger name, env
    end

    def trigger(name, *args, &block)
      catch :pass do
        callbacks = self.class.callbacks name
        callbacks.each do |callback|
          throw :pass if callback.bind(self).call(*args, &block) == false
        end
      end
    end
  end
end
