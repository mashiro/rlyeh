require 'rlyeh/attributes'

module Rlyeh
  class Environment < ::Hash
    include Rlyeh::Attributes

    def attributes
      self
    end

    def extract(*syms, &block)
      value = syms.inject(self) do |obj, sym|
        return if obj.nil?
        if obj.respond_to?("#{sym}?")
          obj.__send__(sym) if obj.__send__("#{sym}?")
        else
          obj.__send__(sym)
        end
      end

      block.call value if block && !value.nil?
      value
    end
  end
end
