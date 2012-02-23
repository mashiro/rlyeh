require 'rlyeh/utils'

module Rlyeh
  module Filters
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def define_filters(*names, &block)
        names.each do |name|
          unless method_defined?("#{name}_with_filters")
            define_method(:"#{name}_with_filters") do |*args, &block|
              run_filters name, *args do
                send(:"#{name}_without_filters", *args, &block)
              end
            end
            alias_method :"#{name}_without_filters", :"#{name}"
            alias_method :"#{name}", :"#{name}_with_filters"
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

    def run_filters(name, *args, &block)
      catch :halt do
        _run_filters name, [:before, :arround], *args
        result = block.call *args if block
        _run_filters name, [:arround, :after], *args
        result
      end
    end

    [:before, :after, :around].each do |type|
      define_method(:"#{type}_filter") do |*names, &block|
        _insert_filter(names, type, block)
      end
      alias_method :"append_#{type}_filter", :"#{type}_filter"

      define_method(:"prepend_#{type}_filter") do |*names, &block|
        _insert_filter(names, type, block, :prepend => true)
      end

      define_method(:"remove_#{type}_filter") do |*names, &block|
        _remove_filter(names, type, block)
      end
    end

    private

    def _filters
      @_filters ||= {}
    end

    def _run_filters(name, types, *args, &block)
      named_filters = _filters[name.to_s] || {}
      types.each do |type|
        (named_filters[type.to_s] || []).each do |filter|
          throw :halt if filter.bind(self).call(*args, &block) == false
        end
      end
    end

    def _generate_filter_method(name, type, block)
      method_name = "__filter_#{type}_#{name}"
      Rlyeh::Utils.generate_method(singleton_class, method_name, block)
    end

    def _insert_filter(names, type, block, options = {})
      prepend = options[:prepend]
      names.each do |name|
        filter = _generate_filter_method name, type, block
        named_filters = (_filters[name.to_s] ||= {})
        filters = (named_filters[type.to_s] ||= [])
        if prepend
          filters.unshift filter
        else
          filters.push filter
        end
      end
    end

    def _remove_filter(names, type, block)
      names.each do |name|
        named_filters = (_filters[name.to_s] ||= {})
        filters = (named_filters[type.to_s] ||= [])
        filters.delete block
      end
    end
  end
end
