module Rlyeh
  module Stores
    autoload :Base,   'rlyeh/stores/base'
    autoload :Null,   'rlyeh/stores/null'
    autoload :Memory, 'rlyeh/stores/memory'

    class << self
      def guess(name_or_class)
        if name_or_class.is_a? Class
          name_or_class
        else
          name = name_or_class.to_s
          class_name = name.gsub(/(^|[_.-])(\w)/) { |s| $2.upcase }
          const_get class_name
        end
      end
    end
  end
end
