module Rlyeh
  module Utils
    class << self
      def extract_options!(args)
        args.last.is_a?(::Hash) ? args.pop : {}
      end
    end
  end
end
