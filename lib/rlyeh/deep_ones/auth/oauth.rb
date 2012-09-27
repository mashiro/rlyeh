require 'oauth'
require 'rlyeh/deep_ones/auth/base'

module Rlyeh
  module DeepOnes
    module Auth
      class OAuth < Rlyeh::DeepOnes::Auth::Base
        attr_accessor :consumer_key, :consumer_secret, :client_options
        attr_accessor :open_timeout, :read_timeout
        attr_accessor :authorize_params, :request_params
        attr_reader :access_token

        def initialize(app, consumer_key, consumer_secret, client_options = {})
          @consumer_key = consumer_key
          @consumer_secret = consumer_secret
          @client_options = client_options
          @open_timeout = nil
          @read_timeout = nil
          @authorize_params = {}
          @request_params = {}
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
          request_token = consumer.get_request_token @request_params
          env.sender.privmsg 'Access this URL get the PIN and paste it here.', sender_nick
          env.sender.privmsg request_token.authorize_url(@authorize_params), sender_nick
        end

        protected

        def sender_nick
          '$oauth'
        end
      end
    end
  end
end
