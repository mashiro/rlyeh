require 'oauth'
require 'rlyeh/deep_ones/auth/base'

module Rlyeh
  module DeepOnes
    module Auth
      class OAuth < Rlyeh::DeepOnes::Auth::Base
        attr_accessor :consumer_key, :consumer_secret, :client_options
        attr_accessor :open_timeout, :read_timeout
        attr_accessor :authorize_params, :request_params
        attr_accessor :sender_nick
        attr_reader :access_token

        def initialize(app, consumer_key, consumer_secret, client_options = {})
          @consumer_key = consumer_key
          @consumer_secret = consumer_secret
          @client_options = client_options
          @open_timeout = 30
          @read_timeout = 30
          @authorize_params = {}
          @request_params = {}
          @sender_nick = '$oauth'
          super app
        end

        def consumer
          consumer = ::OAuth::Consumer.new @consumer_key, @consumer_secret, @client_options
          consumer.http.open_timeout = @open_timeout if @open_timeout
          consumer.http.read_timeout = @read_timeout if @read_timeout
          consumer
        end

        def try(env)
          welcome env
          request_phase env
        end

        def request_phase(env)
          @request_token = consumer.get_request_token @request_params
          env.sender.privmsg 'Access this URL get the PIN and paste it here.', :prefix => @sender_nick
          env.sender.privmsg @request_token.authorize_url(@authorize_params), :prefix => @sender_nick
        end

        on :privmsg do |env|
          unless authenticated?
            receiver = env.message.params[0]
            if receiver == sender_nick
              pin = env.message.params[1].to_s
              unless pin.empty?
                @access_token = @request_token.get_access_token :oauth_verifier => pin
                env.sender.privmsg 'Authentication succeeded.', :prefix => @sender_nick
                succeeded env
              end
            end
          end
        end
      end
    end
  end
end
