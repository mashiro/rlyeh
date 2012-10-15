require 'rlyeh/stores/base'

module Rlyeh
  module Stores
    class Memory < Rlyeh::Stores::Base
      def initialize(user, options = {})
        @cache = {}
        super
      end

      def read(name, options = {})
        @cache[name]
      end

      def write(name, value, options = {})
        @cache[name] = value
        true
      end

      def delete(name, options = {})
        !!@cache[name]
      end
    end
  end
end
