module Rlyeh
  module Attributes
    ATTRIBUTES_REGEX = /^(.+)([=\?])$/

    def attributes
      raise NotImplementedError
    end

    def read_attribute(name)
      attributes[name.to_s]
    end

    def write_attribute(name, value)
      attributes[name.to_s] = value
    end

    def has_attribute?(name)
      attributes.include? name.to_s
    end

    def respond_to?(method_id, include_private = false)
      super || respond_to_missing?(method_id, include_private)
    end

    def respond_to_missing?(method_id, include_private)
      true
    end

    def method_missing(method_id, *args, &block)
      method_name = method_id.to_s
      if method_name =~ ATTRIBUTES_REGEX
        case $2
        when '='
          write_attribute $1, args.first
        when '?'
          has_attribute? $1
        end
      else
        read_attribute method_name
      end
    end
  end
end
