module Rlyeh
  module Utils
    class << self
      def singleton_class(obj)
        if obj.respond_to?(:singleton_class)
          obj.singleton_class
        else
          class << obj
            self
          end
        end
      end

      def extract_options(args)
        args.last.is_a?(::Hash) ? args.last : {}
      end

      def extract_options!(args)
        args.last.is_a?(::Hash) ? args.pop : {}
      end

      def generate_method(obj, name, method = nil, &block)
        name = name.to_s
        method ||= block
        obj.instance_eval do
          define_method name, &method
          method = instance_method name
          remove_method name
          method
        end
      end
    end
  end
end
