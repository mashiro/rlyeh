require 'oauth'

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

          talk env, 'Access this URL get the PIN and paste it here.'
          talk env, request_token.authorize_url(@authorize_params)
        end

        private

        def talk(env, text)
          prefix = {:nick => '$oauth', :user => 'rlyeh', :host => env.settings.server_name}
          env.connection.send_message 'PRIVMSG', @nick, ":#{text}", :prefix => prefix
        end
      end
    end
  end
end
