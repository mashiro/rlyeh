module Rlyeh
  class Target
    attr_reader :env, :target

    def initialize(env, target)
      @env = env
      @target = target
    end

    def send_message(command, message, options = {})
      prefix = options[:prefix]
      prefix = {:nick => prefix} if prefix && !prefix.is_a?(::Hash)
      @env.connection.send_message command, @target, ":#{message}", :prefix => prefix
    end

    def numeric_reply(type, *args)
      @env.connection.send_numeric_reply type, @target, *args, :prefix => {:servername => server_name}
    end

    def msg(message, options = {})
      notice = options.delete(:notice) { false }
      command = notice ? 'NOTICE' : 'PRIVMSG'
      send_message command, message, options
    end

    def privmsg(message, options = {})
      options[:notice] = false
      msg message, options
    end

    def notice(message, options = {})
      options[:notice] = true
      msg message, options
    end

    private

    def server_name
      @env.settings.server_name
    end
  end
end
