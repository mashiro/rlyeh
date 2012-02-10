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

    def _filter_callbacks
      @_filter_callbacks ||= {}
    end
    private :_filter_callbacks

    def _run_filter_callbacks(name, types, *args, &block)
      named_filter_callbacks = _filter_callbacks[name] || {}
      types.each do |type|
        (named_filter_callbacks[type] || []).each do |callback|
          callback.call(*args, &block)
        end
      end
    end
    private :_run_filter_callbacks

    def _insert_filter_callbacks(names, type, block, options = {})
      prepend = options[:prepend]
      names.each do |name|
        named_filter_callbacks = (_filter_callbacks[:"#{name}"] ||= {})
        callbacks = (named_filter_callbacks[type] ||= [])
        if prepend
          callbacks.unshift block
        else
          callbacks.push block
        end
      end
    end
    private :_insert_filter_callbacks

    def _remove_filter_callbacks(names, type, block)
      names.each do |name|
        named_filter_callbacks = (_filter_callbacks[:"#{name}"] ||= {})
        callbacks = (named_filter_callbacks[type] ||= [])
        callbacks.delete block
      end
    end
    private :_remove_filter_callbacks

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
