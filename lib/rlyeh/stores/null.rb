require 'rlyeh/stores/base'

module Rlyeh
  module Stores
    class Null < Rlyeh::Stores::Base
      def initialize(user, options = {})
        super
      end

      def read(name, options = {})
      end

      def write(name, value, options = {})
        true
      end

      def delete(name, options = {})
        false
      end
    end
  end
end
