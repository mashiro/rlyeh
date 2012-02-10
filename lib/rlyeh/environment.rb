module Rlyeh
  class Environment < ::Hash
    def method_missing(method_id, *args)
      case method_id.to_s
      when /^(.+)=$/
        store $1.to_sym, args.first
      when /^(.+)\?$/
        key? $1.to_sym
      else
        unless key? method_id
          store method_id, Environment.new
        else
          fetch method_id
        end
      end
    end
  end
end
