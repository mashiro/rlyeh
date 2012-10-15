require 'celluloid'

module Rlyeh
  module Stores
    class Base
      include Celluloid

      def initialize(user, options = {})
      end

      def read(name, options = {})
        raise NotImplementedError
      end

      def write(name, value, options = {})
        raise NotImplementedError
      end

      def delete(name, options = {})
        raise NotImplementedError
      end
    end
  end
end
