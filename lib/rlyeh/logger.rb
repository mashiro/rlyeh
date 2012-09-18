module Rlyeh
  module Logger
    module_function

    [:debug, :info, :warn, :error, :fatal].each do |level|
      define_method level do |message|
        Rlyeh.logger.__send__(level, message) if Rlyeh.logger
      end
    end

    def crash(exception, message = nil)
      error [message, format_exception(exception)].compact.join("\n")
    end

    def format_exception(exception)
      str = "#{exception.class}: #{exception.to_s}\n"
      str << exception.backtrace.map { |s| "  #{s}" }.join("\n")
    end
  end
end
