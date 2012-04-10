#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift 'lib', '../lib'
require 'rlyeh'

class MyApp < Rlyeh::Base
  use Rlyeh::DeepOnes::Logger, :info
  use Rlyeh::DeepOnes::Auth do |auth|
    auth.nick if [auth.nick, auth.pass] == ['dankogai', 'kogaidan']
  end
  
  set :server_name, 'MyApp'
  set :server_version, '1.0.0'

  on :privmsg do |env|
    puts "RECV: #{env.message}"
  end
end

Rlyeh.emerge MyApp, :host => '0.0.0.0'
