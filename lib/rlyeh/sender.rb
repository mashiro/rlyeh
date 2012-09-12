require 'ircp'
require 'rlyeh/numeric_reply'
require 'rlyeh/utils'

module Rlyeh
  module Sender
    def send_message(command, *args)
      options = Rlyeh::Utils.extract_options! args
      send_data Ircp::Message.new(*args, options.merge(:command => command))
    end

    def send_numeric_reply(type, target, *args)
      options = Rlyeh::Utils.extract_options! args
      numeric = Rlyeh::NumericReply.to_value type
      send_data Ircp::Message.new(target, *args, options.merge(:command => numeric))
    end
  end
end
