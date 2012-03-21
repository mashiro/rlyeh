module Rlyeh
  module Settings
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def settings
        self
      end

      def set(option, value = nil, &block)
        if option.respond_to?(:each)
          option.each { |k, v| set k, v }
          return self
        end

        setter = proc { |v| set option, v }
        getter = block ? block : proc { value }

        Rlyeh::Utils.singleton_class(self).class_eval do
          define_method "#{option}=", &setter if setter
          define_method "#{option}", &getter if getter
          class_eval "def #{option}?; !!#{option}; end" unless method_defined?("#{option}?")
        end
      end

      self
    end

    def settings
      self.class.settings
    end
  end
end
