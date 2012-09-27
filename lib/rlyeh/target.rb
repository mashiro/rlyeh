module Rlyeh
  class Target
    def initialize(env, target)
      @env = env
      @target = target
    end

    def send_message(command, text, prefix = nil)
      prefix = {:nick => prefix} unless prefix.is_a?(Hash)
      unless prefix.key? :servername
        prefix[:nick] ||= 'rlyeh'
        prefix[:user] ||= 'rlyeh'
        prefix[:host] ||= @env.settings.server_name
      end

      @env.connection.send_message command, @target, ":#{text}", :prefix => prefix
    end

    def privmsg(text, prefix = nil)
      send_message 'PRIVMSG', text, prefix
    end

    def notice(text, prefix = nil)
      send_message 'NOTICE', text, prefix
    end
  end
end
