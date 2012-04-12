require 'logger'

module Rlyeh
  module Loggable
    [:debug, :info, :warn, :error, :fatal].each do |method|
      define_method method do |env_or_logger, name = nil, &block|
      logger = env_or_logger.is_a?(::Logger) ? env_or_logger : env_or_logger.logger
      logger.send(method, name || self.class.name) { block.call }
      end
    end
  end
end
