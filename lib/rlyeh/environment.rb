module Rlyeh
  class Environment < ::Hash
    def respond_to?(method_id, include_private = false)
      super || respond_to_missing?(method_id, include_private)
    end

    def respond_to_missing?(method_name, include_private)
      method_name = method_id.to_s
      return true if method_name =~ /^(.+)=$/
      return true if self.key? method_name
      super
    end

    def method_missing(method_id, *args, &block)
      method_name = method_id.to_s
      return self[$1] = args.first if method_name =~ /^(.+)=$/
      return self[method_name] if self.key? method_name
      super method_id, *args, &block
    end
  end
end
