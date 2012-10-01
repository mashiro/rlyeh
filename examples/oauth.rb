#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift 'lib', '../lib'
require 'rlyeh'

class OAuthServer < Rlyeh::Base
  use Rlyeh::DeepOnes::Logger
  use Rlyeh::DeepOnes::Auth::OAuth, 'consumer key', 'consumer secret', {
    :authorize_path => '/oauth/authenticate',
    :site => 'https://api.twitter.com'
  }

  set :server_name, 'oauth-server'
  set :server_version, '1.0.0'

  on :privmsg do |env|
    puts "RECV: #{env.message}"
  end
end

Rlyeh.emerge OAuthServer, :host => '0.0.0.0'
