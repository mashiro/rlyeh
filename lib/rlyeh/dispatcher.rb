require 'rlyeh/utils'

module Rlyeh
  module Dispatcher
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def callbacks(target)
        @dispatchers ||= []
        callbacks = @dispatchers.select do |item|
          key = item[0]
          case key
          when Regexp then key =~ target
          else             key == target
          end
        end.map { |item| item[1] }.flatten

        if superclass.respond_to?(:callbacks)
          superclass.callbacks(target) + callbacks
        else
          callbacks
        end
      end

      def on(*args, &block)
        options = Rlyeh::Utils.extract_options! args
        target = args.shift
        target = Array(options[:scope]) + Array(target) if [String, Symbol].any? { |type| target.is_a?(type) }
        target = target.join('.') if target.is_a?(Array)

        @dispatchers ||= []
        @dispatchers << [target, Rlyeh::Utils.generate_method(self, "__on_#{target}", block)]
      end
    end

    def call(env)
      if env.event?
        target = env.event
        trigger target, env
      end
    end
    alias_method :dispatch, :call

    def trigger(target, *args, &block)
      callbacks = self.class.callbacks target
      callbacks.each do |callback|
        break if callback.bind(self).call(*args, &block) == false
      end
    end
  end
end
