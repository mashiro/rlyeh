module Rlyeh
  module Settings
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def settings
        self
      end

      def set(name_or_settings, *args, &block)
        if name_or_settings.respond_to?(:each)
          name_or_settings.each { |k, v| set k, *([v].flatten(1)) }
          return self
        end

        name = name_or_settings
        setter = proc { |*_args| set name, *_args }
        getter = block ? block : proc { args.length <= 1 ? args.first : args }
        exist = proc { !!__send__(name) }

        singleton_class.class_eval do
          define_method "#{name}=", &setter
          define_method "#{name}", &getter
          define_method "#{name}?", &exist
        end
      end
    end

    def settings
      self.class.settings
    end
  end
end
