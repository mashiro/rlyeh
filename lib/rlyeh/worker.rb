require 'celluloid'

module Rlyeh
  module Worker
    class ThreadPool
      include Celluloid

      def invoke(*args, &block)
        block.call *args if block
      end
    end

    class << self
      def included(base)
        base.extend ClassMethods
      end

      def setup(options = {})
        @worker_pool = ThreadPool.pool options
      end

      def worker_pool
        @worker_pool ||= setup
      end
    end

    module ClassMethods
      def worker_pool
        @worker_pool ||= Rlyeh::Worker.worker_pool
      end
    end

    def invoke(*args, &block)
      self.class.worker_pool.invoke *args, &block
    end
  end
end

