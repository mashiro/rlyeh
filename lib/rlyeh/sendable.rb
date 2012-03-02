require 'ircp'
require 'rlyeh/numeric_reply'

module Rlyeh
  module Sendable
    def send_numeric_reply(numeric, target, *args)
      numeric = Rlyeh::NumericReply.to_value numeric
      send_data Ircp::Message.new(target, *args, :command => numeric)
    end
  end
end
