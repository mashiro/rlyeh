require 'monitor'

module Rlyeh
  class SyncDelegator < ::BasicObject
    def initialize(obj)
      __setobj__(obj)
      @monitor = ::Monitor.new
    end

    def method_missing(method_id, *args, &block)
      define_synchronized_method(method_id)
      __call__(method_id, *args, &block)
    end

    def __call__(method_id, *args, &block)
      __sync__ do
        __getobj__.__send__(method_id, *args, &block)
      end
    end

    def __sync__(&block)
      @monitor.synchronize do
        block.call if block
      end
    end

    def __setobj__(obj)
      @sync_delegator_obj = obj
    end

    def __getobj__
      @sync_delegator_obj
    end

    private

    def define_synchronized_method(method_id)
      __sync__ do
        singleton_class = (class << self; self; end)
        singleton_class.class_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{method_id}(*args, &block)
            __call__(:#{method_id}, *args, &block)
          end
        EOS
      end
    end
  end
end
