module Rlyeh
  module Filter
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def define_filter(*names, &block)
        names.each do |name|
          unless method_defined?("#{name}_with_filter")
            define_method(:"#{name}_with_filter") do |*args, &block|
              _run_filter_callbacks(:"#{name}", [:before, :around], *args, &block)
              result = send(:"#{name}_without_filter", *args, &block)
              _run_filter_callbacks(:"#{name}", [:around, :after], *args, &block)
              result
            end
            alias_method :"#{name}_without_filter", :"#{name}"
            alias_method :"#{name}", :"#{name}_with_filter"
          end
        end
      end
    end

    unless respond_to? :singleton_class
      def singleton_class
        class << self
          self
        end
      end
    end

    private

    def _filter_callbacks
      @_filter_callbacks ||= {}
    end

    def _run_filter_callbacks(name, types, *args, &block)
      named_filter_callbacks = _filter_callbacks[name] || {}
      types.each do |type|
        (named_filter_callbacks[type] || []).each do |callback|
          callback.bind(self).call *args, &block
        end
      end
    end

    def _generate_filter_method(type, name, block)
      method_name = "__filter_#{type}_#{name}"
      singleton_class.instance_eval do
        define_method method_name, &block
        method = instance_method method_name
        remove_method method_name
        method
      end
    end

    def _insert_filter_callbacks(names, type, block, options = {})
      prepend = options[:prepend]
      names.each do |name|
        callback = _generate_filter_method type, name, block
        named_filter_callbacks = (_filter_callbacks[:"#{name}"] ||= {})
        callbacks = (named_filter_callbacks[type] ||= [])
        if prepend
          callbacks.unshift callback
        else
          callbacks.push callback
        end
      end
    end

    def _remove_filter_callbacks(names, type, block)
      names.each do |name|
        named_filter_callbacks = (_filter_callbacks[:"#{name}"] ||= {})
        callbacks = (named_filter_callbacks[type] ||= [])
        callbacks.delete block
      end
    end

    public

    [:before, :after, :around].each do |type|
      define_method(:"#{type}_filter") do |*names, &block|
        _insert_filter_callbacks(names, type, block)
      end
      alias_method :"append_#{type}_filter", :"#{type}_filter"

      define_method(:"prepend_#{type}_filter") do |*names, &block|
        _insert_filter_callbacks(names, type, block, :prepend => true)
      end

      define_method(:"remove_#{type}_filter") do |*names, &block|
        _remove_filter_callbacks(names, type, block)
      end
    end
  end
end
