module Rlyeh
  class Environment < ::Hash
    def respond_to?(method_id, include_private = false)
      super || respond_to_missing?(method_id, include_private)
    end

    def respond_to_missing?(method_id, include_private)
      method_name = method_id.to_s
      return true if method_name =~ /^(.+)=$/
      return true if method_name =~ /^has_(.+)\?$/
      return true if self.key? method_name
      super
    end

    def method_missing(method_id, *args, &block)
      method_name = method_id.to_s
      return self[$1] = args.first if method_name =~ /^(.+)=$/
      return self.has_key? $1 if method_name =~ /^has_(.+)\?$/
      return self[method_name] if self.key? method_name
      super
    end
  end
end
