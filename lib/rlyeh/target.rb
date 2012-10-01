module Rlyeh
  class Target
    attr_reader :env, :target

    def initialize(env, target)
      @env = env
      @target = target
    end

    def send_message(command, message, prefix = nil)
      prefix = {:nick => prefix} unless prefix.is_a?(Hash)
      @env.connection.send_message command, @target, ":#{message}", :prefix => prefix
    end

    def privmsg(message, prefix = nil)
      send_message 'PRIVMSG', message, prefix
    end

    def notice(message, prefix = nil)
      send_message 'NOTICE', message, prefix
    end

    def numeric_reply(type, *args)
      @env.connection.send_numeric_reply type, @target, *args, :prefix => {:servername => server_name}
    end

    private

    def server_name
      @env.settings.server_name
    end
  end
end
